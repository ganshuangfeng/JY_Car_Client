local basefunc = require "Game/Common/basefunc"

DrivePanel = basefunc.class()
local M = DrivePanel
M.name = "DrivePanel"
local instance

function M.Init()
	return M.Create()
end

function M.Exit()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M.Create()
	if not instance then
		instance = M.New()
	end
	return instance
end

function M.Instance()
	return instance
end

function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:MakeListener()
	self.listener = {}
	self.listener["logic_pvp_all_info_req_response"] = basefunc.handler(self,self.on_pvp_all_info_req_response)
	self.listener["model_pvp_signup_response"] = basefunc.handler(self,self.on_pvp_signup_response)

	self.listener["model_pvp_enter_room_msg"] = basefunc.handler(self,self.on_pvp_enter_room_msg)
	self.listener["model_pvp_join_msg"] = basefunc.handler(self,self.on_pvp_join_msg)
	self.listener["model_driver_ready_msg"] = basefunc.handler(self,self.on_driver_ready_msg)
	self.listener["model_driver_ready_ok_msg"] = basefunc.handler(self,self.on_driver_ready_ok_msg)
	self.listener["logic_pvp_game_over_msg"] = basefunc.handler(self,self.on_pvp_game_over_msg)
	self.listener["model_driver_game_begin_msg"] = basefunc.handler(self,self.on_driver_game_begin_msg)
	self.listener["model_driver_game_settlement_msg"] = basefunc.handler(self,self.on_driver_game_settlement_msg)
	
	self.listener["logic_drive_game_process_data_msg_status_change"] = basefunc.handler(self,self.on_drive_game_process_data_msg_status_change)
	self.listener["logic_drive_game_process_data_msg_player_op"] = basefunc.handler(self,self.on_drive_game_process_data_msg_player_op)
	self.listener["logic_drive_game_process_data_msg_player_action"] = basefunc.handler(self,self.on_drive_game_process_data_msg_player_action)

	--流程控制相关
	self.listener["logic_round_end"] = basefunc.handler(self,self.on_round_end)

end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:MyExit()
	DriveToolsContainer.Close()
	DriveSkillBuffContainer.Close()
	DriveAccelerator.Close()
	DriveGameStatusPanel.Close()
	DriveGameInfoPanel.Close()
	DriveSkillBottomPanel.Clear()
	-- DriveSkillCarPanel.Clear()
	if self.timer_countdown then
		self.timer_countdown:Stop()
	end
	self.timer_countdown = nil
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end

