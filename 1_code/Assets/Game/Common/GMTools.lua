GMTools = {}
local M = GMTools
require "Game.GameCommon.Lua.GMPanel"

local function show_gm_panel()
	local UserInfo = MainModel.UserInfo or {}
	local player_level = UserInfo.player_level or 0
	print("[Debug] GMPanel player_level:" .. player_level)
	if player_level < 1  then return end
	GMPanel.Create()
end

function GMTools.OnGestureCircle()
	show_gm_panel()
end

function GMTools.OnGestureLines()
    show_gm_panel()
end

--添加手势
local GestureAdded = false
function M.AddGesture()
	local player_level = MainModel.UserInfo.player_level or 0
	if player_level >= 0 and not GestureAdded then
		gestureMgr:TryAddGesture("GestureCircle")
		GestureAdded = true
	end
end