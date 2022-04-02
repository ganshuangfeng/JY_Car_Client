-- 创建时间:2021-01-05
-- 技能动画效果类：电锯强化
local basefunc = require "Game/Common/basefunc"

SkillAddChainsaw = basefunc.class(SkillBase)

local C = SkillAddChainsaw
local fx_name = "skill_addhp_upgrade_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAddChainsaw.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd")  then
            return true
        end
    end
end

function C:OnTriggerBefore()
    if not self.launcher_car.DriveCarFaleli then
        self:OnActEnd()
        return
    end
    AudioManager.PlaySound(audio_config.drive.com_main_map_dianjuqianghua.audio_name)
    local fx_pre = newObject("dianjuqianghua",self.launcher_car.car.transform)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.8)
    seq:AppendCallback(function()
        self:OnTriggerMain()
    end)
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        destroy(fx_pre)
    end)
end

function C:OnTriggerMain()
    local font_img_name = "com_img_djqh_map3"
    if self.skill_cfg and self.skill_cfg.level then
        if self.skill_cfg.level == 1 then
            font_img_name = "com_img_djqh_map3"
        elseif self.skill_cfg.level == 2 then
            font_img_name = "com_img_cjdjqh_map3"
        end
    end
    self.obj_datas = self:GetObjs()
    if self.obj_datas and next(self.obj_datas) then
        for i,v in ipairs(self.obj_datas) do
            self:PlayObjData(v)
            DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx",font_img_name,"",true,self.launcher_car:GetCenterPosition(),function()
                if self.obj_datas and i == #self.obj_datas then
                    self:OnTriggerEnd()
                end
            end,true)
        end
    else
        DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx",font_img_name,"",true,self.launcher_car:GetCenterPosition(),function()
            self:OnTriggerEnd()
        end,true)
    end
end

function C:OnTriggerEnd()
    self:OnActEnd()
end