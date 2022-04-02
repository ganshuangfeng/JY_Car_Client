local basefunc = require "Game.Common.basefunc"
GuideFunction = {}
local M = GuideFunction

function M.ok()
	GuideView.Close()
	Event.Brocast("guide_step_complete")
	--自动执行下一步
	Event.Brocast("guide_step_trigger")
end

--第一场比赛
function M.signup_game_1()
	local game_id = -1
	local map_id = 5
	local scene_name = SceneConfig["game_Drive_map" .. map_id].SceneName
	GameManager.Goto({
		_goto = scene_name,
		car_id = SysCarManager.GetCurCar().car_id,
		game_id = game_id,
		map_id = map_id,
	})
end

local step_1_1
local step_1_2
local step_1_3
function M.run_step_1()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 1 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if not step_1_1 and cur_scene == SceneConfig.game_Hall.SceneName then
		--在大厅报名进入比赛场
		step_1_1 = true
		M.signup_game_1()
		return false
	elseif not step_1_2 and cur_scene == SceneConfig.game_Drive_map5.SceneName then
		local target = GameObject.Find("DriveWaitTablePanel")
		if not IsEquals(target) or not target.activeSelf then
			return
		end
		local btn = target.transform:Find("@cancel_btn")
		if IsEquals(btn) then
			btn.gameObject:SetActive(false)
		end
		step_1_2 = true
		return false
	elseif cur_scene == SceneConfig.game_Drive_map5.SceneName then
		dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step 11111</color>")
		local target = GameObject.Find("2DNode/Canvas/GUIRoot/DrivePanel/@down_node")
		if not IsEquals(target) or not target.activeSelf then
			return
		end
		--在第一场比赛中
		local timer = Timer.New(function ()
			step_1_3 = true
			GuideView.Create()
		end,3,1)
		timer:Start()
		return true
	end
end

function M.check_end_step_1()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 1 then return end
	if not step_1_3 then return end

	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	local target = GameObject.Find("2DNode/Canvas/GUIRoot/DrivePanel/@down_node")
	if not IsEquals(target) or not target.activeSelf then
		return
	end

	return true
end

function M.run_step_2()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 2 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	--在第一场比赛中
	GuideView.Create()
	if DriveAccelerator then
		local acc = DriveAccelerator.GetInstance()
		acc:MyRefresh()
		acc:SetState(DriveAccelerator.State.big)
		return true
	end
end

function M.check_end_step_2()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 2 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	return true
end

function M.run_step_3()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 3 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	--在第一场比赛中
	GuideView.Create()

	return true
end

function M.check_end_step_3()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 3 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	return true
end

function M.run_step_4()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 4 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	if not DriveAccelerator then return end
	local acc = DriveAccelerator.GetInstance()
	if not acc or not (acc.state == DriveAccelerator.State.small or acc.state == DriveAccelerator.State.all) then return end

	--在第一场比赛中
	GuideView.Create()

	return true
end

function M.check_end_step_4()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 4 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	if not DriveAccelerator then return end
	local acc = DriveAccelerator.GetInstance()
	if not acc or not (acc.state == DriveAccelerator.State.small or acc.state == DriveAccelerator.State.all) then return end

	return true
end

function M.run_step_5()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 5 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	--在第一场比赛中
	GuideView.Create()
	if DriveAccelerator then
		local acc = DriveAccelerator.GetInstance()
		acc:SetState(DriveAccelerator.State.small)
		return true
	end
end

function M.check_end_step_5()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 5 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	return true
end

function M.run_step_6()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 6 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	--在第一场比赛中
	GuideView.Create()

	return true
end

function M.check_end_step_6()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 6 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	return true
end

local step_9_1
local step_9_2
function M.run_step_9(data)
	dump(data,"<color=green>大招停留数据？？？？？？？？？？</color>")
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 9 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end


	if not DriveLogicProcess then return end
	local pd_next = DriveLogicProcess.get_next_process()
	dump(pd_next,"<color=white>新手引导大招数据？？？？？？？？</color>")
	if pd_next and pd_next.index == 3 and pd_next.key == "road_award_change" then
		--在第一场比赛中
		if not step_9_1 then 
			step_9_1 = true
			DriveLogicProcess.set_process_pause(true)
			return
		end
	else
		return
	end

	if data and data.car_data and data.car_data.seat_num == 1 then
		if not step_9_2 then
			step_9_2 = true
			GuideView.Create()
		end
	end

	return true
