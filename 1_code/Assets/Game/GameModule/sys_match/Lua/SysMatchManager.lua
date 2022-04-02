-- 创建时间:2021-06-01
-- SysMatchManager 管理器

local basefunc = require "Game/Common/basefunc"
SysMatchManager = {}
local M = SysMatchManager
M.key = "sys_match"
M.award_config = GameModuleManager.ExtLoadLua(M.key,"sys_match_award_config")
M.config = GameModuleManager.ExtLoadLua(M.key,"sys_match_config")
GameModuleManager.ExtLoadLua(M.key,"SysMatchPanel")
GameModuleManager.ExtLoadLua(M.key,"SysRankMatchPanel")
GameModuleManager.ExtLoadLua(M.key,"SysMatchAwardPanel")
local this
local listener

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameModuleManager.RunFun({_goto="sys_permission", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.Goto(parm)
	if parm.goto_parm == "view" then
        return SysMatchPanel.Create(parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm._goto == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { _goto = M.key })
end


local function AddListener()
    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if listener then
        for msg,cbk in pairs(listener) do
            Event.RemoveListener(msg, cbk)
        end
    end
    listener=nil
end
local function MakeListener()
    listener = {}
    listener["login_complete"] = this.on_login_complete
    listener["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    listener["model_on_pvp_game_settlement_msg"] = this.on_model_on_pvp_game_settlement_msg
    listener["pvp_duanwei_get_data_response"] = this.on_pvp_duanwei_get_data_response
    listener["ExitScene"] = this.OnExitScene
    listener["pvp_duanwei_get_award_list_response"] = this.on_pvp_duanwei_get_award_list_response
    listener["pvp_duanwei_take_award_response"] = this.on_pvp_duanwei_take_award_response
end

function M.Init()
	M.Exit()

	this = SysMatchManager
	this.m_data = {}
	MakeListener()
    AddListener()
	M.InitUIConfig()
    M.InitAwardData()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitAwardData()
    this.awardData = {}
    for k,v in pairs(M.award_config.base) do
        this.awardData[v.grade] = this.awardData[v.grade] or {}
        this.awardData[v.grade][v.level] = 0
    end
end

local function UpdataAwardData(award)
    for k,v in pairs(this.awardData) do
        for _k,_v in pairs(v) do
            this.awardData[k][_k] = 2
            for __k,__v in pairs(award) do
                if k == __v.grade and _k == __v.level then
                    this.awardData[k][_k] = 1
                end
            end
            if k > this.match_data.grade
            or (k == this.match_data.grade and _k > this.match_data.level) then
                this.awardData[k][_k] = 0
            end
        end
    end
    dump(this.awardData,"<color=red>AwardData</color>")
end

function M.on_pvp_duanwei_get_award_list_response(_, data)
    dump(data, "<color=red>未领取的段位升级奖励</color>")
    dump(this.match_data, "<color=red>当前段位信息</color>")
    if data.result == 0 then
        UpdataAwardData(data.award)
        Event.Brocast("manager_pvp_get_award_list_change_msg")
    end
end

function M.on_pvp_duanwei_take_award_response(_, data)
    dump(data, "<color=red>领奖结果</color>")
    if data.result == 0 then
        -- UpdataAwardData(data.award)
        -- Event.Brocast("manager_pvp_get_award_list_change_msg")
        --领奖成功的时候，重新请求List
        Network.SendRequest("pvp_duanwei_get_award_list")
    end
end

function M.GetAwardStatus(grade, level)
    if this.awardData[grade][level] then
        return this.awardData[grade][level]
    end
    return 0
end

function M.InitUIConfig()
    this.UIConfig = {}
end

function M.GetMatchCfg()
    return M.config
end

function M.GetGradeLevelAward(grade,level)
    if not grade or not level then return end
    for k,v in pairs(M.config.level) do
        if v.grade == grade and v.level == level then
            return v
        end
    end
end

function M.on_model_on_pvp_game_settlement_msg(data)
    this.match_data = data
    Event.Brocast("manager_pvp_duanwei_change_msg")
end

function M.on_pvp_duanwei_get_data_response(_,data)
    if data.result == 0 then
        this.match_data = data
        Event.Brocast("manager_pvp_duanwei_change_msg")
    end
end

function M.on_login_complete()
    Network.SendRequest("pvp_duanwei_get_data")

    --获取还未领取的段位奖励列表
    Network.SendRequest("pvp_duanwei_get_award_list")
end

function M.GetMatchData()
    dump(this.match_data,"<color=yellow>比赛数据</color>")
    return this.match_data
end

function M.OnExitScene()
    SysMatchPanel.Close()
end