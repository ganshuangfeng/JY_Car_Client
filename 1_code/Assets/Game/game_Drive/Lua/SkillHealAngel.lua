-- 创建时间:2021-04-23
-- 技能动画效果类：恢复天使
local basefunc = require "Game/Common/basefunc"

SkillHealAngel = basefunc.class(SkillBase)

local C = SkillHealAngel
local fx_name = "skill_addhp_upgrade_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillHealAngel.super.ctor(self,skill_data)
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
    -- local fx_pre_1 = newObject("huanjingzhongxin",GameObject.Find("Canvas/LayerLv3").transform)
    AudioManager.PlaySound(audio_config.drive.com_main_map_huifutianshi.audio_name)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.5)
    -- seq:AppendCallback(function()
    --     destroy(fx_pre_1)
    -- end)
    local fx_pre = newObject("huifutianshi",GameObject.Find("3DNode").transform)
    fx_pre.gameObject:SetActive(false)
    seq:AppendCallback(function()
        fx_pre.gameObject:SetActive(true)
    end)
    seq:AppendInterval(2)
    seq:AppendCallback(function()
        self:OnTriggerMain()
    end)
    seq:AppendInterval(3)
    seq:OnForceKill(function()
        destroy(fx_pre)
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
                modify_value = 0,
                car_no = 1,
            }
        }
        self.obj_datas[2] = {
            key = "obj_car_modify_property",
            obj_car_modify_property = {
                modify_key_name = "hp",
                modify_value = 0,
                car_no = 2,
            }
        }
    end
    for i,v in ipairs(self.obj_datas) do
        local effecter_car = DriveCarManager.GetCarByNo(v[v.key].car_no)
        DriveAnimManager.PlayColorGlowFx(effecter_car.car.transform,"lvse",self.skill_cfg.level + 1)
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(0.8)
        seq:AppendCallback(function()
            self:PlayObjData(v)
            local modify_value = v[v.key].modify_value or 0
            local modify_desc = modify_value
            if v[v.key].modify_type == 2 then
                local total_v = DrivePlayerManager.GetShowAttribute(effecter_car.car_data.seat_num,effecter_car.car_data.car_id,"hp_max")
                modify_desc = math.floor(modify_value / total_v  * 100) .. "%"
            end
            DriveAnimManager.PlayNewAttributeChangeFx("hp_change_fx","com_img_jsm","+" .. modify_desc,true,effecter_car:GetCenterPosition(),function()
                if self.obj_datas and i == #self.obj_datas then
                    AudioManager.PlayOldBGM()
                    self:OnTriggerEnd()
                end
            end)
        end)
    end
end