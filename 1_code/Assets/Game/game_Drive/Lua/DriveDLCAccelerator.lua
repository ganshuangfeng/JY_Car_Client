local basefunc = require "Game/Common/basefunc"

DriveDLCAccelerator = basefunc.class()
local M = DriveDLCAccelerator
M.name = "DriveDLCAccelerator"
local State = {
	all = "all",
	big = "big",
	small = "small",
	off = "off",
	on = "on",
	skill_again = "skill_again",	--再来一次技能改变油门状态
}

local OPType = {
	big = 2, --大油门
	small = 3, --小油门
}

local instance
function M.Create(parent)
	if instance then
		instance:MyExit()
	end
	instance = M.New(parent)
	return instance
end

function M.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M.Refresh()
	if instance then
		instance:MyRefresh()
		return
	end
	M.Create()
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
	self.listener["refresh_dlc_storage"] = basefunc.handler(self,self.on_refresh_dlc_storage)
	self.listener["car_move_end"] = basefunc.handler(self,self.on_car_move_end)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:ctor(parent)

	self:MakeListener()
	self:AddListener()
	self:InitUI(parent)
	self:MyRefresh()
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
	self.big_btn.onClick:AddListener(function()
		self:OnBigClick()
	end)
	self.small_btn.onClick:AddListener(function()
		self:OnSmallClick()
	end)
	EventTriggerListener.Get(self.big_btn.gameObject).onDown = basefunc.handler(self, self.BigOnDown)
	EventTriggerListener.Get(self.big_btn.gameObject).onUp = basefunc.handler(self, self.BigOnUp)
	self.accelerator = DriveAccelerator.RawCreate(self.acc_parent)
	self.accelerator.transform.localPosition = Vector3.zero
end

function M:OnSmallClick()
	DriveModel.SendRequest("drive_game_player_op_req",{op_type = OPType.small})
end
function M:OnBigClick()
	local player_op = DriveModel.data.players_info[DriveModel.data.seat_num].player_op
	if self.big_btn.interactable and player_op and (player_op.op_type == DriveModel.OPType.accelerator_all 
		or player_op.op_type == DriveModel.OPType.accelerator_big 
		or player_op.op_type == DriveModel.OPType.accelerator_small) then
		self.anniu_sound_key = AudioManager.PlaySound(audio_config.drive.com_main_map_leianniu.audio_name,-1)
		self.lei_anniu.gameObject:SetActive(true)
	end
	DriveModel.SendRequest("drive_game_player_op_req",{op_type = 13})
end

function M:MyRefresh()
	self.accelerator:MyRefresh()
end

function M:BigOnUp()
end

function M:BigOnDown()
end

function M:on_car_move_end(data)
	if self.anniu_sound_key then
		AudioManager.CloseSound(self.anniu_sound_key)
		self.anniu_sound_key = nil
	end
	self.lei_anniu.gameObject:SetActive(false)
end

function M:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end

function M:on_refresh_dlc_storage(data)
	if data and data.owner_id and DriveCarManager.GetCarByNo(data.owner_id) and DriveCarManager.GetCarByNo(data.owner_id).car_data.seat_num == DriveModel.data.seat_num then
		self.storage_txt.text = data.mine_num .. " / " .. data.max_mine_num
		self.storage_progress.transform:GetComponent("Image").fillAmount = data.mine_num / data.max_mine_num
		if tonumber(data.mine_num) <= 0 then
			self.big_btn.interactable = false
		else
			self.big_btn.interactable = true
		end
	end
end