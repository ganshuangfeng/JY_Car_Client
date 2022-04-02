-- 创建时间:2021-01-04
SkillManager = {}
local M = SkillManager
local drive_skill_config = ext_require("Game.game_Drive.Lua.drive_skill_config")
local drive_game_skill_server = ext_require("Game.game_Drive.Lua.drive_game_skill_server")
ext_require("Game.game_Drive.Lua.DriveSkillBuffContainer")
ext_require("Game.game_Drive.Lua.SkillBase")
ext_require("Game.game_Drive.Lua.SkillBuffBase")
ext_require("Game.game_Drive.Lua.SkillAwardBomb")
ext_require("Game.game_Drive.Lua.SkillAddHp")
ext_require("Game.game_Drive.Lua.SkillAddAttack")
ext_require("Game.game_Drive.Lua.SkillAddSpeed")
ext_require("Game.game_Drive.Lua.SkillLandmine")
ext_require("Game.game_Drive.Lua.SkillAgain")
ext_require("Game.game_Drive.Lua.SkillDash")
ext_require("Game.game_Drive.Lua.SkillHeadWuling")
ext_require("Game.game_Drive.Lua.SkillFaleliHead")
ext_require("Game.game_Drive.Lua.SkillFaleliBody")
ext_require("Game.game_Drive.Lua.SkillTransfer")
ext_require("Game.game_Drive.Lua.SkillExchangeCar")
ext_require("Game.game_Drive.Lua.SkillSelectTransfer")
ext_require("Game.game_Drive.Lua.SkillCarSkillUp")
ext_require("Game.game_Drive.Lua.SKillSelectBarrier")
ext_require("Game.game_Drive.Lua.SkillTrap")
ext_require("Game.game_Drive.Lua.SkillFaleliBig")
ext_require("Game.game_Drive.Lua.SkillTankTail")
ext_require("Game.game_Drive.Lua.SkillTankBody")
ext_require("Game.game_Drive.Lua.SkillTankHead")
ext_require("Game.game_Drive.Lua.SkillTankBig")
--改造中心
ext_require("Game.game_Drive.Lua.SkillAddShield")
ext_require("Game.game_Drive.Lua.SkillAddChainsaw")
ext_require("Game.game_Drive.Lua.SkillAddGun")

ext_require("Game.game_Drive.Lua.SkillDFRocketHp")
ext_require("Game.game_Drive.Lua.SkillDFRocketGold")
ext_require("Game.game_Drive.Lua.SkillSlotCrit")
ext_require("Game.game_Drive.Lua.SkillSlotMiss")
ext_require("Game.game_Drive.Lua.SkillSlotDouble")
ext_require("Game.game_Drive.Lua.SkillEndOff")
ext_require("Game.game_Drive.Lua.SkillRain")
ext_require("Game.game_Drive.Lua.SkillThunder")
ext_require("Game.game_Drive.Lua.SkillNight")
ext_require("Game.game_Drive.Lua.SkillSun")
ext_require("Game.game_Drive.Lua.SkillPTGBig")
ext_require("Game.game_Drive.Lua.SkillPTGSmall")
ext_require("Game.game_Drive.Lua.SkillExchangeHp")
ext_require("Game.game_Drive.Lua.SkillClearTrap")
ext_require("Game.game_Drive.Lua.SkillTimeBomb")
ext_require("Game.game_Drive.Lua.SkillAddHpKit")
ext_require("Game.game_Drive.Lua.SkillTrapForbid")
ext_require("Game.game_Drive.Lua.SkillRedLamp")
ext_require("Game.game_Drive.Lua.SkillSystemRain")
ext_require("Game.game_Drive.Lua.SkillTrapMiss")
ext_require("Game.game_Drive.Lua.SkillSystemNight")
ext_require("Game.game_Drive.Lua.SkillAddTankBulletLimit")
ext_require("Game.game_Drive.Lua.SkillPTGStorage")
ext_require("Game.game_Drive.Lua.SkillDLCStorage")
ext_require("Game.game_Drive.Lua.SkillLandmineCarSmall")
ext_require("Game.game_Drive.Lua.SkillTransferRandom")
ext_require("Game.game_Drive.Lua.SkillHealAngel")
ext_require("Game.game_Drive.Lua.SkillCloneHp")
ext_require("Game.game_Drive.Lua.SkillAddBulletNum")
ext_require("Game.game_Drive.Lua.SkillReverse")
ext_require("Game.game_Drive.Lua.SkillSmallRocket")
ext_require("Game.game_Drive.Lua.SkillFanshang")
ext_require("Game.game_Drive.Lua.SkillAddHpExtra")
ext_require("Game.game_Drive.Lua.SkillAddSpeedExtra")
ext_require("Game.game_Drive.Lua.SkillAddAttackExtra")
ext_require("Game.game_Drive.Lua.SkillComplexBuff")
ext_require("Game.game_Drive.Lua.SkillLandmineCarBig")

M.act_enum = {
	create = 1,
	dead = 2,
    trigger = 3,
    change = 4,
}

