local basefunc = require "Game/Common/basefunc"

BuffFaleliAddHit = basefunc.class(BuffBase)

local M = BuffFaleliAddHit
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffFaleliAddHit.super.ctor(self,buff_data)
end

--刷新回调
function M:OnRefresh()
    local car_data = {
        car_no = self.buff_data.owner_id
    }
    --作用于车
    local car = DriveCarManager.GetCar(car_data)
    if car and car.DriveCarFaleli then
        car.DriveCarFaleli:SetChainSaw(true)
    end
end

--创建回调
function M:OnCreate()
    dump("buff_create")
    local car_data = {
        car_no = self.buff_data.owner_id
    }
    --作用于车
    local car = DriveCarManager.GetCar(car_data)
    if car and car.DriveCarFaleli then
        car.DriveCarFaleli:SetChainSaw(true)
    end
    self:OnTrigger()
end

--移除回调
function M:OnDead()
    dump("buff_dead")
    local car_data = {
        car_no = self.buff_data.owner_id
    }
    --作用于车
    local car = DriveCarManager.GetCar(car_data)
    if car and car.DriveCarFaleli then
        car.DriveCarFaleli:SetChainSaw(false)
    end
    self:PlayObjs()
    self:OnActEnd()
end