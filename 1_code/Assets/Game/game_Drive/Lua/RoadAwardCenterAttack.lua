-- 创建时间:2021-03-11

RoadAwardCenterAttack = basefunc.class(RoadAwardBase)
local M = RoadAwardCenterAttack
M.name = "RoadAwardCenterAttack"

function M.Create(road_award_data,create_cbk)
    return M.New(road_award_data,create_cbk)
end

local rocket_img = {
	[1] = "img_dfdd_",
	[2] = "img_xjdd_"
}

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
	self.animator = self.icon_fashejing.transform:GetComponent("Animator")
	self.animator.enabled = false
	self.rocket_id = 1
	self.obj_name = "发射井"
	self:InitUI()
	if RoadAwardManager.road_award_null_map and RoadAwardManager.road_award_null_map[road_award_data.road_id] then
		RoadAwardManager.road_award_null_map[road_award_data.road_id]:MyExit()
		RoadAwardManager.road_award_null_map[road_award_data.road_id] = nil
	end
end

function M:InitUI()
	self:MyRefresh()
	self:OnCreate()
end

function M:MyRefresh()
	self:RefreshRocket()
end

function M:RefreshRocket()
	--直接换图
	for i = 1,4 do
		self["icon_" .. i .. "_img"].sprite = GetTexture(rocket_img[self.rocket_id] .. i)
	end
end

function M:OnSelectSkill(rocket_id,cbk)
	local seq = DoTweenSequence.Create()
	if rocket_id ~= self.rocket_id then
		seq:AppendCallback(function()
			self:ChangeRocket(rocket_id)
		end)
		seq:AppendInterval(3)
	end
	seq:AppendInterval(0.1)
	seq:AppendCallback(function()
		self:PlayFire()
	end)
	seq:AppendInterval(2)
	seq:AppendCallback(function()
		if cbk then cbk() end
	end)
end

function M:ChangeRocket(rocket_id)
	local seq = DoTweenSequence.Create()
	self.animator.enabled = true
	self.animator:Play("qiehuan",0,0)
	seq:AppendInterval(2)
	seq:AppendCallback(function()
		self.rocket_id = rocket_id
		self:RefreshRocket()
	end)
	seq:AppendInterval(40/60)
	seq:AppendCallback(function()
		self.animator.enabled = false
	end)
end

function M:PlayFire()
	local seq = DoTweenSequence.Create()
	self.animator.enabled = true
	DriveAnimManager.PlayShakeScreen(DriveModel.camera3dParent,5)
	self.animator:Play("fashenjing",0,0)
	AudioManager.PlaySound(audio_config.drive.com_main_map_dongfengdaodan.audio_name)
	seq:AppendInterval(5)
	seq:AppendCallback(function()
		if IsEquals(self.animator) then
			self.animator.enabled = false
		end
	end)
end

function M:PlayNewRocket(rocket_id,cbk)
	if rocket_id then
		self.rocket_id = rocket_id 
	end
	local seq = DoTweenSequence.Create()
	self.animator.enabled = true
	self.animator:Play("chuxian",0,0)
	seq:AppendInterval(1)
	seq:AppendCallback(function()
		if IsEquals(self.animator) then
			self.animator.enabled = false
		end
		if cbk then cbk() end
	end)
end