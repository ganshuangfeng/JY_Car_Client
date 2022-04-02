-- 创建时间:2021-01-04
BuffManager = {}
local M = BuffManager
local drive_game_buff_server = ext_require("Game.game_Drive.Lua.drive_game_buff_server")
local drive_buff_config = ext_require("Game.game_Drive.Lua.drive_buff_config")
ext_require("Game.game_Drive.Lua.BuffBase")
ext_require("Game.game_Drive.Lua.BuffTankHead")
ext_require("Game.game_Drive.Lua.BuffModifyCarHit")
ext_require("Game.game_Drive.Lua.BuffModifyCarAtRange")
ext_require("Game.game_Drive.Lua.BuffModifyCarAt")
ext_require("Game.game_Drive.Lua.BuffModifyCarHpMax")
ext_require("Game.game_Drive.Lua.BuffModifyCarSp")
ext_require("Game.game_Drive.Lua.BuffTriggerCarMiss")
ext_require("Game.game_Drive.Lua.BuffModifyCarMiss")
ext_require("Game.game_Drive.Lua.BuffTriggerCarCrit")
ext_require("Game.game_Drive.Lua.BuffModifyCarCrit")
ext_require("Game.game_Drive.Lua.BuffTriggerCarBatter")
ext_require("Game.game_Drive.Lua.BuffNight")
ext_require("Game.game_Drive.Lua.BuffRain")
ext_require("Game.game_Drive.Lua.BuffInvicible")
ext_require("Game.game_Drive.Lua.BuffSuperPower")
ext_require("Game.game_Drive.Lua.BuffFanShang")
ext_require("Game.game_Drive.Lua.BuffReverse")
ext_require("Game.game_Drive.Lua.BuffDoubleAward")
ext_require("Game.game_Drive.Lua.BuffChangeTankPaodan")
ext_require("Game.game_Drive.Lua.BuffFaleliAddHit")
ext_require("Game.game_Drive.Lua.BuffChargeRestore")
ext_require("Game.game_Drive.Lua.BuffRedLamp")

M.act_enum = {
    create = 1,
    dead = 2,
    trigger = 3,
    refresh = 4,
}

M.status_enum = {
    create = 1,
    dead = 2,
    trigger = 3,
    refresh = 4,
}

local this
local listener

local function MakeListener()
    listener = {}
    listener["play_process_buff_create"] = this.on_play_process_buff_create
    listener["play_process_buff_dead"] = this.on_play_process_buff_dead
    listener["play_process_buff_change"] = this.on_play_process_buff_change
end

local function AddListener()
    for msg, cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if listener then
        for msg, cbk in pairs(listener) do
            Event.RemoveListener(msg, cbk)
        end
    end
    listener = nil
end

function M.Init()
    if not this then
        M.Exit()
        this = BuffManager
        this.m_data = {}
        MakeListener()
        AddListener()
        M.InitConfig()
        M.Refresh()
    end
end

function M.Exit()
    if this then
        RemoveLister()
        M.Clear()
        this.m_data = nil
    end
    this = nil
end

function M.InitConfig()
    this.config = {}
    this.config.drive_game_buff_server = drive_game_buff_server
    this.config.drive_buff_config = drive_buff_config
    this.config.buff_config = {}
    for i, v_main in pairs(drive_game_buff_server.main) do
        for k, v_arg in pairs(drive_game_buff_server.arg) do
            if v_arg.arg_id == v_main.id then
                v_main[v_arg.arg_type] = {}
                v_main[v_arg.arg_type] = v_arg
            end
        end
    end

    for i, v in ipairs(drive_buff_config.main) do
        this.config.buff_config[v.id] = v
    end

    for i, v_main in pairs(drive_game_buff_server.main) do
        for k, v in pairs(v_main) do
            if this.config.buff_config[v_main.id] then
                this.config.buff_config[v_main.id][k] = v
            end
        end
    end
    --modify_type 1:加减固定数值 2:加减百分比 3:设置数值
    dump(this.config.buff_config, "<color=white>buff_config</color>")
end

function M.GetBuffCfgById(buff_id)
    for k, v in pairs(this.config.buff_config) do
        if v.id == buff_id then
            return v
        end
    end
end

function M.AddBuff(buff_data)
    dump(buff_data,"<color=white>添加buff</color>")
    local buff_cfg = M.GetBuffCfgById(buff_data.buff_id)
    local buff_class = _G[buff_cfg.class_name]
    if not buff_class then
        buff_class = BuffBase
    end
    local buff_item = buff_class.Create(buff_data)
    local owner_type = buff_data.owner_type
    local owner_id = buff_data.owner_id
    local buff_id = buff_data.buff_id
    this.m_data.buff_map = this.m_data.buff_map or {}
    this.m_data.buff_map[owner_type] = this.m_data.buff_map[owner_type] or {}
    this.m_data.buff_map[owner_type][owner_id] = this.m_data.buff_map[owner_type][owner_id] or {}
    this.m_data.buff_map[owner_type][owner_id][buff_id] = buff_item
    return buff_item
