local basefunc = require "Game/Common/basefunc"

RoadAwardCenterRadar = basefunc.class(RoadAwardBase)
local M = RoadAwardCenterRadar
M.name = "RoadAwardCenterRadar"

function M.Create(road_award_data,create_cbk)
	return M.New(road_award_data,create_cbk)
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