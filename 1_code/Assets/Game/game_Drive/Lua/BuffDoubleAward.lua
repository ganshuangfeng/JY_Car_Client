local basefunc = require "Game/Common/basefunc"

BuffDoubleAward = basefunc.class(BuffBase)

local M = BuffDoubleAward
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffDoubleAward.super.ctor(self,buff_data)
end

--移除回调
function M:OnDead()
    self:ClearDoubleAwardIconMap()
    self:PlayObjs()
    self:OnActEnd()
end

function M:MyExitSubclass()
    self:ClearDoubleAwardIconMap()
end

--刷新时回调
function M:OnRefresh()
    -- if self.buff_data.act ~= BuffManager.act_enum.dead then
    --     local owner_car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    --     local player_op = DriveModel.data.players_info[owner_car.car_data.seat_num].player_op
    --     if player_op then
    --         self:CreateDoubleAward()
    --     else
    --         self:ClearDoubleAwardIconMap()
    --     end
	-- end
end

function M:CreateDoubleAward()
    self:ClearDoubleAwardIconMap()
    for road_id,v in pairs(RoadAwardManager.road_award_map) do 
        if v and next(v) then
            local road_award = v[next(v)]
            if road_award.name == "RoadAwardNormal" then
                if road_award.road_award_cfg and road_award.road_award_cfg.key ~= "zailaiyici" then
                    self.double_award_icon_map[road_id] = newObject("buff_double_award_icon",road_award.transform)
                end
            end
        end
    end
end

function M:ClearDoubleAwardIconMap()
    if self.double_award_icon_map then
        for k,v in pairs(self.double_award_icon_map) do 
            destroy(v)
        end
    end
    self.double_award_icon_map = {}
end