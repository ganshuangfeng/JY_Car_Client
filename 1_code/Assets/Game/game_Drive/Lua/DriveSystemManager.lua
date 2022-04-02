-- 创建时间:2020-10-19
DriveSystemManager = {}
local M = DriveSystemManager
ext_require("Game.game_Drive.Lua.DriveSystem")

M.dotween_key = "DriveSystemManager"
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
end

function M.Init()
    if not this then
        M.Exit()
        this = DriveSystemManager
        this.m_data = {}
        MakeListener()
        AddListener()
        M.InitConfig()
    end
end

function M.InitConfig()
    this.config = {}
end

function M.Exit()
    if this then
        this.ClearSystem()
    end
    RemoveLister()
    this = nil
end

function M.RefreshSystemData(system_data)
    if not system_data or not next(system_data) then return end
    this.system:RefreshData(system_data)
end

function M.RefreshSystem()
    if not DriveModel.data or not next(DriveModel.data) then return end
    local system_data = DriveModel.data.system_data
    if not system_data or not next(system_data) then return end
    if not this.system then
        this.AddSystem(system_data)
    else
        this.system:Refresh(system_data)
    end
end

function M.CreateSystem(system_data)
    this.AddSystem(system_data)
end

function M.AddSystem(system_data)
    dump(system_data,"<color=white>加入系统</color>")
    this.system = DriveSystem.Create(system_data)
    return this.system
end

function M.RemoveSystem(system_data)
    local system = M.GetSystem(system_data)
    if not system then return end
    system:MyExit()
    this.system = nil
    system = nil
end

function M.ClearSystem()
    if this.system then
        this.system:MyExit()
        this.system = nil
    end
end

function M.GetAllSystem()
    return this.system
end

function M.GetSystem()
    return this.system
end

function M.GetSystemData()
    return this.system.system_data
end