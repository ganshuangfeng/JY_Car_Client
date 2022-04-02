local basefunc = require "Game/Common/basefunc"

DriveAccelerator = basefunc.class()
local M = DriveAccelerator
M.name = "DriveAccelerator"
local State = {
	all = "all",
	big = "big",
	small = "small",
	off = "off",
	on = "on",
	skill_again = "skill_again",	--再来一次技能改变油门状态
}
M.State = State
local OPType = {
	big = 2, --大油门
	small = 3, --小油门
}

local min_euler_z = -60
local max_euler_z = -300

local instance
function M.Create(parent)
	if instance then
		instance:MyExit()
	end
	instance = M.New(parent)
	return instance
end

--不创建单例的create
function M.RawCreate(parent)
	return M.New(parent)
end

function M.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M.Refresh()
	--如果是平头哥采用不同的油门
	local car_type
	if DriveModel.data and DriveModel.data.seat_num and DriveCarManager.cars and DriveCarManager.cars[DriveModel.data.seat_num] then
		local cars = DriveCarManager.cars[DriveModel.data.seat_num]
		local car = cars[next(cars)]
		car_type = car.config.car_type
	end
	if car_type == "DriveCarPTG" then
		if instance and instance.name == DrivePTGAccelerator.name then
			instance:MyRefresh()
			return
		end
		if instance then
			instance:MyExit()
		end
		instance = DrivePTGAccelerator.Create()
	elseif car_type == "DriveCarLandmine" then
		if instance and instance.name == DriveDLCAccelerator.name then
			instance:MyRefresh()
			return
		end
		if instance then
			instance:MyExit()
		end
		instance = DriveDLCAccelerator.Create()
	else
		if instance and instance.name == M.name then
			instance:MyRefresh()
			return
		end
		if instance then
			instance:MyExit()
		end
		M.Create()
	end
end

function M.GetInstance()
	return instance
end

function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:MakeListener()
	self.listener = {}
	self.listener["model_drive_game_player_op_req_response"] = basefunc.handler(self,self.on_model_drive_game_player_op_req_response)
	self.listener["view_round_end"] = basefunc.handler(self,self.on_view_round_end)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:ctor(parent)
	self.min_euler_z = min_euler_z
	self.max_euler_z = max_euler_z
	self.op_type = OPType.small

	self:MakeListener()
	self:AddListener()
	self:InitUI(parent)
	self:MyRefresh()
end

function M:SetStyle()
	self.pointer_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_icon_ybp_3"))
	self.start_btn_img = self.start_btn.transform:GetComponent("Image")
	self.start_btn_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_btn_ybp"))
	self.bg_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_icon_ybp_1"))
end