function M:ctor()
	local parent = GameObject.Find("2DNode/Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	basefunc.GeneratingVar(self.transform, self)
	self:MakeListener()
	self:AddListener()
	self:InitUI()
	self.timer_countdown = Timer.New(function (  )
		self:Countdowm()
	end,1,-1,nil,nil)
	self.timer_countdown:Start()
end

function M:SetStyle()
	self.down_bg_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_bg_czl"))
	self.surround_btn_img = self.surround_btn.transform:GetComponent("Image") 
	self.surround_btn_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_btn_caidan"))
	self.surround_btn_img:SetNativeSize()
	self.set_btn_img = self.set_btn.transform:GetComponent("Image") 
	self.set_btn_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_btn_caidan"))
	self.set_btn_img:SetNativeSize()
end

function M:InitUI()
	self:SetStyle()
	self.surround_btn.onClick:AddListener(function()
		if DriveModel.data.map_data then
			HintPanel.Create({show_yes_btn = true,show_close_btn = true,msg = "确定要投降吗？",yes_callback = function()
				DriveModel.SendRequest("pvp_surrender_game",nil,function(data)
					dump(data)
				end)
			end})
		else
			TipsShowUpText.Create("游戏尚未开始！")
		end
	end)
	self.surround_btn.gameObject:SetActive(false)

	self.skill_desc_panel:GetComponent("Button").onClick:AddListener(function()
		self.skill_desc_panel.gameObject:SetActive(false)
	end)
	local ps_go = self.down_tips_fx:Find("Particle System")
	self.set_btn.onClick:AddListener(function()
		local gotoUI = {_goto = "sys_setting",goto_parm = "view"}
		GameManager.Goto(gotoUI)
	end)
	SetParticleSize(ps_go)
	self:MyRefresh()
end

function M:Countdowm()
	local op_timeout = DriveModel.get_op_timeout()
	self.time_out_txt.text = op_timeout < 0 and "" or op_timeout
end

-------------------刷新
function M:MyRefresh()
	self:SetStyle()
	dump(DriveModel.data,"<color=white>刷新 MyRefresh</color>")
	if not DriveModel.data then
		TipsShowUpText.Create("DriveModel.data is nil")
		return
	end

	-- if DriveModel.data.game_status == DriveModel.GameStatus.wait_table then
	-- elseif DriveModel.data.game_status == DriveModel.GameStatus.wait_ready then
	-- elseif DriveModel.data.game_status == DriveModel.GameStatus.gaming then
	-- elseif DriveModel.data.game_status == DriveModel.GameStatus.game_over then
	-- end
	self:RefreshDownNode()
	self:RefreshWaitTablePanel()
	self:RefreshMap()
	self:RefreshCar()
	self:RefreshSystem()
	self:RefreshOP()
	self:RefreshPlayerInfo()
	self:RefreshSkillBottomPanel()
	self:RefreshSkill()
	self:RefreshBuff()
	self:RefreshTools()
	self:RefreshRoadAward()
	self:RefreshRoadBarrier()
	self:RefreshGameStatusPanel()
	self:RefreshGameInfoPanel()
end

function M:RefreshDownNode()
	local b = false
	if DriveModel.data.game_status == DriveModel.GameStatus.wait_table then
	elseif DriveModel.data.game_status == DriveModel.GameStatus.wait_ready then
	elseif DriveModel.data.game_status == DriveModel.GameStatus.gaming then
		b = true
	elseif DriveModel.data.game_status == DriveModel.GameStatus.settlement then
		b = true
	elseif DriveModel.data.game_status == DriveModel.GameStatus.game_over then
	end

	self.down_node.gameObject:SetActive(b)
	if b then
		Event.Brocast("model_guide_step")
	end
end

function M:RefreshRoadBarrier()
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		RoadBarrierManager.ClearMap()
		return
	end
	RoadBarrierManager.Refresh()
end

function M:RefreshWaitTablePanel()
	if DriveModel.data and (DriveModel.data.ready_ok or DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		DriveWaitTablePanel.Close()
		return
	end
	DriveWaitTablePanel.Refresh()
end

function M:RefreshGameStatusPanel()
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		DriveGameStatusPanel.Close()
		return
	end
	DriveGameStatusPanel.Refresh()
end

function M:RefreshGameInfoPanel()
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		DriveGameInfoPanel.Close()
		return
	end
	DriveGameInfoPanel.Refresh()
end

--刷新油门
function M:RefreshAccelerator()
	DriveAccelerator.Refresh()
end

function M:RefreshOP()
	self:RefreshAccelerator()
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not DriveModel.data.game_status == DriveModel.GameStatus.gaming
	or not DriveModel.data.players_info 
	or not DriveModel.data.seat_num then
		return 
	end

	local player_op = DriveModel.data.players_info[DriveModel.data.seat_num].player_op
	local seat_num = DriveModel.data.seat_num
	for k,v in ipairs(DriveModel.data.players_info) do
		if v.player_op then
			player_op = v.player_op
			seat_num = v.seat_num
		end
	end
	if not player_op then
		return
	end

	if player_op.op_type == DriveModel.OPType.accelerator_all then
		--所有油门
		if seat_num == DriveModel.data.seat_num then
			DriveMapManager.CloseAllMapBtn()
			self.down_tips_fx.gameObject:SetActive(true)
		end
		for car_id,car in ipairs(DriveCarManager.cars[seat_num]) do
			car:AddRoundArrow(seat_num == DriveModel.data.seat_num)
		end
	elseif player_op.op_type == DriveModel.OPType.accelerator_big then
		--大油门
		if seat_num == DriveModel.data.seat_num then
			DriveMapManager.CloseAllMapBtn()
		end
	elseif player_op.op_type == DriveModel.OPType.accelerator_small then
		--小油门
		if seat_num == DriveModel.data.seat_num then
			DriveMapManager.CloseAllMapBtn()
		end
	elseif player_op.op_type == DriveModel.OPType.select_index then
		--选择索引
		if seat_num == DriveModel.data.seat_num then
			DriveMapManager.CloseAllMapBtn()
		end
	elseif player_op.op_type == DriveModel.OPType.select_road or player_op.op_type == DriveModel.OPType.select_clear_barrier then
		--选择道路
		if seat_num == DriveModel.data.seat_num then
			DriveMapManager.SelectGrid(player_op.for_select_vec)
		end

		for seat_num,cars in ipairs(DriveCarManager.cars) do
			for car_id,car in ipairs(cars) do
				car:ShowOrHideSelectRoad(DriveModel.data.player_op)
			end
		end
	elseif player_op.op_type == DriveModel.OPType.select_skill then
		--选择技能
		if seat_num == DriveModel.data.seat_num then
			DriveMapManager.CloseAllMapBtn()
		end
		DriveSelectSkillPanel.Create(player_op)
	elseif player_op.op_type == DriveModel.OPType.select_map_award then
		--选择地图奖励
		if seat_num == DriveModel.data.seat_num then
			DriveMapManager.CloseAllMapBtn()
		end
		DriveSelectRoadAwardPanel.Create(player_op)
	elseif player_op.op_type == DriveModel.OPType.use_tool then
		--使用道具
		if seat_num == DriveModel.data.seat_num then
			DriveMapManager.CloseAllMapBtn()
		end
		TipsShowUpText.Create("使用道具")
	elseif player_op.op_type == DriveModel.OPType.select_tool_op then
		--选择道具选项
		if seat_num == DriveModel.data.seat_num then
			DriveMapManager.CloseAllMapBtn()
		end
		TipsShowUpText.Create("选择道具选项")
		DriveSelectToolOPPanel.Create(player_op)
	end
end

function M:PlayRoundChange(seat_num)
	local fx_pre = newObject("tanchuang_huihetishi",GameObject.Find("Canvas/LayerLv5").transform)
	if seat_num == DriveModel.data.seat_num then
        AudioManager.PlaySound(audio_config.drive.com_main_map_huihetishi.audio_name)
		fx_pre.transform:Find("wodehuihe").gameObject:SetActive(true)
		fx_pre.transform:Find("duishouhuihe").gameObject:SetActive(false)
	else
		fx_pre.transform:Find("duishouhuihe").gameObject:SetActive(true)
		fx_pre.transform:Find("wodehuihe").gameObject:SetActive(false)
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(3)
	seq:OnForceKill(function()
		destroy(fx_pre)
	end)
end

function M:RefreshPlayerInfo()
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		DrivePlayerManager.ClearPanel()
		return
	end
	DrivePlayerManager.RefreshPanel()
end

function M:RefreshMap()
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		DriveMapManager.ClearMap()
		return
	end
	DriveMapManager.RefreshMap()
end

function M:RefreshCar()
	dump(DriveModel.data.game_status,"<color=yellow>游戏状态</color>")
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		DriveCarManager.ClearCar()
		return
	end
	DriveCarManager.RefreshCar()
end

function M:RefreshSystem(  )
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		DriveSystemManager.ClearSystem()
		return
	end
	DriveSystemManager.RefreshSystem()
end

function M:RefreshSkillBottomPanel()
	if true then return end
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		DriveSkillBottomPanel.Clear()
		return
	end
	DriveSkillBottomPanel.Refresh()
end

function M:RefreshSkill()
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		SkillManager.Clear()
		return
	end
	SkillManager.Refresh()
end

function M:RefreshTools()
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		ToolsManager.Clear()
		return
	end
	ToolsManager.Refresh()
end

function M:RefreshBuff()
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		BuffManager.Clear()
		return
	end
	BuffManager.Refresh()
end

function M:RefreshRoadAward()
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not (DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.settlement or DriveModel.data.game_status == DriveModel.GameStatus.game_over) then
		RoadAwardManager.Clear()
		return
	end
	RoadAwardManager.Refresh()
end

-------------------消息
function M:on_pvp_all_info_req_response()
	self:MyRefresh()
end

function M:on_pvp_signup_response()
	-- TipsShowUpText.Create("报名成功")
	DriveSelectSkillPanel.Exit()
	BuffManager.Clear()
	SkillManager.Clear()
	DriveCarManager.ClearCar()
	DOTweenManager.KillLayerKeyTween(DriveLogicProcess.dotween_key)

	self:MyRefresh()
end

function M:on_pvp_enter_room_msg()
	-- TipsShowUpText.Create("进入房间")
	self:MyRefresh()
end

function M:on_pvp_join_msg(data)
	-- TipsShowUpText.Create(data.player_info.name .. "加入")
	self:MyRefresh()
end

function M:on_driver_ready_msg(data)
	local player_info = DriveModel.data.players_info[data.seat_num]
	-- TipsShowUpText.Create(player_info.name .. "准备")
	self:MyRefresh()
end

function M:on_driver_ready_ok_msg(data)
	Event.Brocast("dbss_send_power",{key = "rank_match_enter_game"})
	self:MyRefresh()
	if self.game_begin_panel then
		self.game_begin_panel:MyExit()
		self.game_begin_panel = nil
	end
	self.game_begin_panel = DriveBeginPanel.Create()
end

function M:on_driver_game_begin_msg(data)
	self:MyRefresh()
	if self.game_begin_panel then
		self.game_begin_panel:MyExit()
		self.game_begin_panel = nil
	end
end

function M:on_pvp_game_over_msg(data)
	-- TipsShowUpText.Create("pve 游戏结束")
	self:MyRefresh()
	-- DriveClearingPanel.Create(data)
end

--玩家状态改变
function M:on_drive_game_process_data_msg_status_change(data)
	if data.seat_num then
		local player_info = DriveModel.data.players_info[data.seat_num]
		if DriveModel.GameingStatus[data.status] == DriveModel.GameingStatus.game_begin then
			if DriveModel.data.seat_num == data.seat_num then
				DriveAnimManager.PlayProcessFirstPlayerFx()
			end
		elseif DriveModel.GameingStatus[data.status] == DriveModel.GameingStatus.round_start then
			self:PlayRoundChange(data.seat_num)
		else
			-- TipsShowUpText.Create(player_info.name .. "状态改变" .. DriveModel.GameingStatus[data.status])
        end
	else
		-- TipsShowUpText.Create("状态改变" .. DriveModel.GameingStatus[data.status])
	end
	-- self:RefreshOP()
end

--玩家操作
function M:on_drive_game_process_data_msg_player_op(data)
	dump(data,"<color=white>玩家操作</color>")
    self:RefreshOP()
	Event.Brocast("view_drive_game_process_data_msg_player_op",data)
end

--玩家动作
function M:on_drive_game_process_data_msg_player_action(data)
	dump(data,"<color=white>玩家动作</color>")
	--清除下方提示
	self.down_tips_fx.gameObject:SetActive(false)
	--清除车上的提示
	DriveCarManager.ClearCarArrow()
	self:RefreshAccelerator()

    if data.op_type == DriveModel.OPType.select_skill then
		--选择技能
		DriveSelectSkillPanel.PlayCloseAni(data)
	elseif data.op_type == DriveModel.OPType.select_tool_op then
		--选择道具选项
		DriveSelectToolOPPanel.PlayCloseAni(data)
	elseif data.op_type == DriveModel.OPType.select_map_award then
		DriveSelectRoadAwardPanel.PlayCloseAni(data)
	end

	for seat_num,cars in ipairs(DriveCarManager.cars) do
		for car_id,car in ipairs(cars) do
			car:ShowOrHideSelectRoad(DriveModel.data.player_op,false)
		end
	end
end

function M:on_round_end(data)
	self:MyRefresh()
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.2)
	seq:AppendCallback(function()
		if DriveModel.data.settlement_info and DriveModel.data.settlement_info.win_reason ~= 1 then
			DriveClearingPanel.Create(DriveModel.data.settlement_info)
			DriveModel.data.settlement_info = nil
		end
	end)
	Event.Brocast("view_round_end")
end

function M:on_driver_game_settlement_msg()
	--如果是投降的话直接在这里弹界面
	if DriveModel.data.settlement_info and DriveModel.data.settlement_info.win_reason == 3 then
		DriveClearingPanel.Create(DriveModel.data.settlement_info)
		DriveModel.data.settlement_info = nil
	end
end

function M.CheckClickScreen()
	local is_pointer_over
	local click_position
	if gameRuntimePlatform == "WindowsEditor" or gameRuntimePlatform == "" then
		if UnityEngine.Input.GetMouseButtonDown(0) then
			if IsEquals(EventSystem.current) then
				is_pointer_over = EventSystem.current:IsPointerOverGameObject()
				click_position = UnityEngine.Input.mousePosition
				Event.Brocast("click_screen",{click_position = click_position,is_pointer_over = is_pointer_over})
			end
		end
	else
		if UnityEngine.Input.touchCount > 0 then
			local first_touch = UnityEngine.Input.GetTouch(0)
			if first_touch.phase == UnityEngine.TouchPhase.Began then
				if IsEquals(EventSystem.current) then
					is_pointer_over = EventSystem.current:IsPointerOverGameObject(first_touch.fingerId)
					click_position = first_touch.position
					Event.Brocast("click_screen",{click_position = click_position,is_pointer_over = is_pointer_over})
				end
			end
		end
	end
end