M.status_enum = {
	create = 1,
	dead = 2,
	trigger = 3,
	change = 4,
}

local this
local listener

local function MakeListener()
    listener = {}
    listener["play_process_skill_create"] = this.on_play_process_skill_create
    listener["play_process_skill_trigger"] = this.on_play_process_skill_trigger
    listener["play_process_skill_dead"] = this.on_play_process_skill_dead
    listener["play_process_skill_change"] = this.on_play_process_skill_change
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

function M.Init()
    if not this then
        M.Exit()
        this = SkillManager
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
    this.config.skill_config = drive_skill_config.main
    for i,v in ipairs(this.config.skill_config) do
        if drive_game_skill_server.skill[v.id] then
            v.key = drive_game_skill_server.skill[v.id].key
            v.level = drive_game_skill_server.skill[v.id].level
        end
    end
end

function M.GetSkillCfgById(skill_id)
    for k,v in ipairs(this.config.skill_config) do
        if v.id == skill_id then
            return v
        end
    end
end

function M.AddSkill(skill_data)
    local skill_cfg = M.GetSkillCfgById(skill_data.skill_id)
    local skill_class = _G[skill_cfg.class_name]
    if not skill_class then 
        skill_class = SkillBase
    end
    local skill_item = skill_class.Create(skill_data)
    local owner_type = skill_data.owner_type
    local owner_id = skill_data.owner_id
    local skill_id = skill_data.skill_id
    this.m_data.skill_map = this.m_data.skill_map or {}
    this.m_data.skill_map[owner_type] = this.m_data.skill_map[owner_type] or {}
    this.m_data.skill_map[owner_type][owner_id] = this.m_data.skill_map[owner_type][owner_id] or {}
    this.m_data.skill_map[owner_type][owner_id][skill_id] = skill_item

    return skill_item
end

function M.RemoveSkill(skill_data)
    --这里只清空了表，没有把skill_item Exit掉
    local skill_item = M.GetSkill(skill_data)
    if not skill_item then return end
    local owner_type = skill_data.owner_type
    local owner_id = skill_data.owner_id
    local skill_id = skill_data.skill_id
    this.m_data.skill_map[owner_type][owner_id][skill_id] = nil
    -- skill_item:MyExit()
end

function M.ClearSkill(skill_data)
    local skill_item = M.GetSkill(skill_data)
    if not skill_item then return end
    local owner_type = skill_data.owner_type
    local owner_id = skill_data.owner_id
    local skill_id = skill_data.skill_id
    this.m_data.skill_map[owner_type][owner_id][skill_id] = nil
    skill_item:MyExit()
end

function M.RefreshSkill(skill_data)
    local skill_item = M.GetSkill(skill_data)
    if skill_item then
        skill_item:Refresh(skill_data)
    else
        M.AddSkill(skill_data)
    end
end

-- function M.debug_skill_map()
--     if this.m_data.skill_map then
--         for k,v in pairs(this.m_data.skill_map) do
--             for k,v in pairs(table_name) do
                
--             end
--         end
--     end
-- end

function M.GetSkill(skill_data)
    local owner_type = skill_data.owner_type
    local owner_id = skill_data.owner_id
    local skill_id = skill_data.skill_id

    if this.m_data.skill_map
    and this.m_data.skill_map[owner_type] 
    and this.m_data.skill_map[owner_type][owner_id] then
        return this.m_data.skill_map[owner_type][owner_id][skill_id]
    end
end

function M.GetSkillByOwner(owner_data)
    return this.m_data.skill_map[owner_data.owner_type][owner_data.owner_id]
end

function M.GetAllSkill()
    return this.m_data.skill_map
end