function M:InitUI(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot/DrivePanel/@down_node")
	if not parent then return end
	parent = parent.transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	basefunc.GeneratingVar(self.transform, self)

	EventTriggerListener.Get(self.start_btn.gameObject).onDown = basefunc.handler(self, self.OnDown)
	EventTriggerListener.Get(self.start_btn.gameObject).onDrag = basefunc.handler(self, self.OnDrag)
	EventTriggerListener.Get(self.start_btn.gameObject).onUp = basefunc.handler(self, self.OnUp)
	-- self.start_btn.onClick:AddListener(function()
	-- 	if not self.cur_euler_z then
	-- 		self.cur_euler_z = self.start_euler_z
	-- 	end
	-- 	if self.cur_euler_z > -180 then
	-- 		self.op_type = OPType.small
	-- 	else
	-- 		self.op_type = OPType.big
	-- 	end

	-- 	if not self.op_type then
	-- 		return
	-- 	end
	-- 	if self.DOTRoation then
	-- 		self.DOTRoation:Pause()
	-- 	end
	-- 	DriveModel.SendRequest("drive_game_player_op_req",{op_type = self.op_type})
	-- end)
end

--中间值 如果角度大于这个值则是小油门
local center_euler = -180
local click_b = false
function M:OnDown()
	if self.xuli_sound_key then
		AudioManager.CloseSound(self.xuli_sound_key)
		self.xuli_sound_key = nil
	end
	self.xuli_sound_key = AudioManager.PlaySound(audio_config.drive.com_main_map_youmenxuli.audio_name,-1)
	if self.state == State.off or self.state == State.on then
		click_b = false
		return
	end
	click_b = true
	self:SetState(State.on)
	self:RoationAni(nil,true)
	Event.Brocast("guide_step_complete")
	Event.Brocast("guide_step_trigger")
end

local cancel_move_y = 200

function M:OnDrag(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnDrag</color>")
end

function M:ScreenToWorldPoint(position)
	if not self.camera then
		self.camera = GameObject.Find("2DNode/2DCamera"):GetComponent("Camera")
	end
	return self.camera:ScreenToWorldPoint(position)
end

function M:OnUp(go,data)
	if self.xuli_sound_key then
		AudioManager.CloseSound(self.xuli_sound_key)
		self.xuli_sound_key = nil
	end
	if not DriveModel.data.players_info[DriveModel.data.seat_num].player_op then
		for k,v in pairs(DriveModel.data.players_info) do
			if v.player_action and v.seat_num == DriveModel.data.seat_num then
				TipsShowUpText.Create("操作执行中")
				break
			elseif v.player_action and v.seat_num ~= DriveModel.data.seat_num then
				TipsShowUpText.Create("对方回合")
				break
			end
		end
	end
	if not click_b then return end

	--上滑取消
	local up_pos = self:ScreenToWorldPoint(data.position)
	if up_pos.y - go.transform.position.y > cancel_move_y then
		TipsShowUpText.Create("操作取消")
		if self.DOTProcesse then
			self.DOTProcesse:Kill()
			self.DOTProcesse = nil
		end
		if self.DOTRoation then
			self.DOTRoation:Kill()
			self.DOTRoation = nil
		end
		self:SetPointerProgress(min_euler_z)
		self:SetState(State.all)
		click_b = false
		return
	end

	if self.state ~= State.on then
		return
	end
	if not self.cur_euler_z then
		self.cur_euler_z = self.start_euler_z
	end
	if self.cur_euler_z > center_euler then
		self.op_type = OPType.small
		-- AudioManager.PlaySound(audio_config.drive.com_main_map_shifangxiaoyoumen.audio_name)
		self.slow.gameObject:SetActive(true)
		self.fast.gameObject:SetActive(false)
	else
		-- AudioManager.PlaySound(audio_config.drive.com_main_map_shifangdayoumen.audio_name)
		self.op_type = OPType.big
		self.slow.gameObject:SetActive(false)
		self.fast.gameObject:SetActive(true)
	end

	if not self.op_type then
		return
	end
	if self.DOTRoation then
		self.DOTRoation:Pause()
	end
	DriveModel.SendRequest("drive_game_player_op_req",{op_type = self.op_type})
	if self.op_type == OPType.big then
		if IsEquals(self.songkai_guang_kuai) then
			self.songkai_guang_kuai.gameObject:SetActive(false)
			self.songkai_guang_kuai.gameObject:SetActive(true)
		end
	elseif self.op_type == OPType.small then
		if IsEquals(self.songkai_guang_man) then
			self.songkai_guang_man.gameObject:SetActive(false)
			self.songkai_guang_man.gameObject:SetActive(true)
		end
	else
		if IsEquals(self.songkai_guang) then
			self.songkai_guang.gameObject:SetActive(false)
			self.songkai_guang.gameObject:SetActive(true)
		end
	end

	Event.Brocast("guide_step_complete")
	Event.Brocast("guide_step_trigger")
end

function M:SetPointerProgress(cur_euler_z)
	if not IsEquals(self.transform) then return end
	if cur_euler_z then
		-- self.cur_euler_z = cur_euler_z
		self.progress_img.fillAmount = math.abs(cur_euler_z / 360)
		self.pointer.transform.localRotation = Quaternion:SetEuler(0,0,cur_euler_z)
		return
	end

	if not self.cur_euler_z then
		self.cur_euler_z = min_euler_z
	end
	if self.state == State.on then
		if self.cur_euler_z > center_euler then
			self.slow_bg_color.gameObject:SetActive(true)
			self.fast_bg_color.gameObject:SetActive(false)
		else
			self.slow_bg_color.gameObject:SetActive(false)
			self.fast_bg_color.gameObject:SetActive(true)
		end
	end
	self.progress_img.fillAmount = math.abs(self.cur_euler_z / 360)
	self.pointer.transform.localRotation = Quaternion:SetEuler(0,0,self.cur_euler_z)
end

function M:ProcesseAni(start_v,end_v)
	start_v = start_v or min_euler_z
	end_v = end_v or self.cur_euler_z
	end_v = end_v or max_euler_z

	local cur_euler_z = start_v

	if self.progress_img.fillAmount == math.abs(cur_euler_z / 360) then return end

	local time_coefficient = 4 / 360 --计算时间系数，转过每一度所需时间
	local duration = math.abs((end_v - start_v) * time_coefficient)
	self.DOTProcesse = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
			function(value)
				cur_euler_z = start_v
				self.progress_img.fillAmount = math.abs(cur_euler_z / 360)
                return cur_euler_z
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				cur_euler_z = value
				self.progress_img.fillAmount = math.abs(cur_euler_z / 360)
            end
        ),
        end_v,
		duration
	)
	self.DOTProcesse:SetEase(Enum.Ease.Linear)
