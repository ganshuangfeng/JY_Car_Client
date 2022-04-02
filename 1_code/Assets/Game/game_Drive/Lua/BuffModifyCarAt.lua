-- 创建时间:2021-01-06
local basefunc = require "Game/Common/basefunc"

BuffModifyCarAt = basefunc.class(BuffBase)

local M = BuffModifyCarAt
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffModifyCarAt.super.ctor(self,buff_data)
end

--创建回调
function M:OnCreate()
    self.launcher_car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    DriveAnimManager.PlayColorGlowFx(self.launcher_car.car.transform,"hongse",3)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.8)
    seq:AppendCallback(function()
        DriveAnimManager.PlayNewAttributeChangeFx(nil,"com_img_gj","+10%",true,self.launcher_car:GetCenterPosition(),function()
            self:OnTrigger()
        end)
    end)
end