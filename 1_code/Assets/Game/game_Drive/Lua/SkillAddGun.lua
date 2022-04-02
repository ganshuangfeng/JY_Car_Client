-- 创建时间:2021-01-05
-- 技能动画效果类：加血
local basefunc = require "Game/Common/basefunc"

SkillAddGun = basefunc.class(SkillBase)

local C = SkillAddGun
local fx_name = "skill_addhp_upgrade_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAddGun.super.ctor(self,skill_data)
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
    AudioManager.PlaySound(audio_config.drive.com_main_map_xueliangzengjia.audio_name)
    local fx_pre = newObject("paodanqianghua",self.launcher_car.car.transform)
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
    local img_font = "com_img_pdqh_map3"
    if self.skill_cfg.id == 4004 then
        img_font = "com_img_cjpdqh_map3"
    end
    self.obj_datas = self:GetObjs()
    if self.obj_datas and next(self.obj_datas) then
        for i,v in ipairs(self.obj_datas) do
            self:PlayObjData(v)
            DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx",img_font,"",true,self.launcher_car:GetCenterPosition(),function()
                if self.obj_datas and i == #self.obj_datas then
                    self:OnTriggerEnd()
                end
            end,true)
        end
    else
        DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx",img_font,"",true,self.launcher_car:GetCenterPosition(),function()
                self:OnTriggerEnd()
        end,true)
    end
end