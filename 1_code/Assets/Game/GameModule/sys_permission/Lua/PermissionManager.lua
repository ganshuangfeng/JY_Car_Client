-- 创建时间:2019-11-29
-- PermissionManager 管理器

local basefunc = require "Game/Common/basefunc"
PermissionManager = {}
local M = PermissionManager
M.key = "sys_permission"
local cpm = GameModuleManager.ExtLoadLua(M.key, "common_permission_manager")

local this
local listener

TagVecKey = {
    tag_new_player = "tag_new_player", --- 新人用户
    tag_free_player = "tag_free_player", --- 免费
    tag_stingy_player = "tag_stingy_player", --- 小额用户
    tag_vip_low = "tag_vip_low", --- vip 1-2
    tag_vip_mid = "tag_vip_mid", --- vip 3-6
    tag_vip_high = "tag_vip_high", --- vip 7-10
}

-- 创建入口按钮时调用
function M.CheckIsShow(cfg)
    if not cfg.is_on_off or cfg.is_on_off == 0 then
        return
    end
    return true
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

    listener["global_sysqx_uichange_msg"] = this.on_global_sysqx_uichange_msg

    -- 权限管理相关消息
    listener["model_query_system_variant_data"] = this.query_system_variant_data
    listener["on_system_variant_data_change_msg"] = this.on_system_variant_data_change_msg
    listener["on_player_permission_error"] = this.on_player_permission_error
end

local tag_name = {
    tag_new_player = "新人用户", --- 新人用户
    tag_free_player = "免费", --- 免费
    tag_stingy_player = "小额用户", --- 小额用户
    tag_vip_low = "vip 1-2", --- vip 1-2
    tag_vip_mid = "vip 3-6", --- vip 3-6
    tag_vip_high = "vip 7-10", --- vip 7-10
}
function M.debug_test()
    if this.m_data.tag_vec_map then
        local desc = ""
        for k,v in pairs(this.m_data.tag_vec_map) do
            if tag_name[k] then
                desc = desc .. "\n" .. tag_name[k]
            end
        end
        return desc
    end
end

function M.Init()
    if not this then
        M.Exit()

        this = PermissionManager
        cpm.init(true)

        this.m_data = {}
        this.m_data.tag_vec_map = {} -- 标签map
        this.m_data.no_act_permission_map = {} -- 不能玩的活动
        MakeListener()
        AddListener()
        M.InitUIConfig()
    end
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig={
    }
end

function M.convert_variant_to_table( _data )
    local ret_vec = {}
    for key,data in pairs(_data) do
        local value_vec = basefunc.string.split( data.variant_value , ",")
        if value_vec then
            for _key,value in pairs(value_vec) do
                if data.variant_type == "string" then
                    value_vec[_key] = tostring( value )
                elseif data.variant_type == "number" then
                    value_vec[_key] = tonumber( value )
                end
            end
        end

        local ret = value_vec
        if data.variant_value_type == "table" then
            if not value_vec or #value_vec == 0 then
                ret = {}
            end
        end
        if data.variant_value_type == "value" then
            ret = value_vec and value_vec[1]
        end
        ret_vec[ data.variant_name ] = ret
  end
  
    -- 转成 map
    ret_vec.diff_act_permission_map = {}
    if ret_vec.diff_act_permission then
        for _,v in ipairs(ret_vec.diff_act_permission) do
            ret_vec.diff_act_permission_map[v] = true
        end
    end

    return ret_vec
end