end

function M.check_end_step_9()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 9 then return end
	if not step_9_2 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	if not DriveLogicProcess then return end
	local pd_next = DriveLogicProcess.get_next_process()
	dump(pd_next,"<color=white>新手引导大招数据？？？？？？？？</color>")
	if pd_next and pd_next.index == 3 and pd_next.key == "road_award_change" then
		local callback = function ()
			DriveLogicProcess.set_process_pause(false)
			Event.Brocast("process_play_next")
		end
		return true,callback
	end
end

local setp_9_data
local setp_9_func
function M.run_step_10()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 10 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	if not DriveModel or not DriveModel.data or not DriveModel.data.settlement_info then return end
	setp_9_data = basefunc.deepcopy(DriveModel.data.settlement_info)
	--在第一场比赛中
	GuideView.Create()
	setp_9_func = DriveClearingPanel.Create
	DriveClearingPanel.Create = function ()
		--屏蔽创建结算界面
		return
	end

	return true
end

function M.check_end_step_10()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 10 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Drive_map5.SceneName then
		return
	end

	DriveClearingPanel.Create = setp_9_func
	DriveClearingPanel.Create(setp_9_data)
	return true
end

function M.run_step_11()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 11 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	GuideView.Create()

	return true
end

function M.check_end_step_11()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 11 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	return true
end

function M.run_step_12()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 12 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end
	GuideView.Create()

	return true
end

function M.check_end_step_12()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 12 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end
	return true
end

function M.run_step_13()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 13 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	dump({cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end
	GuideView.Create()

	return true
end

function M.check_end_step_13()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 13 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end

	return true
end

local setp_14_b
function M.run_step_14()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 14 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	dump({cur_step_cfg = cur_step_cfg, cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end
	--临时代码
	if not setp_14_b then
		setp_14_b = true
		return
	end
	dump(debug.traceback(),"<color=white>新手引导14步</color>")
	GuideView.Create()

	return true
end

function M.check_end_step_14()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 14 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end

	return true
end

function M.run_step_15()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 15 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	dump({cur_step_cfg = cur_step_cfg, cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end
	GuideView.Create()

	return true
end

function M.check_end_step_15()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 15 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end

	return true
end

function M.run_step_16()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 16 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	dump({cur_step_cfg = cur_step_cfg, cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end
	GuideView.Create()

	return true
end

function M.check_end_step_16()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 16 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end

	return true
end

function M.run_step_17(data)
	dump(debug.traceback(),"<color=white>堆栈</color>")
	dump(data,"<color=white>data</color>")
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 17 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	dump({cur_step_cfg = cur_step_cfg, cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	local match_mask = GameObject.Find("Canvas/LayerLv1/HallPanel/@ui_node/@main_ui/@match/@match_mask")
	if match_mask.activeSelf then
		return
	end
	if data and data.run_type == "enter_scene" then
		--进入场景会默认选择比赛场
		local view_node = GameObject.Find("Canvas/LayerLv1/HallPanel/@view_node")
		if not IsEquals(view_node) then return end
		local cc = view_node.transform.childCount
		if cc == 0 then return end
		local match_panel = GameObject.Find("Canvas/LayerLv1/HallPanel/@view_node/SysMatchPanel")
		if IsEquals(match_panel) then return end
	end
	GuideView.Create()

	return true
end

function M.check_end_step_17()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 17 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end

	return true
end

function M.run_step_18()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 18 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end
	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	dump({cur_step_cfg = cur_step_cfg, cur_scene = cur_scene,cur_step = cur_step},"<color=white>新手引导 run_step</color>")
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end

	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end
	GuideView.Create()

	return true
end

function M.check_end_step_18()
	local cur_step = GuideModel.GetStep()
	if cur_step ~= 18 then return end
	local cur_scene = SceneHelper.GetCurScene()
	if not cur_scene then return end

	local cur_step_cfg = GuideModel.GetCurSetpCfg()
	if cur_step_cfg.target then
		local target = GameObject.Find(cur_step_cfg.target)
		if not IsEquals(target) then
			return
		end	
	end
	if cur_scene ~= SceneConfig.game_Hall.SceneName then
		return
	end

	return true
end