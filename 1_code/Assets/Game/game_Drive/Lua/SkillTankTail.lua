-- 创建时间:2021-02-22
-- 技能动画效果类：坦克车尾技能 每回合增加攻击力
local basefunc = require "Game/Common/basefunc"

SkillTankTail = basefunc.class(SkillBase)

local C = SkillTankTail

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillTankTail.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and v.obj_car_modify_property.modify_key_name == "at" then
            return true
        end
    end
end

function C:OnTriggerBefore()
    DriveAnimManager.PlayColorGlowFx(self.effecter_car.car.transform,"jinse",self.skill_cfg.level + 1,function()
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
    self.obj_datas = self:GetObjs()
    for i,v in ipairs(self.obj_datas) do
        self:PlayObjData(v)
        local modify_value = v[v.key].modify_value or 0
        DriveAnimManager.PlayAttributeChangeFx(nil,"zd_icon_gj","+" .. modify_value,true,self.effecter_car:GetCenterPosition(),function()
            if self.obj_datas and i == #self.obj_datas then
                self:OnTriggerEnd()
            end
        end)
    end
end