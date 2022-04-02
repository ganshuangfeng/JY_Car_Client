-- 技能动画效果类：雷暴
local basefunc = require "Game/Common/basefunc"

SkillThunder = basefunc.class(SkillBase)

local C = SkillThunder
local fx_name = "violent_weapon_buff_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillThunder.super.ctor(self,skill_data)
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
    AudioManager.PlaySound(audio_config.drive.com_main_map_addatack.audio_name)
    DriveAnimManager.PlayColorGlowFx(self.launcher_car.car.transform,"jinse",self.skill_cfg.level + 1)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.8)
    seq:AppendCallback(function()
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
    self.obj_datas = self:GetObjs()
    if self.obj_datas and next(self.obj_datas) then
        for i,v in ipairs(self.obj_datas) do
            self:PlayObjData(v)
            DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx","com_img_ld_hy","",true,self.launcher_car:GetCenterPosition(),function()
                if self.obj_datas and i == #self.obj_datas then
                    self:OnTriggerEnd()
                end
            end,true)
        end
    else
        DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx","com_img_ld_hy","",true,self.launcher_car:GetCenterPosition(),function()
            self:OnTriggerEnd()
        end,true)
    end
end