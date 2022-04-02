RoadAwardManager = {}
local M = RoadAwardManager
local drive_road_award_config
local drive_game_car_and_skill_server = ext_require("Game.game_Drive.Lua.drive_game_car_and_skill_server")
ext_require("Game.game_Drive.Lua.RoadAwardBase")
ext_require("Game.game_Drive.Lua.RoadAwardNormal")
ext_require("Game.game_Drive.Lua.RoadAwardMapStart")
ext_require("Game.game_Drive.Lua.RoadAwardMapBig")
ext_require("Game.game_Drive.Lua.RoadAwardCenterAttack")
ext_require("Game.game_Drive.Lua.RoadAwardCenterRemodel")
ext_require("Game.game_Drive.Lua.RoadAwardCenterRadar")
ext_require("Game.game_Drive.Lua.RoadAwardNull")

--服务器上的双倍奖励表
local can_double_award = {
    [55] = true ,         --道具箱
    [56] = true ,              --车辆升级
    [1] = true ,         -- 1-6是加血加攻加圈数
    [2] = true ,         -- n2o在油门里单独处理
    [3] = true ,
    [4] = true ,
    [5] = true ,
    [6] = true ,
  }
  
  local can_double_award_type_id_to_award_extra_num_name = {
    [1] = "sp_award_extra_num" ,
    [2] = "sp_award_extra_num" ,
    [3] = "at_award_extra_num" ,
    [4] = "at_award_extra_num" ,
    [5] = "hp_award_extra_num" ,
    [6] = "hp_award_extra_num" ,
    [7] = "small_daodan_award_extra_num" ,
    [8] = "small_daodan_award_extra_num" ,
    [36] = "n2o_award_extra_num" ,
    [37] = "n2o_award_extra_num" ,
    [55] = "tool_award_extra_num" ,
    [56] = "car_award_extra_num" ,
}

local double_award_keys = {
    sp_award_extra_num = "sp_award_extra_num",
    at_award_extra_num = "at_award_extra_num",
    hp_award_extra_num = "hp_award_extra_num",
    small_daodan_award_extra_num = "small_daodan_award_extra_num",
    n2o_award_extra_num = "n2o_award_extra_num",
    tool_award_extra_num = "tool_award_extra_num",
    car_award_extra_num = "car_award_extra_num"
}

M.award_type = {
    normal = "normal",
    start = "start",
    big = "big",
    gj_center = "gj_center",
    gz_center = "gz_center",
    radar_center = "radar_center",
}

M.award_type_class = {
    normal = "RoadAwardNormal",
    start = "RoadAwardMapStart",
    big = "RoadAwardMapBig",
    gj_center = "RoadAwardCenterAttack",
    gz_center = "RoadAwardCenterRemodel",
    radar_center = "RoadAwardCenterRadar",
}

M.act_enum = {
	create = 1,
	dead = 2,
	trigger = 3,
}

local this
local listener

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
    listener["play_process_road_award_change"] = this.on_play_process_road_award_change
end

function M.Init()
    if not this then
        M.Exit()
        this = RoadAwardManager
        this.road_award_map = {}
        drive_road_award_config = SysCarUpgradeManager.drive_road_award_config
        MakeListener()
        AddListener()
        M.InitConfig()
        M.Refresh()
    end
end

function M.Exit()
    RemoveLister()
    if this then
        this.ClearMap()
    end
    this = nil
end

function M.InitConfig()
    this.config = {}
    this.config.road_award_config = drive_road_award_config.main
    for i,v in ipairs(this.config.road_award_config) do
        for _i,_v in ipairs(drive_game_car_and_skill_server.skill_base) do
            if v.id == _v.type_id then
                for k,skill_base_v in pairs(_v) do
                    if k ~= "id" then
                        v[k] = skill_base_v
                    end
                end
            end
        end
    end
    local road_award_config = {}
    for i,v in ipairs(this.config.road_award_config) do
        if v.type_id then
            road_award_config[v.type_id] = v
        else
            road_award_config[v.id] = v
        end
    end
    this.config.road_award_config = road_award_config
    dump(this.config.road_award_config,"<color=white>road_award_config</color>")
end

function M.GetRoadAwardCfgByTypeId(type_id)
    if not type_id then return end
    if not this or not this.config or not this.config.road_award_config then return end
    return this.config.road_award_config[type_id]
end

