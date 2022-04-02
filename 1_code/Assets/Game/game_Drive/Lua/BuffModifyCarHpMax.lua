local basefunc = require "Game/Common/basefunc"

BuffModifyCarHpMax = basefunc.class(BuffBase)

local M = BuffModifyCarHpMax
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffModifyCarHpMax.super.ctor(self,buff_data)
end

--创建回调
function M:OnCreate()
    self.launcher_car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    DriveAnimManager.PlayColorGlowFx(self.launcher_car.car.transform,"lvse",3)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.8)
    seq:AppendCallback(function()
        DriveAnimManager.PlayNewAttributeChangeFx("hp_change_fx","com_img_jsm","+50",true,self.launcher_car:GetCenterPosition(),function()
            self:OnTrigger()
        end)
    end)
end