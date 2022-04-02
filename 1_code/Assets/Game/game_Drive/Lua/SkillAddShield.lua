-- 创建时间:2021-01-05
-- 技能动画效果类：加护盾
local basefunc = require "Game/Common/basefunc"

SkillAddShield = basefunc.class(SkillBase)

local C = SkillAddShield
local fx_name = "skill_addhp_upgrade_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAddShield.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and v.obj_car_modify_property.modify_key_name == "hd" then
            return true
        end
    end
end

function C:OnTriggerBefore()
    local obj = self:GetObjs()[1]
    local modify_hd_value = 0
    if obj then
        modify_hd_value = obj.obj_car_modify_property.modify_value
    end
    if not IsEquals(self.effecter_car.shield) and modify_hd_value > 0 then
        AudioManager.PlaySound(audio_config.drive.com_main_map_fanghudun.audio_name)
        self.effecter_car.shield = newObject("buff_hudun",self.effecter_car.car.transform)
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(1.5)
        seq:AppendCallback(function()
            self:OnTriggerMain()
        end)
    else
        self:PlayObjs()
        self:OnTriggerEnd()
    end
end

function C:OnTriggerMain()
    self.obj_datas = self:GetObjs()
    if not self.obj_datas or not next(self.obj_datas) then
        self.obj_datas = {}
        self.obj_datas[1] = {
            key = "obj_car_modify_property",
            obj_car_modify_property = {
                modify_key_name = "hd",
                modify_value = 0
            }
        }
    end
    local img_font = "com_img_fhd_map3"
    if self.skill_cfg.id == 1023 then
        img_font = "com_img_cjfhd_map3"
    end
    for i,v in ipairs(self.obj_datas) do
        self:PlayObjData(v)
        local modify_value = v[v.key].modify_value or 0
        DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx",img_font,"",true,self.launcher_car:GetCenterPosition(),function()
            if self.obj_datas and i == #self.obj_datas then
                self:OnTriggerEnd()
            end
        end,true)
    end
end