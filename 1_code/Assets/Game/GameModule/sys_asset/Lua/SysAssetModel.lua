-- 创建时间:2021-06-09
-- SysAssetModel 管理器

local basefunc = require "Game/Common/basefunc"
SysAssetModel = {}
local M = SysAssetModel
M.key = "sys_asset"
local item_config = SysAssetController.item_config

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
    listener["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    listener["login_complete"] = M.on_login_complete
    listener["query_asset_response"] = this.on_query_asset
    listener["notify_asset_change_msg"] = this.on_notify_asset_change_msg
end

function M.Init()
	M.Exit()

	this = SysAssetModel
	this.m_data = {}
    this.assetCfg = {}
    this.assetData = {}
    this.assetGetData = {}
	MakeListener()
    AddListener()
    M.InitConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitConfig()
    for k,v in pairs(item_config.config) do
        this.assetCfg[v.item_key] = v
    end
end

--更新玩家资产
local function UpdateAssetData(player_asset)
    for k,v in pairs(player_asset) do
        if not this.assetData[v.asset_type] then
            this.assetData[v.asset_type] = {}
        end
        this.assetData[v.asset_type].asset_value = tonumber(v.asset_value)
        this.assetData[v.asset_type].attribute = v.attribute
    end
    dump(this.assetData, "<color=white>资产数据Data</color>")

    for k,v in pairs(this.assetData) do
        MainModel.UserInfo[k] = v.asset_value
    end

    Event.Brocast("asset_change", player_asset)
end

--更新资产获得
local function UpdateAssetGetData(_assetGetData)
    if table_is_null(_assetGetData) then
        return
    end
    dump(_assetGetData, "<color=white>资产获得</color>")
    this.assetGetData[#this.assetGetData + 1] = _assetGetData
    dump(this.assetGetData, "<color=white>资产获得Data</color>")
    Event.Brocast("asset_get", _assetGetData)
end

--改变资产
local function ChangeAssetData(change_asset)
    local _assetGetData = {}
    for k,v in ipairs(change_asset) do
        if not this.assetData[v.asset_type] then
            this.assetData[v.asset_type] = {}
            this.assetData[v.asset_type].asset_value = 0
        end
        local changeValue = tonumber(v.asset_value)
        this.assetData[v.asset_type].asset_value = this.assetData[v.asset_type].asset_value + changeValue
        if changeValue > 0 then
            _assetGetData[#_assetGetData + 1] = {}
            _assetGetData[#_assetGetData].asset_type = v.asset_type
            _assetGetData[#_assetGetData].asset_value = changeValue
        end
    end
    Event.Brocast("asset_change", change_asset)
    dump(change_asset, "<color=white>资产改变Data</color>")
    UpdateAssetGetData(_assetGetData)
end

function M.GetItemConfig(key)
    if this.assetCfg[key] then
        return this.assetCfg[key]
    end
end

function M.GetItemData(item_key)
    if this.assetData[item_key] then
        return this.assetData[item_key]
    end
end

function M.GetItemCount(item_key)
    if this.assetData[item_key] then
        return this.assetData[item_key].asset_value
    end
    return 0
end

function M.GetItemImage(item_key)
    if this.assetCfg[item_key] then
        return this.assetCfg[item_key].image
    end
end

function M.IsAssetGetView()
    if not table_is_null(this.assetGetData) then
        return true
    end
end

function M.GetAssetGetViewData()
    return this.assetGetData[#this.assetGetData]
end

function M.RemoveAssetGetView()
    this.assetGetData[#this.assetGetData] = nil
end

function M.on_login_complete()
    this.query_asset_index = 1
    Network.SendRequest("query_asset", {index = this.query_asset_index})
    dump("<color=green>Network.SendRequest(query_asset)</color>")
end

function M.on_query_asset(_, data)
    dump(data, "<color=white>资产更新</color>")
    if data.result ~= 0 then
        return
    end

    if not table_is_null(data.player_asset) then
        UpdateAssetData(data.player_asset)
    end
end

local not_show_type = {
    open_timer_box_award = "open_timer_box_award",
    new_user_logined_award = "new_user_logined_award",
}

function M.on_notify_asset_change_msg(_, data)
    dump(data, "<color=white>资产改变</color>")
    if not_show_type[data.type] then
        return
    end

    if not table_is_null(data.change_asset) then
        ChangeAssetData(data.change_asset)
    end
end