local basefunc = require "Game/Common/basefunc"

BuffModifyCarSp = basefunc.class(BuffBase)

local M = BuffModifyCarSp
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffModifyCarSp.super.ctor(self,buff_data)
end

--创建回调
function M:OnCreate()
    self.launcher_car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    DriveAnimManager.PlayColorGlowFx(self.launcher_car.car.transform,"qingse",3)
    local modify_value
    for k,v in ipairs(self.buff_data.other_data) do 
        if v.key == "modify_value" then
            modify_value = v.value
        end
    end
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.8)
    seq:AppendCallback(function()
        DriveAnimManager.PlayNewAttributeChangeFx("speed_change_fx_new","com_img_jqs","+" .. modify_value,true,self.launcher_car:GetCenterPosition(),function()
            self:OnTrigger()
        end)
    end)
end