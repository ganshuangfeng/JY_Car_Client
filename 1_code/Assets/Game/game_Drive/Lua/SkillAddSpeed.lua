-- 创建时间:2021-01-05
-- 技能动画效果类：加速度
local basefunc = require "Game/Common/basefunc"

SkillAddSpeed = basefunc.class(SkillBase)

local C = SkillAddSpeed
local fx_name = "skill_pressure_speed_up"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAddSpeed.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and v.obj_car_modify_property.modify_key_name == "sp"  then
            return true
        end
    end
end


function C:OnTriggerBefore()
    AudioManager.PlaySound(audio_config.drive.com_main_map_addspeed.audio_name)
    DriveAnimManager.PlayColorGlowFx(self.launcher_car.car.transform,"qingse",self.skill_cfg.level + 1)
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
                modify_key_name = "sp",
                modify_value = 0
            }
        }
    end
    for i,v in ipairs(self.obj_datas) do
        self:PlayObjData(v)
        local modify_value = v[v.key].modify_value or 0
        if v[v.key].modify_type == 2 then
            modify_value = modify_value .. "%"
        end
        DriveAnimManager.PlayNewAttributeChangeFx("speed_change_fx_new","com_img_jqs","+" .. modify_value,true,self.launcher_car:GetCenterPosition(),function()
            if self.obj_datas and i == #self.obj_datas then
                self:OnTriggerEnd()
            end
        end)
    end
end