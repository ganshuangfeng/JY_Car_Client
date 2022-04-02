-- 创建时间:2021-01-05
-- 技能动画效果类：加速度
local basefunc = require "Game/Common/basefunc"

SkillAddSpeedExtra = basefunc.class(SkillBase)

local C = SkillAddSpeedExtra
local fx_name = "skill_pressure_speed_up"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAddSpeedExtra.super.ctor(self,skill_data)
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
    if true then
        DriveAnimManager.PlayNewAttributeChangeFx("speed_double_fx",nil,nil,true,self.launcher_car:GetCenterPosition(),function()
            self:PlayObjs()
            self:OnTriggerEnd()
        end)
        return
    end
    for i,v in ipairs(self.obj_datas) do
        self:PlayObjData(v)
        local modify_value = v[v.key].modify_value or 0
        local modify_desc = modify_value
        if v[v.key].modify_type == 2 then
            local total_v = DrivePlayerManager.GetShowAttribute(self.effecter_car.car_data.seat_num,self.effecter_car.car_data.car_id,"hp_max")
            modify_desc = math.floor(modify_value / total_v  * 100) .. "%"
        end
        DriveAnimManager.PlayNewAttributeChangeFx("speed_change_fx_new","com_img_jqs","+" .. modify_value,true,self.launcher_car:GetCenterPosition(),function()
            if self.obj_datas and i == #self.obj_datas then
                DriveAnimManager.PlayNewAttributeChangeFx("speed_double_fx",nil,nil,true,self.launcher_car:GetCenterPosition(),function()
                    self:OnTriggerEnd()
                end)
            end
        end)
    end
end