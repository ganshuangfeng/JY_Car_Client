-- 创建时间:2021-06-04
-- SysSettingController 管理器

local basefunc = require "Game/Common/basefunc"
SysSettingController = {}
local M = SysSettingController
M.key = "sys_setting"

GameModuleManager.ExtLoadLua(M.key,"SysSettingModel")
GameModuleManager.ExtLoadLua(M.key,"SysSettingView")

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
        return SysSettingView.Create(parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
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
    listener["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    listener["ExitScene"] = this.OnExitScene
end

function M.Init()
	M.Exit()

	this = SysSettingController
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

function M.OnExitScene()
    SysSettingView.Close()
end