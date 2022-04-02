package.loaded["Game.game_Hall.Lua.HallModel"] = nil
require "Game.game_Hall.Lua.HallModel"
package.loaded["Game.game_Hall.Lua.HallPanel"] = nil
require "Game.game_Hall.Lua.HallPanel"

HallLogic = {}

local this  -- 单例

local cur_panel

--get push devicetoken timer
local UpdatePushDeviceTokenTimer
local UPDATE_PUSHDEVICETOKEN_INTERVAL = 5

local listener
local function AddListener()
    listener = {}
    listener["EnterForeGround"] = this.on_backgroundReturn_msg
    listener["EnterBackGround"] = this.on_background_msg
    listener["login_complete"] = this.login_complete
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
 --

--游戏后台重进入消息
function HallLogic.on_backgroundReturn_msg()
    if cur_panel then
        cur_panel:MyRefresh()
    end
end
--游戏后台消息
function HallLogic.on_background_msg()
    DOTweenManager.KillAllStopTween()
end
function HallLogic.login_complete()
    if cur_panel then
        cur_panel:MyRefresh()
    end
end

function HallLogic.Init()
	SceneHelper.GotoSceneServer()

	MainLogic.SetCanvasScaler()
	audioMgr:CloseSound()
	Util.ClearMemory()
    this = HallLogic

    HallModel.Init()
    AddListener()
    local call = function ()
        GameManager.CheckCurrGameScene()
    end

    cur_panel = HallPanel.Create(call)

    UpdatePushDeviceTokenTimer = Timer.New(this.UpdatePushDeviceToken, UPDATE_PUSHDEVICETOKEN_INTERVAL, -1, nil, true)
    AudioManager.PlaySceneBGM(audio_config.game.com_main_map_zhujiemian.audio_name)
    UpdatePushDeviceTokenTimer:Start()
    return this
end

--进入支付
function HallLogic.gotoPay()
    PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function HallLogic.UpdatePushDeviceToken()
	local pushDeviceToken = sdkMgr:GetPushDeviceToken()
	if pushDeviceToken == nil or pushDeviceToken == "" then
		--print("[PUSH] deviceToken is invalid")
		return
	end

	local device_os = string.lower(MainModel.LoginInfo.device_os)
	if string.find(device_os, "iphone") ~= nil or string.find(device_os, "ios") ~= nil then
		device_os = "ios"
	elseif string.find(device_os, "android") ~= nil then
		device_os = "android"
	end
	print("[PUSH] deviceToken: " .. pushDeviceToken .. ", device_os: " .. device_os)

	Network.SendRequest("device_info", {device_type=device_os, device_token=pushDeviceToken})

	UpdatePushDeviceTokenTimer:Stop()
	UpdatePushDeviceTokenTimer = nil
end

function HallLogic.Exit()
    if this then
        HallModel.Exit()
        if cur_panel then
            cur_panel:MyExit()
        end
        cur_panel = nil

	if UpdatePushDeviceTokenTimer then
		UpdatePushDeviceTokenTimer:Stop()
		UpdatePushDeviceTokenTimer = nil
	end

        RemoveLister()

        this = nil
    end
end

local function SplitGroupPairs(value, groupSplit, pairSplit)
	local result = {}

	local groups = StringHelper.Split(value, groupSplit)
	if not groups or #groups <= 0 then return result end

	for k, v in pairs(groups) do
		local pair = StringHelper.Split(v, pairSplit)
		if pair and #pair == 2 then
			result[#result + 1] = {tonumber(pair[1]), tonumber(pair[2])}
		end
	end

	return result
end

--[[
[id] = {
	time_type = 0,
	activity_time = {
		{begin, end}, {begin, end}
	}
	activity_node = "but",
}
]]--
local function parse_activity_time(config)
	local monday_time = StringHelper.getThisWeekMonday()

	local time_table = {}
	for k, v in pairs(config) do
		local times = SplitGroupPairs(v.activity_time, "#", "+")
		if #times > 0 then
			if v.time_type == 1 then
				for _, t in pairs(times) do
					t[1] = t[1] + monday_time
					t[2] = t[2] + monday_time
				end
			end

			local item = {}
			item.time_type = v.time_type
			item.activity_node = v.activity_node
			item.activity_time = times
			time_table[k] = item
		end
	end
	return time_table
end

return HallLogic
