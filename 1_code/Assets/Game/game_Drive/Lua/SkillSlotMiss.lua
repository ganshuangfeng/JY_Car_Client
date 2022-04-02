-- 创建时间:2021-03-11
local basefunc = require "Game/Common/basefunc"

SkillSlotMiss = basefunc.class(SkillBase)

local C = SkillSlotMiss

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillSlotMiss.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        dump(v)
        if v.buff_create or v.buff_change then
            return true
        end
    end
end

function C:OnTriggerBefore()
    AudioManager.PlaySound(audio_config.drive.com_main_shanbizhuangzhi.audio_name)
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    self.obj_datas = self:GetObjs()
    for i,v in ipairs(self.obj_datas) do
        -- self:PlayObjData(v)
        local modify_value = 0
        local percent_flag = false
        local buff_data = v.buff_create or v.buff_change
        for _k,_v in ipairs(buff_data.buff_data.other_data) do 
            if _v.key == "modify_value" then
                modify_value = _v.value
            end
            if _v.key == "percent_base_type" then
                percent_flag = true
            end 
        end
        if percent_flag then
            modify_value = modify_value .. "%"
        end
        local fx_pre = newObject("buff_shanbi_fx",GameObject.Find("Canvas/LayerLv3").transform)
        fx_pre.transform:Find("buff_fx/@icon_buff_fx/Text"):GetComponent("TMP_Text").text = TMPNormalStringConvertTMPSpriteStr("+") .. TMPNormalStringConvertTMPSpriteStr(modify_value)
        fx_pre.transform.localPosition = self.launcher_car:GetUICenterPosition()
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(1)
        seq:AppendCallback(function()
            --通知底部栏更新技能
            -- Event.Brocast("slot_skill_trigger",self.skill_data)
        end)
        seq:AppendInterval(1)
        seq:AppendCallback(function()
            destroy(fx_pre)
            if self.obj_datas and i == #self.obj_datas then
                Event.Brocast("slot_skill_create",{skill_id = self.skill_data.skill_id,launcher = self.launcher_car.car_data.seat_num})
                self:OnActEnd()
            end
        end)
    end
end

function C:OnChange()
    self.launcher_car = DriveCarManager.GetCarByNo(self.skill_data.owner_id)
    self:OnTriggerBefore()
end