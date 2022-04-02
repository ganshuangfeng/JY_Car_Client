-- 创建时间:2021-06-07
-- SysBoxManager 管理器

local basefunc = require "Game/Common/basefunc"
SysBoxManager = {}
local M = SysBoxManager
M.key = "sys_box"
M.config = GameModuleManager.ExtLoadLua(M.key,"sys_box_base_config")
GameModuleManager.ExtLoadLua(M.key,"SysBoxItem")
GameModuleManager.ExtLoadLua(M.key,"SysBoxOpenPanel")

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
    listener["query_player_timer_box_data_response"] = this.on_query_player_timer_box_data_response
    listener["on_timer_box_data_change"] = this.on_timer_box_data_change
    listener["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = SysBoxManager
	this.m_data = {}
	MakeListener()
    AddListener()
	M.InitUIConfig()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

function M.AddBoxNode(box_node_list)
    Network.SendRequest("query_player_timer_box_data")
    M.BoxNodeList = box_node_list
    dump(M.Box,"<color=red>宝箱注册开始</color>")
    --测试代码
    -- for i = 1,4 do
    --     local b = SysBoxItem.Create({parent = M.BoxNodeList[i],data = {
    --         index = i,
    --         box_id = i,
    --     },
    --         update_func = {}
    --     })
    -- end
end

function M.GetBoxConfigByID(box_id)
    for i = 1,#M.config.base do
        if M.config.base[i].box_id == box_id then
            return M.config.base[i]
        end
    end
end

function M.GetAwardConfigByID(award_id)
    for i = 1,#M.config.award do
        if M.config.award[i].award_id == award_id then
            return M.config.award[i]
        end
    end
end

function M.on_query_player_timer_box_data_response(_,data)
    M.DeleteBox()
    dump(data,"<color=red>on_query_player_timer_box_data_response</color>")
    if data.result == 0 then
        M.box_data = data.box_data
        if not SysMatchPanel.GetInstance() then return end
        for i = 1,#data.box_data do
            local b = SysBoxItem.Create({parent = M.BoxNodeList[data.box_data[i].pos_id],data = {
                index = data.box_data[i].pos_id,
                box_id = data.box_data[i].box_id,
            },
                update_func = {}
            ,all_data = data.box_data[i]
            })
            M.BoxItems = M.BoxItems or {}
            M.BoxItems[#M.BoxItems + 1] = b
        end
    end
end

function M.on_timer_box_data_change(_,data)
    dump(data,"<color=red>on_timer_box_data_change</color>")
    if not SysMatchPanel.GetInstance() then 
        M.box_data = data.box_data
        return 
    end
    for k,v in pairs(data.box_data) do
        if not M.box_data[k] then
            local b = SysBoxItem.Create({parent = M.BoxNodeList[v.pos_id],data = {
                index = v.pos_id,
                box_id = v.box_id,
            },
                update_func = {}
            ,all_data = v
            })
            M.BoxItems = M.BoxItems or {}
            M.BoxItems[#M.BoxItems + 1] = b
        end
    end
    M.box_data = data.box_data
end

function M.IsCanOpenByTime()
    if M.box_data then
        for i = 1,#M.box_data do
            if M.box_data[i].start_time then
                return false
            end
        end
    end
    return true
end

function M.IsEnough()
    if M.box_data then
        return #M.box_data >= 4
    end
    return false
end

function M.GetDataByPos(pos)
    for i = 1,#M.box_data do
        if M.box_data[i].pos_id == pos then
            return M.box_data[i]
        end
    end
end

function M.DeleteBox()
    M.BoxItems = M.BoxItems or {}
    for i = 1,#M.BoxItems do
        M.BoxItems[i]:MyExit()
    end
    M.BoxItems = {}
end