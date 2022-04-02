-- 科技
local basefunc = require "Game.Common.basefunc"
TechnologyModel = {}
local M = TechnologyModel

local drive_technology_config = GameModuleManager.ExtLoadLua(TechnologyController.key,"drive_technology_config")
local this
local listener

local function MakeListener()
    listener={}
end

local function AddListener()
    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveListener()
    if listener then
        for msg,cbk in pairs(listener) do
            Event.RemoveListener(msg, cbk)
        end
    end
    listener=nil
end

function M.Init()
    M.Exit()
    MakeListener()
    AddListener()
    this = M
	this.m_data = {}
    M.InitConfig()
end

function M.Exit()
    if this then
		RemoveListener()
		this = nil
	end
end

function M.InitConfig()
    this.config = {}
    this.config.skills = {}
    local techType = {}
    for i = 1, #drive_technology_config.tech do
        this.config.skills[i] = {}
        local type = drive_technology_config.tech[i].type
        techType[type] = i
    end

    for k_, v_ in pairs(drive_technology_config) do
        if k_ ~= "tech" then
            local index = techType[k_]
            for i = 1 , #v_ do
                this.config.skills[index][#this.config.skills[index] + 1] = SysCarUpgradeManager.GetUpgradeSkillCfg(v_[i].type_id)
                this.config.skills[index][#this.config.skills[index]].tech_type = k_
            end
        end 
    end

    dump(this.config.skills,"<color=red>Skills</color>")
end

function M.GetTechCount()
    return #drive_technology_config.tech
end

function M.GetSkillCfgById(index)
    return drive_technology_config.skills[index]
end

function M.GetTechCfgById(index)
    return drive_technology_config.tech[index]
end

function M.GetSkillsByTechId(index)
    return this.config.skills[index]   
end