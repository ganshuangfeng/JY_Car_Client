-- 创建时间:2021-01-19
-- 技能动画效果类：瞬间移动
local basefunc = require "Game/Common/basefunc"

SkillTransfer = basefunc.class(SkillBase)

local C = SkillTransfer
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillTransfer.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_transfer then
            return true
        end
    end
end

function C:OnTriggerBefore()
    DriveAnimManager.PlaySkillNameFx(GameObject.Find("Canvas/LayerLv3").transform,self.launcher_car:GetUICenterPosition(),self.skill_cfg.name,function()
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
    self.obj_data = self:GetObj()
    self.launcher_car:TransferPosition(self.obj_data.obj_car_transfer.end_pos)
    self:OnTriggerEnd()
end

function C:OnTriggerEnd()
    self:OnActEnd()
end