function M.Refresh()
    if not DriveModel or not DriveModel.data then return end

    --刷新车上的技能
    local car_data = DriveModel.data.car_data
    for seat_num,seat_car_datas in ipairs(car_data or {}) do
        for car_no,v in ipairs(seat_car_datas or {}) do
            for i,s_skill_data in ipairs(v.skill_datas or {}) do
                local skill_data = {}
                --默认断线重连上来的技能在触发状态
                skill_data.status = M.status_enum.trigger
                skill_data.process_no = s_skill_data.process_no
                skill_data.skill_id = tonumber(s_skill_data.skill_id)
                skill_data.skill_tag = s_skill_data.skill_tag
                skill_data.trigger_msg = s_skill_data.trigger_msg
                skill_data.life_value = s_skill_data.life_value
                for k,v in pairs(s_skill_data.other_data or {}) do
                    skill_data[v.key] = v.value
                end
                skill_data.owner_id = tonumber(v.car_no)
                skill_data.owner_type = tonumber(DriveModel.OwnerType.car)
                M.RefreshSkill(skill_data)
            end
        end
    end

    --刷新玩家身上的技能
    local players_info = DriveModel.data.players_info
    for seat_num,player_info in ipairs(players_info or {}) do
        for i,s_skill_data in ipairs(player_info.skill_datas or {}) do
            local skill_data = {}
            --默认断线重连上来的技能在触发状态
            skill_data.status = M.status_enum.trigger
            skill_data.process_no = s_skill_data.process_no
            skill_data.skill_id = tonumber(s_skill_data.skill_id)
            skill_data.skill_tag = s_skill_data.skill_tag
            skill_data.trigger_msg = s_skill_data.trigger_msg
            skill_data.life_value = s_skill_data.life_value
            -- skill_data.other_data = s_skill_data.other_data
            for k,v in pairs(s_skill_data.other_data or {}) do
                skill_data[v.key] = v.value
            end
            skill_data.owner_id = tonumber(player_info.seat_num)
            skill_data.owner_type = tonumber(DriveModel.OwnerType.player)
            M.RefreshSkill(skill_data)
        end
    end

    --刷新system技能
    local system_data = DriveModel.data.system_data
    if system_data and next(system_data) then
        for i,s_skill_data in ipairs(system_data.skill_datas or {}) do
            local skill_data = {}
            --默认断线重连上来的技能在触发状态
            skill_data.status = M.status_enum.trigger
            skill_data.process_no = s_skill_data.process_no
            skill_data.skill_id = tonumber(s_skill_data.skill_id)
            skill_data.skill_tag = s_skill_data.skill_tag
            skill_data.life_value = s_skill_data.life_value
            skill_data.trigger_msg = s_skill_data.trigger_msg
            -- skill_data.other_data = s_skill_data.other_data
            for k,v in pairs(s_skill_data.other_data or {}) do
                skill_data[v.key] = v.value
            end
            skill_data.owner_id = tonumber(DriveModel.OwnerType.system)
            skill_data.owner_type = tonumber(DriveModel.OwnerType.system)
            M.RefreshSkill(skill_data)
        end
    end
    DriveSkillBuffContainer.Refresh()
end

function M.Clear()
    for owner_type,v in pairs(this.m_data.skill_map or {}) do
        for owner_id,v1 in pairs(v) do
            for skill_id,skill in pairs(v1) do
                skill:MyExit()
            end
        end
    end
    this.m_data.skill_map = {}
end

local convert_skill_data = function (data)
    local skill_data = {}
    local sd = data[data.key]
    skill_data.process_no = data.process_no
    skill_data.father_process_no = data.father_process_no
    skill_data.life_value = sd.skill_data.life_value
    skill_data.skill_id = tonumber(sd.skill_data.skill_id)
    skill_data.skill_tag = sd.skill_data.skill_tag
    skill_data.trigger_msg = sd.trigger_msg
    -- skill_data.other_data = sd.skill_data.other_data
    for k,v in pairs(sd.skill_data.other_data or {}) do
        skill_data[v.key] = v.value
    end
    skill_data.owner_id = tonumber(sd.owner_data.owner_id)
    skill_data.owner_type = tonumber(sd.owner_data.owner_type)
    skill_data.pos = sd.pos
    if sd.trigger_data then
        skill_data.trigger_data = sd.trigger_data
        skill_data.launcher = {}
        for k,v in ipairs(sd.trigger_data) do 
            skill_data.launcher[k] = v.owner_id
        end
    end

    if sd.receive_data then
        skill_data.receive_data = sd.receive_data
        skill_data.effecter = {}
        for k,v in ipairs(sd.receive_data) do 
            skill_data.effecter[k] = v.owner_id
        end
    end
    -- skill_data.data = data
    return skill_data
end

function M.on_play_process_skill_create(data)
    Event.Brocast("skill_manager_skill_create",data)
    local skill_data = convert_skill_data(data)
    skill_data.status = M.status_enum.create
    skill_data.act = M.act_enum.create
    -- M.RemoveSkill(skill_data)
    M.RefreshSkill(skill_data)
    local skill_item = M.GetSkill(skill_data)
    if skill_item then
        skill_item:OnActStart()
    end
end

function M.on_play_process_skill_trigger(data)
    Event.Brocast("skill_manager_skill_trigger",data)
    local skill_data = convert_skill_data(data)
    skill_data.status = M.status_enum.trigger
    skill_data.act = M.act_enum.trigger
    M.RefreshSkill(skill_data)
    local skill_item = M.GetSkill(skill_data)
    if skill_item then
        skill_item:OnActStart()
    end
end

function M.on_play_process_skill_dead(data)
    local skill_data = convert_skill_data(data)
    skill_data.status = M.status_enum.dead
    skill_data.act = M.act_enum.dead
    M.RefreshSkill(skill_data)
    local skill_item = M.GetSkill(skill_data)
    if skill_item then
        skill_item:OnActStart()
    end
    M.RemoveSkill(skill_data)
end

function M.on_play_process_skill_change(data)
    local skill_change_data = data[data.key]
    skill_change_data.owner_type = tonumber(skill_change_data.owner_data.owner_type)
    skill_change_data.owner_id = tonumber(skill_change_data.owner_data.owner_id)
    skill_change_data.status = M.status_enum.change
    skill_change_data.act = M.act_enum.change
    skill_change_data.process_no = data.process_no
    local skill_item = M.GetSkill(skill_change_data)
    if skill_item then
        skill_item:OnActStart(skill_change_data.act,skill_change_data)
    end
end