end

function M:RoationAni(duration,is_loop)
	if self.DOTShakesRoation then
		self.DOTShakesRoation:Kill()
	end
	self.DOTShakesRoation = nil
	-- dump({start_euler_z = self.start_euler_z,min_euler_z = self.min_euler_z,end_euler_z = self.end_euler_z,max_euler_z = self.max_euler_z,cur_euler_z = self.cur_euler_z},"<color=></color>")
	if self.start_euler_z == self.min_euler_z and self.end_euler_z == self.max_euler_z then
		--转动数据相同不需要重启转动动画
		return
	end

	if self.DOTRoation then
		self.DOTRoation:Kill()
	end

	self.start_euler_z = self.min_euler_z
	self.end_euler_z = self.max_euler_z

	if self.start_euler_z == self.end_euler_z then
		--最大最小值相同直接设置
		self:SetPointerProgress()
		return
	end

	self.cur_euler_z = self.start_euler_z
	local time_coefficient = (3.6 + 1.8) / 360 --计算时间系数，转过每一度所需时间
	local duration = duration or math.abs((self.end_euler_z - self.start_euler_z) * time_coefficient)
	duration = 1
	self.DOTRoation = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
			function(value)
				self.cur_euler_z = self.start_euler_z
				self:SetPointerProgress(self.cur_euler_z)
                return self.start_euler_z
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				self.cur_euler_z = value
				if self.cur_euler_z > center_euler then
					self.slow_bg_color.gameObject:SetActive(true)
					self.fast_bg_color.gameObject:SetActive(false)
				else
					self.slow_bg_color.gameObject:SetActive(false)
					self.fast_bg_color.gameObject:SetActive(true)
				end
				self:SetPointerProgress(self.cur_euler_z)
            end
        ),
        self.end_euler_z,
		duration
	)
	if is_loop then
		self.DOTRoation:SetLoops(-1,Enum.LoopType.Yoyo)
	end
	self.DOTRoation:SetEase(Enum.Ease.Linear)
end

