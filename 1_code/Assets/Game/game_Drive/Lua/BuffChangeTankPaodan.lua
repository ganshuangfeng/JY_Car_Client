local basefunc = require "Game/Common/basefunc"

BuffChangeTankPaodan = basefunc.class(BuffBase)

local M = BuffChangeTankPaodan
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffChangeTankPaodan.super.ctor(self,buff_data)
end

--刷新回调
function M:OnRefresh()
    local car_data = {
        car_no = self.buff_data.owner_id
    }
    --作用于车
    local car = DriveCarManager.GetCar(car_data)
    if car and car.DriveCarTank then
        car.DriveCarTank.paodan_strengthen = true
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
    if car and car.DriveCarTank then
        car.DriveCarTank.paodan_strengthen = true
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
    if car and car.DriveCarTank then
        car.DriveCarTank.paodan_strengthen = false
    end
    self:PlayObjs()
    self:OnActEnd()
end