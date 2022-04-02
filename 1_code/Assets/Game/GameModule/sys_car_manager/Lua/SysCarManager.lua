-- 创建时间:2020-10-26
-- SysCarManager 管理器

local basefunc = require "Game/Common/basefunc"
SysCarManager = {}
local M = SysCarManager
M.key = "sys_car_manager"
GameModuleManager.ExtLoadLua(M.key,"CarShow")
local drive_car_config = GameModuleManager.ExtLoadLua(M.key,"drive_car_config")
local drive_map_config = GameModuleManager.ExtLoadLua(M.key,"drive_map_config")

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
    listener["query_drive_car_data_response"] = this.on_query_drive_car_data_response
    listener["model_drive_car_data_change"] = this.on_drive_car_data_change
    listener["login_complete"] = this.on_login_complete
end

function M.Init()
	M.Exit()

	this = SysCarManager
	this.m_data = {}
	MakeListener()
    AddListener()
	M.InitConfig()
    M.set_cur_car_id()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitConfig()
    this.config = {}
    this.config.car_config = {}
    for id,car_data in ipairs(drive_car_config.car_config) do
        this.config.car_config[car_data.id] = basefunc.deepcopy(car_data)
        this.config.car_config[car_data.id].move_config = {}
        this.config.car_config[car_data.id].move_config.big_youmen = drive_car_config.move_config[car_data.big_youmen]
        this.config.car_config[car_data.id].move_config.small_youmen = drive_car_config.move_config[car_data.small_youmen]
        this.config.car_config[car_data.id].move_config.sprint = drive_car_config.move_config[car_data.sprint]
        this.config.car_config[car_data.id].move_config.ptg_big_youmen = drive_car_config.move_config[car_data.ptg_big_youmen]
        this.config.car_config[car_data.id].move_config.ptg_attack = drive_car_config.move_config[car_data.ptg_attack]
        this.config.car_config[car_data.id].move_config.dlc_anzhuang_move = drive_car_config.move_config[car_data.dlc_anzhuang_move]

        this.config.car_config[car_data.id].image_config = drive_car_config.image_config[car_data.image_config]
    end

    this.config.map_config = {}
    for k,v in pairs(drive_map_config.map_config) do
        this.config.map_config[v.id] = v
    end
    this.config.map_asset = drive_map_config.map_asset
    this.config.map_string = drive_map_config.map_string
    this.config.map_color = drive_map_config.map_color

    dump(this.config,"<color=red>SysCarManager 所有配置数据</color>")
end

function M.GetCarCfg(parm)
    local car_type_id = parm.car_type_id
    return this.config.car_config[car_type_id]
end

function M.GetMoveCfg(config_id)
    for k,v in ipairs(drive_car_config.move_config) do
        if v.index == config_id then return v end 
    end
end

function M.GetDefaultCarId()
    return UnityEngine.PlayerPrefs.GetInt("default_car_id" .. MainModel.UserInfo.user_id,1)
end

function M.SetDefaultCarId()
    UnityEngine.PlayerPrefs.SetInt("default_car_id" .. MainModel.UserInfo.user_id,this.car_id)
end

function M.GetDefaultCarStar()
    return UnityEngine.PlayerPrefs.GetInt("default_car_star" .. MainModel.UserInfo.user_id,0)
end

function M.SetDefaultCarStar()
    UnityEngine.PlayerPrefs.SetInt("default_car_star" .. MainModel.UserInfo.user_id,this.car_star)
end

function M.set_cur_car_id(cur_car_id)
    dump(cur_car_id,"<color=yellow>当前车辆设置？？？？？</color>")
    cur_car_id = cur_car_id or M.GetDefaultCarId()
    if this.car_id and this.car_id == cur_car_id then
        --相同的车辆不变
        return
    end
    if this.car_id then
        --客户端出战车辆改变
        Event.Brocast("client_cur_car_change",{car_id = cur_car_id})
    end
    this.car_id = cur_car_id
    this.car_star = M.GetDefaultCarStar()
    Network.SendRequest("query_drive_car_data",{car_id = this.car_id})
    M.SetDefaultCarId()
end

function M.on_query_drive_car_data_response(_,data)
    dump(data,"<color=yellow>车辆详细数据？？？？？？？</color>")
    if data.result ~= 0 then
        TipsShowUpText.Create(errorCode[data.result])
        return
    end
    this.cur_car_data = this.cur_car_data or {}
    this.cur_car_data[data.base_data.car_id] = data
    this.car_star = data.base_data.star or M.GetDefaultCarStar()
    M.SetDefaultCarStar()
end

function M.on_drive_car_data_change(data)
    if not data or not data.base_data then return end
    this.cur_car_data = this.cur_car_data or {}
    this.cur_car_data[data.base_data.car_id] = data

    if this.car_id ~= data.base_data.car_id then return end
    this.car_star = data.base_data.star
    M.SetDefaultCarStar()
end

function M.GetCurCar()
    local car_data = {car_id = this.car_id,car_star = this.car_star}
    if this.cur_car_data and next(this.cur_car_data) then
        car_data.car_data = this.cur_car_data[this.car_id]
    end
    dump(car_data,"<color=yellow>当前出战车辆？？？</color>")
    return car_data
end

function M.GetCarTagByCarId(car_id)
    local car_cfg = this.config.car_config[car_id]
    if not car_cfg or not next(car_cfg) then return "" end
    return car_cfg.tag_name
end

M.map_id = 3

function M.GetMapAssets(key)
    if not this.config.map_asset[key] then return key end
    local id = M.map_id 
    local s = this.config.map_asset[key]["id_" .. id]
    if not s then s = key end
    return s
end

function M.GetMapString(key)
    if not this.config.map_string[key] then return "%s" end
    local id = M.map_id 
    local s = this.config.map_string[key]["id_" .. id]
    if not s then s = "%s" end
    return s
end

function M.SetMapString(key,str)
    local mp_str = M.GetMapString(key)
    if not str then str = "" end
    return string.format(mp_str,str)
end

function M.GetMapColor(key)
    local color = Color.New(255, 255, 255, 255)
    if not this.config.map_color[key] then
        UnityEngine.ColorUtility.TryParseHtmlString("#000000FF",color)
        return color
    end
    local id = M.map_id 
    local s = this.config.map_color[key]["id_" .. id]
    if not s then s =  "#000000FF" end
    local b,c = UnityEngine.ColorUtility.TryParseHtmlString(s,color)
    return c
end

function M.GetDriveMapConfig()
    return drive_map_config
end

local b
function M.on_login_complete(data)
    if b then return end
    local parent = GameObject.Find("GameManager").transform
    coroutine.start(function ( )
        for k,v in pairs(this.config.car_config) do
            for star=1,5 do
                -- 下一帧
                Yield(0)
                local obj =  newObject(v.car_name .. "_" .. star, parent)
                destroy(obj)
            end
        end
    end)

    coroutine.start(function ( )
        Yield(0)
        local obj = newObject("CarShowBG")
        destroy(obj)
        Yield(0)
        local obj = newObject("CarShow")
        destroy(obj)
    end)
    b = true
end