function M.Refresh()
    if not DriveModel.data or not DriveModel.data.map_data then return end
    dump(DriveModel.data.map_data.map_award,"<color=white>刷新地图奖励 map_award</color>")
    ---创建通用的map底
    if not this.road_award_null_map then
        this.road_award_null_map = {}
        for i = 1,DriveMapManager.map_count do 
            this.road_award_null_map[i] = RoadAwardNull.Create({road_id = i})
        end
    end
    local road_award_datas = DriveModel.data.map_data.map_award
    if not road_award_datas or not next(road_award_datas) then return end
    local c2s_road_award_datas = {}
    for k,v in pairs(road_award_datas) do
        M.RefreshRoadAward(v)
        c2s_road_award_datas[v.road_id] = v
    end
    for road_id,road_awards in pairs(this.road_award_map) do
        if not c2s_road_award_datas[road_id] then
            for type_id,road_award in pairs(road_awards) do
                road_award:MyExit()
            end
            if this.road_award_null_map and this.road_award_null_map[road_id] then
                this.road_award_null_map[road_id]:SetBgImg()
            end
        end
    end
    --获取双倍奖励数据
    local cur_player
    for seat_num,player_info in ipairs(DriveModel.data.players_info) do 
        if player_info.player_op then
            cur_player = seat_num
            break
        end
    end
    if cur_player then
        local cur_cars = DriveCarManager.GetCarBySeat(cur_player)
        local cur_car = cur_cars[next(cur_cars)]
        cur_car.car_data.double_award = false
        for k,v in pairs(double_award_keys) do
            if v and cur_car.car_data[v] then
                --清空
                cur_car.car_data[v] = 1
            end
        end
        local double_award_modify_map = {}
        if cur_car.car_data.buff_datas then
            for _,buff_data in ipairs(cur_car.car_data.buff_datas) do
                if buff_data.other_data then
                    local check_key
                    for k,v in ipairs(buff_data.other_data) do 
                        if double_award_keys[v.value] then
                            check_key = double_award_keys[v.value]
                        end
                        if v.key == "modify_value" and check_key then
                            local cur_car_data = cur_car.car_data
                            cur_car_data[check_key] = cur_car_data[check_key] or 1
                            cur_car_data[check_key] = cur_car_data[check_key] + tonumber(v.value)
                            check_key = nil
                        end
                        if v.key == "tag_name" and v.value == "double_award" then
                            cur_car.car_data.double_award = true
                        end
                    end 
                end
            end
        end
        local extra_flag = false
        for road_id,road_awards in pairs(this.road_award_map) do
            if road_awards and next(road_awards) then
                for type_id,road_award in pairs(road_awards) do
                    road_award:ClearDoubleAward()
                    local extra_num_name = can_double_award_type_id_to_award_extra_num_name[type_id]
                    local extra_value = 1
                    if extra_num_name then
                        local cur_car_data = cur_car.car_data
                        if cur_car.car_data[extra_num_name] and cur_car.car_data[extra_num_name] > 0 then
                            extra_value = cur_car.car_data[extra_num_name]
                        end
                    end
                    local is_double_award = cur_car.car_data.double_award
                    if is_double_award and can_double_award[type_id] then
                        extra_value = extra_value + 1
                    end
                    if extra_value > 1 then
                        extra_flag = true
                        road_award:CreateDoubleAward(extra_value)
                    end
                end
            end
        end
        if extra_flag then
            AudioManager.PlaySound(audio_config.drive.com_main_map_shuangbeika.audio_name)
        end
    end
end

function M.AddRoadAward(road_award_data,create_cbk)
    local create_type = M.GetRoadAwardCreateType(road_award_data)
    if create_type then
        local road_id = road_award_data.road_id
        local type_id = road_award_data.type_id
        this.road_award_map = this.road_award_map or {}
        this.road_award_map[road_id] = this.road_award_map[road_id] or {}
        this.road_award_map[road_id][type_id] = create_type.Create(road_award_data,create_cbk)
    end
end

function M.RemoveRoadAward(road_award_data,play_next)
    if not road_award_data or not next(road_award_data) then return end
    local road_award = M.GetRoadAward(road_award_data)
    if not road_award then return end
    road_award:MyExit(play_next)
    local road_id = road_award_data.road_id
    local type_id = road_award_data.type_id
    this.road_award_map[road_id][type_id] = nil
    if this.road_award_null_map and this.road_award_null_map[road_id] then
        this.road_award_null_map[road_id]:SetBgImg()
    end
end

function M.RefreshRoadAward(road_award_data)
    local road_award = M.GetRoadAward(road_award_data)
    if road_award then
        road_award:Refresh(road_award_data)
    else
        M.AddRoadAward(road_award_data)
    end
end

function M.Clear()
    if this.road_award_null_map then
        for k,v in pairs(this.road_award_null_map) do 
            if v then v:MyExit() end
        end
        this.road_award_null_map = nil
    end
    for k,v in pairs(this.road_award_map or {}) do
        for _k,_v in pairs(v) do 
            if _v and _v.MyExit then
                _v:MyExit()
                _v = nil
            end
        end
    end
    this.road_award_map = {}
    -- dump(debug.traceback(),"<color=yellow>清除road_award_map</color>")
end

function M.ClearMap()
    for k,v in pairs(this.road_award_map) do
        if v then
            M.RemoveRoadAward(v)
        end
    end
end

function M.GetRoadAward(road_award_data)
    if not road_award_data then return end
    if not this.road_award_map then return end
    if not next(this.road_award_map) then return end
    local road_id = road_award_data.road_id
    local type_id = road_award_data.type_id
    if not this.road_award_map[road_id] or not next(this.road_award_map[road_id]) then return end
    if not type_id then 
        return this.road_award_map[road_id][next(this.road_award_map[road_id])]
    end
    if not this.road_award_map[road_id][type_id] or not next(this.road_award_map[road_id][type_id]) then return end
    return this.road_award_map[road_id][type_id]
end

function M.GetRoadAwardCreateType(road_award_data)
    local road_award_class = _G[M.award_type_class[road_award_data.road_award_type]]
    road_award_class = road_award_class or _G["RoadAwardNormal"]
    return road_award_class
end

function M.on_play_process_road_award_change(data)
    local rac = data.road_award_change
    if rac.data_type == M.act_enum.create then
        M.RefreshRoadAward(rac.road_award_data)
        Event.Brocast("process_play_next")
    elseif rac.data_type == M.act_enum.trigger then
        M.RefreshRoadAward(rac.road_award_data)
        local road_award = this.GetRoadAward(rac.road_award_data)
        if road_award then
            road_award:OnTrigger(data)
        end
    elseif rac.data_type == M.act_enum.dead then
        M.RefreshRoadAward(rac.road_award_data)
        M.RemoveRoadAward(rac.road_award_data,true)
        Event.Brocast("process_play_next")
    end
end

function M.SetAwardBg(road_id,icon_img)
    if not icon_img then return end
    if this.road_award_null_map and this.road_award_null_map[road_id] then
        this.road_award_null_map[road_id]:SetBgImg(icon_img)
    end
end