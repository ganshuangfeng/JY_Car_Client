-- 创建时间:2021-01-07

ext_require("Game.game_Drive.Lua.DrivePlayerInfoItem")
ext_require("Game.game_Drive.Lua.DrivePlayerInfoPanel")
DrivePlayerManager = {}

local M = DrivePlayerManager


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
        
        this = DrivePlayerManager

        this.m_data = {}
        this.cars = {}
        MakeListener()
        AddListener()
        M.InitUIConfig()
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

function M.Exit()
    if this then
        M.ClearPanel()
        RemoveLister()
    end
    this = nil
end

function M.CreatePanel(parent)
    if this.cur_panel then
        this.cur_panel:MyExit()
        this.cur_panel = nil
    end
    this.cur_panel = DrivePlayerInfoPanel.Create(parent)
end

function M.RefreshPanel()
    if this.cur_panel then
        this.cur_panel:MyRefresh()
        return
    end
    M.CreatePanel()
end

function M.ClearPanel()
    if this and this.cur_panel then
        this.cur_panel:MyExit()
        this.cur_panel = nil
    end
end

---获得当前实际显示的属性值
function M.GetShowAttribute(seat_num,car_id,modify_key_name)
    return this.cur_panel:GetShowAttribute(seat_num,car_id,modify_key_name)
end