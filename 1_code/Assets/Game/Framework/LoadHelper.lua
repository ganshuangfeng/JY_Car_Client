require "Game.game_Loding.Lua.LodingLogic"
LoadHelper = {}
local M = LoadHelper

local load_scene_start
local load_scene_finish
local load_asset_progress

local listener
local function AddListener()
    for msg,cbk in pairs(listener or {}) do
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
    listener["load_scene_start"] = load_scene_start
    listener["load_scene_finish"] = load_scene_finish
    listener["load_asset_progress"] = load_asset_progress
end

function M.Init()
    M.Exit()
	MakeListener()
	AddListener()
end

function M.Exit()
    RemoveLister()
end

load_scene_start = function(data)
    dump(data,"<color=yellow>load_scene_start</color>")
    LodingSmallPanel.Create(data)
end

load_scene_finish = function ()
    dump(nil,"<color=yellow>load_scene_finish</color>")
	LodingSmallPanel.Close()
end

load_asset_progress = function()
    dump(nil,"<color=yellow>load_asset_progress</color>")
	LodingSmallPanel.LoadingUpdate()
end

M.Init()