end

--只从表中清除
function M.RemoveBuff(buff_data)
    local buff_item = M.GetBuff(buff_data)
    if not buff_item then
        return
    end
    local owner_type = buff_data.owner_type
    local owner_id = buff_data.owner_id
    local buff_id = buff_data.buff_id
    this.m_data.buff_map[owner_type][owner_id][buff_id] = nil
end

--只从表中清除并退出
function M.ClearBuff(buff_data)
    local buff_item = M.GetBuff(buff_data)
    if not buff_item then
        return
    end
    local owner_type = buff_data.owner_type
    local owner_id = buff_data.owner_id
    local buff_id = buff_data.buff_id
    this.m_data.buff_map[owner_type][owner_id][buff_id] = nil
    buff_item:MyExit()
end

function M.RefreshBuff(buff_data)
    local buff_item = M.GetBuff(buff_data)
    if buff_item then
        buff_item:Refresh(buff_data)
    else
        M.AddBuff(buff_data)
    end
end

function M.GetBuff(buff_data)
    local owner_type = buff_data.owner_type
    local owner_id = buff_data.owner_id
    local buff_id = buff_data.buff_id
    if this.m_data.buff_map and this.m_data.buff_map[owner_type] and this.m_data.buff_map[owner_type][owner_id] then
        return this.m_data.buff_map[owner_type][owner_id][buff_id]
    end
end

function M.GetAllBuff()
    return this.m_data.buff_map
end

function M.Refresh()
    if not DriveModel or not DriveModel.data then
        return
    end

    --刷新车上的buff
    local car_data = DriveModel.data.car_data
    for seat_num, seat_car_datas in ipairs(car_data or {}) do
        for car_no, v in ipairs(seat_car_datas or {}) do
            for i, bd in ipairs(v.buff_datas or {}) do
                local buff_data = {}
                --默认断线重连上来的buff在触发状态
                buff_data.status = M.status_enum.trigger
                buff_data.buff_id = bd.buff_id
                for k,v in pairs(bd.other_data or {}) do
                    local num = tonumber(v.value)
                    buff_data[v.key] = num and num or v.value
                end
                buff_data.owner_id = v.car_no
                buff_data.owner_type = DriveModel.OwnerType.car
                M.RefreshBuff(buff_data)
            end
        end
    end
end

function M.Clear()
    for owner_type, v in pairs(this.m_data.buff_map or {}) do
        for owner_id, v1 in pairs(v) do
            for buff_id, buff in pairs(v1) do
                buff:MyExit()
            end
        end
    end
    this.m_data.buff_map = {}
end

local convert_buff_data = function(data)
    local buff_data = {}
    local _data = data[data.key]
    buff_data = _data.buff_data
    buff_data.process_no = data.process_no
    buff_data.father_process_no = data.father_process_no
    for k,v in pairs(_data.other_data or {}) do
        local num = tonumber(v.value)
        buff_data[v.key] = num and num or v.value
    end
    buff_data.owner_id = _data.owner_data.owner_id
    buff_data.owner_type = _data.owner_data.owner_type
    buff_data.pos = _data.pos
    return buff_data
end

function M.on_play_process_buff_create(data)
    dump(data, "<color=white>创建buff??????????????????</color>")
    -- TipsShowUpText.Create("创建Buff".. this.config.buff_config[data[data.key].buff_id].name)
    local buff_data = convert_buff_data(data)
    buff_data.status = M.status_enum.create
    buff_data.act = M.act_enum.create
    M.RefreshBuff(buff_data)
    local buff_item = M.GetBuff(buff_data)
    if buff_item then
        buff_item:OnActStart()
    end
end

function M.on_play_process_buff_dead(data)
    dump(data, "<color=white>移除buff??????????????????</color>")
    -- TipsShowUpText.Create("移除Buff".. this.config.buff_config[data[data.key].buff_id].name)
    local buff_data = convert_buff_data(data)
    buff_data.status = M.status_enum.dead
    buff_data.act = M.act_enum.dead
    M.RefreshBuff(buff_data)
    local buff_item = M.GetBuff(buff_data)
    if buff_item then
        buff_item:OnActStart()
    end
    M.RemoveBuff(buff_data)
end

function M.on_play_process_buff_change(data)
    local buff_data = convert_buff_data(data)
    M.RefreshBuff(buff_data)
    buff_data.status = M.status_enum.refresh
    buff_data.act = M.act_enum.refresh
    M.RefreshBuff(buff_data)
    local buff_item = M.GetBuff(buff_data)
    if buff_item then
        buff_item:OnActStart()
    end
end