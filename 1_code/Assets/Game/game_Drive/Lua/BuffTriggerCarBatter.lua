local basefunc = require "Game/Common/basefunc"

BuffTriggerCarBatter = basefunc.class(BuffBase)

local M = BuffTriggerCarBatter
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffTriggerCarBatter.super.ctor(self,buff_data)
end

--移除回调
function M:OnDead()
    dump(self.buff_data,"<color=red>连击技能移除 buff_data</color>")
    if self.fx_pre then
        destroy(self.fx_pre)
        self.fx_pre = nil
    end
    self:PlayObjs()
    self:OnActEnd()
end

--刷新时回调
function M:OnRefresh()
    if not self.fx_pre and self.buff_data.act ~= BuffManager.act_enum.dead then
        self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
        self.fx_pre = newObject("lj_fx_pre_3d",self.car.transform)
	end
end