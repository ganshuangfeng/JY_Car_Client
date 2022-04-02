-- 创建时间:2021-02-22
-- 技能动画效果类：坦克车身技能 清除路过的路障
local basefunc = require "Game/Common/basefunc"

SkillTankBody = basefunc.class(SkillBase)

local C = SkillTankBody

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillTankBody.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.road_barrier_change then
            return true
        end
    end
end

function C:OnTriggerBefore()
    self.obj_datas = self:GetObjs()
    for i,v in ipairs(self.obj_datas) do
        RoadBarrierManager.RemoveRoadBarrier(v[v.key].road_barrier_data)
        if self.obj_datas and i == #self.obj_datas then
            self:OnTriggerMain()
        end
    end
end