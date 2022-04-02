local basefunc = require "Game/Common/basefunc"

BuffInvisible = basefunc.class(BuffBase)

local M = BuffInvisible
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffInvisible.super.ctor(self,buff_data)
end

--创建回调
function M:OnCreate()
    dump(self.buff_data,"<color=red>隐身buff创建 buff_data</color>")
    local owner_car
    if self.buff_data.owner_type == 2 then
        owner_car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)        
    end
    local fade_value = 0.5
    if owner_car and owner_car.car_data.seat_num == DriveModel.data.seat_num then
        fade_value = 0
    end
    local seq = DoTweenSequence.Create()
    seq:Append(owner_car.transform:GetComponent("CanvasGroup"):DOFade(fade_value,1))
    seq:AppendCallback(function()
        self:OnTrigger()
    end)
end

--移除回调
function M:OnDead()
    dump(self.buff_data,"<color=red>隐身技能移除 buff_data</color>")
    local owner_car
    if self.buff_data.owner_type == 2 then
        owner_car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    end
    local seq = DoTweenSequence.Create()
    seq:Append(owner_car.transform:GetComponent("CanvasGroup"):DOFade(1,1))
    seq:AppendCallback(function()
        self:PlayObjs()
        self:OnActEnd()
    end)
end