function M:ResetRoationAni()
	if self.DOTRoation then
		self.DOTRoation:Kill()
	end
	self.DOTRoation = nil

	if self.DOTResetRoation then return end

	self.start_euler_z = self.min_euler_z
	self.end_euler_z = self.max_euler_z
	if not self.cur_euler_z then
		self.cur_euler_z = self.start_euler_z
	end

	if self.cur_euler_z == self.start_euler_z then
		--当前值最小值相同直接设置
		self:SetPointerProgress()
		return
	end

	local time_coefficient = 3.6 / 360 --计算时间系数，转过每一度所需时间
	local duration = 0.4
	-- duration = (self.cur_euler_z - self.start_euler_z) * time_coefficient
	self.DOTResetRoation = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
			function(value)
				self:SetPointerProgress()
                return self.cur_euler_z
            end
        ),
        DG.Tweening.Core.DOSetter_float(
            function(value)
				self.cur_euler_z = value
				self:SetPointerProgress()
            end
        ),
        self.start_euler_z,
		duration
	)
	self.DOTResetRoation:SetEase(Enum.Ease.Linear)
end

function M:ShakesRoationAni()
	if self.DOTShakesRoation then
		self.DOTShakesRoation:Kill()
	end
	self.DOTShakesRoation = nil
	local duration = 0.2
	self.DOTShakesRoation = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
			function(value)
				self:SetPointerProgress(self.min_euler_z)
                return self.min_euler_z
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				self:SetPointerProgress(value)
            end
        ),
        self.min_euler_z - 5,
		duration
	)
	self.DOTShakesRoation:SetLoops(-1,Enum.LoopType.Yoyo)
	self.DOTShakesRoation:SetEase(Enum.Ease.Linear)
end

function M:KillAllDotween()
	if self.DOTResetRoation then
		self.DOTResetRoation:Kill()
	end
	self.DOTResetRoation = nil
	if self.DOTShakesRoation then
		self.DOTShakesRoation:Kill()
	end
	self.DOTShakesRoation = nil
	if self.DOTRoation then
		self.DOTRoation:Kill()
	end
	self.DOTRoation = nil
end

function M:SetState(state)
	if not IsEquals(self.transform) then return end
	self.state  = state
	self:KillAllDotween()
	dump(state,"<color=white>当前油门状态？？？？？</color>")
	--再来一次技能改变状态后，油门相当于在all状态下
	if state == State.all or state == State.skill_again then
		self.min_euler_z = min_euler_z
		self.max_euler_z = max_euler_z
		self.op_type = nil
		self.guang.gameObject:SetActive(true)
		self.go.gameObject:SetActive(true)
		self.go_di.gameObject:SetActive(false)
		self.start_btn.transform:GetComponent("Image").sprite = GetTexture("zd_btn_ybp01_map3")
		

		self.slow.gameObject:SetActive(false)
		self.fast.gameObject:SetActive(false)
		self.slow_bg_color.gameObject:SetActive(false)
		self.fast_bg_color.gameObject:SetActive(false)

		self.progress_img.fillAmount = 0
		self:ShakesRoationAni()
	elseif state == State.big then
		self.min_euler_z = -180
		self.max_euler_z = max_euler_z
		self.op_type = OPType.big
		self.guang.gameObject:SetActive(true)
		self.go.gameObject:SetActive(true)
		self.go_di.gameObject:SetActive(false)
		self.start_btn.transform:GetComponent("Image").sprite = GetTexture("zd_btn_ybp01_map3")
		

		self.slow.gameObject:SetActive(false)
		self.fast.gameObject:SetActive(false)
		self.slow_bg_color.gameObject:SetActive(false)
		self.fast_bg_color.gameObject:SetActive(false)

		self.progress_img.fillAmount = 0
		self:ShakesRoationAni()
	elseif state == State.small then
		self.min_euler_z = min_euler_z
		self.max_euler_z = -180
		self.op_type = OPType.small
		self.guang.gameObject:SetActive(true)
		self.go.gameObject:SetActive(true)
		self.go_di.gameObject:SetActive(false)
		self.start_btn.transform:GetComponent("Image").sprite = GetTexture("zd_btn_ybp01_map3")
		

		self.slow.gameObject:SetActive(false)
		self.fast.gameObject:SetActive(false)
		self.slow_bg_color.gameObject:SetActive(false)
		self.fast_bg_color.gameObject:SetActive(false)

		self.progress_img.fillAmount = 0
		self:ShakesRoationAni()
	elseif state == State.off then
		self.min_euler_z = min_euler_z
		self.max_euler_z = min_euler_z
		self.start_euler_z = nil
		self.end_euler_z = nil
		self.op_type = nil
		self.guang.gameObject:SetActive(false)
		self.go.gameObject:SetActive(false)
		self.go_di.gameObject:SetActive(true)
		self.start_btn.transform:GetComponent("Image").sprite = GetTexture("zd_btn_ybp02_map3")
		

		self.slow.gameObject:SetActive(false)
		self.fast.gameObject:SetActive(false)
		self.slow_bg_color.gameObject:SetActive(false)
		self.fast_bg_color.gameObject:SetActive(false)

		self.progress_img.fillAmount = 0
		self:ResetRoationAni()
	elseif state == State.on then
		self.min_euler_z = self.min_euler_z or min_euler_z
		self.max_euler_z = self.max_euler_z or max_euler_z
		self.start_euler_z = nil
		self.end_euler_z = nil
		self.op_type = nil
		self.guang.gameObject:SetActive(false)
		self.go.gameObject:SetActive(false)
		self.go_di.gameObject:SetActive(false)
		self.start_btn.transform:GetComponent("Image").sprite = GetTexture("zd_btn_ybp01_map3")
		self:SetPointerProgress()
	end
