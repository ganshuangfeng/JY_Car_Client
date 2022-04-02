-- 创建时间:2021-04-16
-- 技能动画效果类：地雷车安装地雷
local basefunc = require "Game/Common/basefunc"

SkillLandmineCarSmall = basefunc.class(SkillBase)

local C = SkillLandmineCarSmall
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillLandmineCarSmall.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd") then
            return true
        end
    end
end

function C:OnTriggerBefore()
    -- DriveAnimManager.PlayNewAttributeChangeFx("normal_text_font_fx",nil,"安装地雷！",true,self.launcher_car:GetCenterPosition())
    self:OnActEnd()
end