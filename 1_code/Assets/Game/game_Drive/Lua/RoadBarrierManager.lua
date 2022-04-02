-- 创建时间:2021-02-01
-- 游戏的路障 管理器
RoadBarrierManager = {}

ext_require("Game.game_Drive.Lua.RoadBarrierBase")
ext_require("Game.game_Drive.Lua.RoadBarrierTimeBomb")
ext_require("Game.game_Drive.Lua.RoadBarrierRedLamp")
ext_require("Game.game_Drive.Lua.RoadBarrierDHQ")
ext_require("Game.game_Drive.Lua.RoadBarrierTrapForbid")
ext_require("Game.game_Drive.Lua.RoadBarrierLandmine")
ext_require("Game.game_Drive.Lua.RoadBarrierCarLamdmine")
ext_require("Game.game_Drive.Lua.RoadBarrierCarBigLandmine")
local M = RoadBarrierManager

M.act_enum = {
	create = 1,
	dead = 2,
}

local barrier_type_map = {
    dilei = {
        name = "地雷",
        class_type = "RoadBarrierLandmine"
    },
    luzhang = {
        name = "拦截路障",
        class_type = "RoadBarrierBase"
    },
    leibao = {
        name = "雷暴",
        class_type = "RoadBarrierBase"
    },
    dingshi_zhadan = {
        name = "定时炸弹",
        class_type = "RoadBarrierTimeBomb"
    },
    hongdeng = {
        name = "红灯",
        class_type = "RoadBarrierRedLamp"
    },
    dao_hang_qi = {
        name = "导航器",
        class_type = "RoadBarrierDHQ" 
    },
    jinting_luzhang = {
        name = "禁停路障",
        class_type = "RoadBarrierTrapForbid"
    },
    dlc_level1_mine = {
        name = "地雷车地雷Lv1",
        class_type = "RoadBarrierCarLamdmine",
        lv = 1,
    },
    dlc_level2_mine = {
        name = "地雷车地雷Lv2",
        class_type = "RoadBarrierCarLamdmine",
        lv = 2,
    },
    dlc_level3_mine = {
        name = "地雷车地雷Lv3",
        class_type = "RoadBarrierCarLamdmine",
        lv = 3,
    },
    dlc_big_mine = {
        name = "地雷车big地雷",
        class_type = "RoadBarrierCarBigLandmine",
    }
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
    listener["play_process_road_barrier_change"] = this.on_play_process_road_barrier_change
end

function M.Init()
    if not this then
        M.Exit()
        this = RoadBarrierManager
        this.road_barrier_map = {}
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
    
end

local convert_road_barrier_data = function(data)
    local barrier_data = basefunc.deepcopy(data)
    if barrier_type_map[data.type] then
        barrier_data.name = barrier_type_map[data.type].name
        barrier_data.class_type = barrier_type_map[data.type].class_type
        barrier_data.lv = barrier_type_map[data.type].lv
    end
    barrier_data.owner_type = data.owner_data.owner_type
    barrier_data.owner_id = data.owner_data.owner_id
    barrier_data.type = data.type
    return barrier_data
end

function M.AddRoadBarrier(data)
    local barrier_data = convert_road_barrier_data(data)
    this.road_barrier_map = this.road_barrier_map or {}
    if barrier_data.road_id then
        if barrier_data.class_type then
            this.road_barrier_map[barrier_data.no] = _G[barrier_data.class_type].Create(barrier_data)
        else
            this.road_barrier_map[barrier_data.no] = RoadBarrierBase.Create(barrier_data)
        end
    end
end

function M.RemoveRoadBarrier(no)
    if not this.road_barrier_map then return end
    local road_barrier = this.road_barrier_map[no]
    if road_barrier then
        local barrier_data = this.road_barrier_map[no].road_barrier_data
        if barrier_data and barrier_data.road_id then
            this.road_barrier_map[barrier_data.no]:MyExit()
        end
    end

    this.road_barrier_map[no] = nil
end

function M.GetRoadBarrier(no)
    if not no or not this or not this.road_barrier_map then return end
    dump(this.road_barrier_map)
    return this.road_barrier_map[no]
end
function M.GetRoadBarrierByRoadId(road_id)
    for k,v in pairs(this.road_barrier_map) do
        if v.road_barrier_data.road_id == road_id then
            return v
        end
    end
end

function M.on_play_process_road_barrier_change(data)
    local rac  = data.road_barrier_change
    if rac.road_barrier_data and data.process_no then
        rac.road_barrier_data.process_no = data.process_no
    end
    if rac.data_type == M.act_enum.create then
        M.AddRoadBarrier(rac.road_barrier_data)
    elseif rac.data_type == M.act_enum.dead then
        if rac.release_skill_id then
            local skill_class = _G[SkillManager.GetSkillCfgById(rac.release_skill_id).class_name]
            if skill_class and skill_class.CloseRoadBarrier then
                skill_class.CloseRoadBarrier(this.GetRoadBarrier(rac.road_barrier_data.no),function()
                    this.RemoveRoadBarrier(rac.road_barrier_data.no)
                end)
            end
        elseif rac.reason == "replace" then
            this.RemoveRoadBarrier(rac.road_barrier_data.no)
            Event.Brocast("process_play_next")
            return
        else
            M.RemoveRoadBarrier(rac.road_barrier_data.no)
        end
    end
    Event.Brocast("process_play_next")
end

function M.Refresh()
    if not DriveModel.data or not DriveModel.data.map_data then return end
    local road_barrier_datas = DriveModel.data.map_data.map_barrier
    if not road_barrier_datas or not next(road_barrier_datas) then return end
    for k,v in pairs(road_barrier_datas) do
        local road_barrier = M.GetRoadBarrier(v.no)
        if road_barrier then
            road_barrier:Refresh(v)
        else
            this.RemoveRoadBarrier(v.no)
            this.AddRoadBarrier(v)
        end
    end
end

function M.ClearMap()
    for k,v in pairs(this.road_barrier_map) do
        if v then
            this.RemoveRoadBarrier(k)
        end
    end
end