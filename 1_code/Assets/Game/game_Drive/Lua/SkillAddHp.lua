-- 创建时间:2021-01-05
-- 技能动画效果类：加血
local basefunc = require "Game/Common/basefunc"

SkillAddHp = basefunc.class(SkillBase)

local C = SkillAddHp
local fx_name = "skill_addhp_upgrade_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAddHp.super.ctor(self,skill_data)
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
    DriveAnimManager.PlayColorGlowFx(self.launcher_car.car.transform,"lvse",self.skill_cfg.level + 1)
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
                modify_key_name = "hp",
                modify_value = 0
            }
        }
    end
    for i,v in ipairs(self.obj_datas) do
        self:PlayObjData(v)
        local modify_value = v[v.key].modify_value or 0
        local modify_desc = modify_value
        if v[v.key].modify_type == 2 then
            local total_v = DrivePlayerManager.GetShowAttribute(self.effecter_car.car_data.seat_num,self.effecter_car.car_data.car_id,"hp_max")
            modify_desc = math.floor((modify_value / total_v  * 100) + 0.5) .. "%"
        end
        DriveAnimManager.PlayNewAttributeChangeFx("hp_change_fx","com_img_jsm","+" .. modify_desc,true,self.launcher_car:GetCenterPosition(),function()
            if self.obj_datas and i == #self.obj_datas then
                self:OnTriggerEnd()
            end
        end)
    end
end