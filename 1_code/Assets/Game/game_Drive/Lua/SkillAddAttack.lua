-- 创建时间:2021-01-05
-- 技能动画效果类：加攻击
local basefunc = require "Game/Common/basefunc"

SkillAddAttack = basefunc.class(SkillBase)

local C = SkillAddAttack
local fx_name = "violent_weapon_buff_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAddAttack.super.ctor(self,skill_data)
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
    DriveAnimManager.PlayColorGlowFx(self.launcher_car.car.transform,"hongse",self.skill_cfg.level + 1)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.8)
    seq:AppendCallback(function()
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
    self.obj_datas = self:GetObjs()
    if not self.obj_datas or not next(self.obj_datas) then
        self.obj_datas = {}
        self.obj_datas[1] = {
            key = "obj_car_modify_property",
            obj_car_modify_property = {
                modify_key_name = "at",
                modify_value = 0
            }
        }
    end

    for i,v in ipairs(self.obj_datas) do
        self:PlayObjData(v)
        local modify_value = v[v.key].modify_value or 0
        local end_value = v[v.key].end_value
        if v[v.key].modify_type == 2 then
            if end_value then
                modify_value = math.floor((100 * modify_value / (end_value - modify_value) + 0.5)) .. "%"
            else
                modify_value = modify_value .. "%"
            end
        end
        DriveAnimManager.PlayNewAttributeChangeFx(nil,"com_img_gj","+" .. modify_value,true,self.launcher_car:GetCenterPosition(),function()
            if self.obj_datas and i == #self.obj_datas then
                self:OnTriggerEnd()
            end
        end)
    end
end