-- 创建时间:2021-06-09
-- SysAssetController 物品管理器

local basefunc = require "Game/Common/basefunc"
SysAssetController = {}
local M = SysAssetController
M.key = "sys_asset"
M.item_config = GameModuleManager.ExtLoadLua(M.key, "item_config")

GameModuleManager.ExtLoadLua(M.key,"SysAssetModel")
GameModuleManager.ExtLoadLua(M.key,"SysAssetGetView")

local this
local listener

local model = SysAssetModel
local assetGetView

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
    listener["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    listener["asset_get"] = this.on_asset_get
    listener["ExitScene"] = this.OnExitScene
    listener["EnterScene"] = this.OnEnterScene
end

function M.Init()
	M.Exit()

	this = SysAssetController
	this.m_data = {}
	MakeListener()
    AddListener()
    SysAssetModel.Init()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.on_asset_get(data)
    M.CheckAndShowAssetGet()
end

function M.CheckAndShowAssetGet()
    if model.IsAssetGetView() and not assetGetView then
        this.CreateItemGetView()
    end
end

function M.CreateItemGetView()
    local assetGetData = model.GetAssetGetViewData()
    assetGetView = SysAssetGetView.Create(assetGetData)
    model.RemoveAssetGetView()
end

function M.HandleAssetGetViewClose()
    assetGetView = nil
    M.CheckAndShowAssetGet()
end

function M.OnExitScene()
    SysAssetGetView.Close()
end

function M.OnEnterScene()
    M.CheckAndShowAssetGet()
end