function M.query_system_variant_data(_, data)
    dump(data, "<color=red>SYS QX query_system_variant_data</color>")
    if data.result == 0 then
        this.m_data.permission_data = M.convert_variant_to_table(data.variant_data)
        if this.m_data.permission_data.tag_vec then
            this.m_data.tag_vec_map = this.m_data.tag_vec_map or {}
            local ll = {}
            for k,v in pairs(this.m_data.tag_vec_map) do
                ll[#ll + 1] = k
            end
            for k,v in ipairs(ll) do
                this.m_data.tag_vec_map[v] = nil
            end
            for k,v in ipairs(this.m_data.permission_data.tag_vec) do
                this.m_data.tag_vec_map[v] = 1
            end
        end
        dump(this.m_data.tag_vec_map)
        if this.m_data.permission_data.no_act_permission then
            this.m_data.no_act_permission_map = this.m_data.tag_vec_map or {}
            for k,v in ipairs(this.m_data.permission_data.no_act_permission) do
                this.m_data.no_act_permission_map[v] = 1
            end
        end
    end
end
function M.on_system_variant_data_change_msg(_, data)
    dump(data, "<color=red>SYS QX on_system_variant_data_change_msg</color>")
    this.m_data.permission_data = M.convert_variant_to_table(data.variant_data)
    if this.m_data.permission_data.tag_vec then
        this.m_data.tag_vec_map = this.m_data.tag_vec_map or {}
        local ll = {}
        for k,v in pairs(this.m_data.tag_vec_map) do
            ll[#ll + 1] = k
        end
        for k,v in ipairs(ll) do
            this.m_data.tag_vec_map[v] = nil
        end
        for k,v in ipairs(this.m_data.permission_data.tag_vec) do
            this.m_data.tag_vec_map[v] = 1
        end
        dump(this.m_data.tag_vec_map)
        if this.m_data.permission_data.no_act_permission then
            this.m_data.no_act_permission_map = {}
            for k,v in ipairs(this.m_data.permission_data.no_act_permission) do
                this.m_data.no_act_permission_map[v] = 1
            end
        end
    end
    Event.Brocast("client_system_variant_data_change_msg")
end
function M.on_player_permission_error(_, data)
    dump(data, "<color=red>SYS QX on_player_permission_error</color>")
    HintPanel.Create(1, data.error_desc, function ()
        -- 门槛相关逻辑
        if MainModel.myLocation == "game_DdzFree"
            or MainModel.myLocation == "game_DdzPDK"
            or MainModel.myLocation == "game_Mj3D"
            or MainModel.myLocation == "game_Gobang"
            or MainModel.myLocation == "game_LHD" then
    
            local huiqu
            if MainModel.lastmyLocation then
                huiqu = MainModel.lastmyLocation
            else
                huiqu = "game_Hall"
            end
            GameManager.Goto({_goto = huiqu})
        end
    end)
end

function M.get_tag_vec_map()
    return M.m_data.tag_vec_map
end

-- 检查条件或权限
function M.CheckCondition(parm)
    local _permission_key
    local is_on_hint
    if type(parm) == "table" then
        _permission_key = parm._permission_key
        is_on_hint = parm.is_on_hint
    end
    if this.m_data.permission_data and _permission_key then
        local a,b = cpm.judge_permission_effect_client(_permission_key, this.m_data.permission_data)
        if b then
            -- 是不是 不要提示(调用的地方自己处理)
            if not is_on_hint then
                GameManager.Goto({_goto="vip", goto_scene_parm="hint", data={desc=b,type = parm.vip_hint_type,cw_btn_desc = parm.cw_btn_desc}})
            end
        end
        return a
    else
        -- print("<color=red>CheckCondition data nil 检查条件或权限  数据为空</color>")
        return true
    end
end

-- 权限相关界面修改
-- Event.Brocast("global_sysqx_uichange_msg", {key="", panelSelf=self})
-- key
function M.on_global_sysqx_uichange_msg(parm)
    -- 测试
    -- this.m_data.tag_vec_map[TagVecKey.tag_new_player] = nil
    -- this.m_data.tag_vec_map[TagVecKey.tag_free_player] = 1
    if ADManager.IsCloseAD() then
        return
    end

    if parm and parm.key then
    end
end

function M.GetRegressTime()
    if this.m_data and this.m_data.permission_data then 
        return this.m_data.permission_data["regress_time"]
    end 
end 

function M.IsNeedWatchAD()
    -- return this.m_data.tag_vec_map[TagVecKey.tag_free_player]
    -- 运营需求：广告权限判定修改-CPL渠道 2020/5/26
    return M.CheckCondition({_permission_key="need_watch_ad", is_on_hint=true})
end

function M.CheckIsWQP()
    local mp = gameMgr:getMarketPlatform()
    if not mp or mp ~= "wqp" then return end
    return true
end

function M.Debug(key)
    local a,b = cpm.judge_permission_effect_client(key, this.m_data.permission_data)
    dump(this.m_data.permission_data , "xxx-----------------this.m_data.permission_data")
    print("<color=red>++++++++++++ permission_key ++++++++++++</color>")
    dump(a)--结果
    dump(b)--错误码
end
--@PermissionManager.Debug("actp_buy_gift_bag_class_golden_egg_1")