end

function M:MyRefresh()
	self:SetStyle()
	--因技能改变了这次的状态 不刷新
	if self.state == State.skill_again then
		return
	end
	if not DriveModel.data
	or not DriveModel.data.game_status
	or not DriveModel.data.game_status == DriveModel.GameStatus.gaming
	or not DriveModel.data.players_info 
	or not DriveModel.data.seat_num then
		self:SetState(State.off)
		return 
	end

	local player_action = DriveModel.data.players_info[DriveModel.data.seat_num].player_action
	dump(player_action,"<color=white>刷新油门 player_action</color>")
	local player_op = DriveModel.data.players_info[DriveModel.data.seat_num].player_op
	dump(player_op,"<color=white>刷新油门 player_op</color>")

	if player_action and not player_op then
		if player_action.op_type == OPType.big then
			if self.cur_euler_z == self.min_euler_z then
				self.cur_euler_z = -240
			end
		elseif player_action.op_type == OPType.small then
			if self.cur_euler_z == self.min_euler_z then
				self.cur_euler_z = -120
			end
		end
		self:SetState(State.on)
		return
	end

	if not player_op then
		self:SetState(State.off)
		return
	end

	if player_op.op_type == DriveModel.OPType.accelerator_all then
		--所有油门
		self:SetState(State.all)
	elseif player_op.op_type == DriveModel.OPType.accelerator_big then
		--大油门
		self:SetState(State.big)
		Event.Brocast("guide_step_complete")
		Event.Brocast("guide_step_trigger")
	elseif player_op.op_type == DriveModel.OPType.accelerator_small then
		--小油门
		self:SetState(State.small)
		Event.Brocast("guide_step_complete")
		Event.Brocast("guide_step_trigger")
	end
end

function M:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end

function M:on_model_drive_game_player_op_req_response(data)
	dump(data,"<color=yellow>油门刷新 drive_game_player_op_req_response</color>")
	if not data.op_type then return end
	if not (data.op_type == 2 or data.op_type == 3) then return end
	if data.result ~= 0 then
		self:SetState(State.all)
		return
	end
	self:SetState(State.on)
end

function M:on_view_round_end()
	local player_op = DriveModel.data.players_info[DriveModel.data.seat_num].player_op
	if not player_op then
		self:SetState(State.off)
	end
end