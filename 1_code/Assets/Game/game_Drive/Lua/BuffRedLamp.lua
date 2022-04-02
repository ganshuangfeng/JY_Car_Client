local basefunc = require "Game/Common/basefunc"

BuffRedLamp = basefunc.class(BuffBase)

local M = BuffRedLamp
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffRedLamp.super.ctor(self,buff_data)
end

function M:OnCreate()
    self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    if not self.fx_pre then
        self.fx_pre = newObject("red_lamp_art_font_fx_3d",self.car.transform)
        local seq = DoTweenSequence.Create()
        seq:Append(self.fx_pre.transform:DOLocalMoveY(0.8,1))
        seq:AppendCallback(function()
            self:PlayObjs()
            self:OnTrigger()
        end)
    else
        self:PlayObjs()
        self:OnTrigger()
    end
end

--移除回调
function M:OnDead()
    dump(self.buff_data,"<color=red>红灯技能移除 buff_data</color>")
    if self.fx_pre then
        destroy(self.fx_pre)
        self.fx_pre = nil
    end
    self:PlayObjs()
    self:OnActEnd()
end
