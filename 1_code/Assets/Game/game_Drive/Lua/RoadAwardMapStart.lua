local basefunc = require "Game/Common/basefunc"

RoadAwardMapStart = basefunc.class(RoadAwardBase)
local M = RoadAwardMapStart
M.name = "RoadAwardMapStart"

function M.Create(road_award_data,create_cbk)
	return M.New(road_award_data,create_cbk)
end

function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:MakeListener()
    self.listener = {}
	self.listener["car_move_to_start_pos"] = basefunc.handler(self,self.OnCarMoveToStartPoint)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:ctor(road_award_data,create_cbk)
	M.super.ctor(self,road_award_data)
	local parent = DriveMapManager.GetMapPrefabByRoadID(road_award_data.road_id,true)
	if not IsEquals(parent) then return end
	parent = parent.transform:Find("skill_node").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	basefunc.GeneratingVar(self.transform, self)
	if RoadAwardManager.road_award_null_map and RoadAwardManager.road_award_null_map[road_award_data.road_id] then
		RoadAwardManager.road_award_null_map[road_award_data.road_id]:MyExit()
		RoadAwardManager.road_award_null_map[road_award_data.road_id] = nil
	end
	self:InitUI()
end

function M:InitUI()
	self:MyRefresh()
	self:OnCreate()
end

function M:MyRefresh()
	self.virtual_circle_start = DriveCarManager.GetVirtualCircle({is_start = true,seat_num = self.seat_num})
	self.virtual_circle_end = DriveCarManager.GetVirtualCircle({seat_num = self.seat_num})
	local cars = DriveCarManager.GetCarBySeat(DriveModel.data.seat_num)
	local car_pos = 0
	for k,v in pairs(cars) do
		car_pos = v.car_data.pos
		break
	end
	self.circle = math.floor(car_pos / DriveMapManager.map_count) + 1
	if not IsEquals(self.gameObject) then return end
	if DriveModel.data.game_status == DriveModel.GameStatus.gaming or DriveModel.data.game_status == DriveModel.GameStatus.game_over then
		-- self.screen_img.gameObject:SetActive(true)
	else
		-- self.screen_img.gameObject:SetActive(false)
	end
	if DriveModel.data.game_status == DriveModel.GameStatus.gaming then
		self.circle_txt.gameObject:SetActive(true)

		if not self.virtual_circle_offset  then
			self.circle_txt.text = self.circle - self.virtual_circle_start

		else
			self.circle_txt.text = self.circle - self.virtual_circle_end
		end

	elseif DriveModel.data.game_status == DriveModel.GameStatus.game_over then
		self.circle_txt.gameObject:SetActive(true)
		if DriveModel.data.settlement_info and DriveModel.data.settlement_info.win_seat_num == DriveModel.data.seat_num then
			self.circle_txt.text = "win"
		else
			if not self.virtual_circle_offset  then
				self.circle_txt.text = self.circle - self.virtual_circle_start
	
			else
				self.circle_txt.text = self.circle - self.virtual_circle_end
			end
		end
	else
		self.circle_txt.gameObject:SetActive(false)
	end
	-- self.screen_img.gameObject:SetActive(false)
	self.circle_txt.gameObject:SetActive(false)

	self.virtual_circle_offset = 0
	self.cur_round_offset = 0
end

function M:OnCarMoveToStartPoint(data)
	if self.virtual_circle_end ~= self.virtual_circle_start then
		self.virtual_circle_offset = self.virtual_circle_offset + 1
	end
	self.cur_round_offset = self.cur_round_offset + 1
	if self.virtual_circle_start + self.virtual_circle_offset > self.virtual_circle_end then
		self.virtual_circle_offset = self.virtual_circle_end - self.virtual_circle_start
	end

	self.circle = math.floor(data.car_data.pos / DriveMapManager.map_count) + 1
	local virtual_circle = self.virtual_circle_start + self.virtual_circle_offset
	if self.cur_round_offset == 1 then
		AudioManager.PlaySound(audio_config.drive.com_main_map_luguoqidian1.audio_name)
	elseif self.cur_round_offset == 2 then
		AudioManager.PlaySound(audio_config.drive.com_main_map_luguoqidian2.audio_name)
	elseif self.cur_round_offset == 3 then
		AudioManager.PlaySound(audio_config.drive.com_main_map_luguoqidian3.audio_name)
	elseif self.cur_round_offset == 4 then
		AudioManager.PlaySound(audio_config.drive.com_main_map_luguoqidian4.audio_name)
	elseif self.cur_round_offset >= 5 then
		AudioManager.PlaySound(audio_config.drive.com_main_map_luguoqidian5.audio_name)
	end
	if IsEquals(self.circle_txt) then
		-- self.screen_img.gameObject:SetActive(true)
		self.circle_txt.gameObject:SetActive(true)
		--动画
		self.circle_txt.gameObject:SetActive(false)
		-- self.circle_txt.text = TMPNormalStringConvertTMPSpriteStr((DriveModel.data.total_round or 60) -  (self.circle - virtual_circle))
		self.circle_txt.text = TMPNormalStringConvertTMPSpriteStr(self.cur_round_offset)
		local obj = GameObject.Instantiate(self.circle_txt.gameObject,self.bg_img.transform)
		obj.transform.localPosition = Vector3.New(0,0.6,0)
		obj.transform.localScale = Vector3.New(0.2,0.2,1)
		obj.gameObject:SetActive(true)
		local fx = self.transform:Find("biejin_deng")
		fx.gameObject:SetActive(false)
		fx.gameObject:SetActive(true)
		local seq = DoTweenSequence.Create()
		seq:Append(obj.transform:DOScale(Vector3.New(1.5,1.5,1),0.4))
		seq:Append(obj.transform:DOScale(Vector3.New(1,1,1),0.05))
		seq:OnForceKill(function()
			destroy(obj.gameObject)
			if IsEquals(self.circle_txt) then
				self.circle_txt.gameObject:SetActive(true)
				-- self.screen_img.gameObject:SetActive(false)
				self.circle_txt.gameObject:SetActive(false)
			end
		end)
	end
end