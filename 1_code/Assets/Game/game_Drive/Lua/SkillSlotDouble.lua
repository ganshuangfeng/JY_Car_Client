-- 创建时间:2021-03-11
local basefunc = require "Game/Common/basefunc"

SkillSlotDouble = basefunc.class(SkillBase)

local C = SkillSlotDouble

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillSlotDouble.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.buff_create then
            return true
        end
    end
end

function C:OnTriggerBefore()
    AudioManager.PlaySound(audio_config.drive.com_main_lianjizhuangzhi.audio_name)
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    self.obj_datas = self:GetObjs()
    if self.obj_datas and next(self.obj_datas) then
        for i,v in ipairs(self.obj_datas) do
            -- self:PlayObjData(v)
            local modify_value = 0
            local percent_flag = false
            for _k,_v in ipairs(v.buff_create.buff_data.other_data) do 
                if _v.key == "modify_value" then
                    modify_value = _v.value
                end
                if _v.key == "percent_base_type" then
                    percent_flag = true
                end 
            end
            -- if percent_flag then
            --     modify_value = modify_value .. "%"
            -- end
            local fx_pre = newObject("buff_lianji_fx",GameObject.Find("Canvas/LayerLv3").transform)
            fx_pre.transform:Find("buff_fx/@icon_buff_fx/Text"):GetComponent("TMP_Text").text = TMPNormalStringConvertTMPSpriteStr("+")..TMPNormalStringConvertTMPSpriteStr(tostring(modify_value)) 
            fx_pre.transform.position = self.launcher_car:GetUICenterPosition()
            local seq = DoTweenSequence.Create()
            seq:AppendInterval(2)
            seq:AppendCallback(function()
                destroy(fx_pre)
                if self.obj_datas and i == #self.obj_datas then
                    Event.Brocast("slot_skill_create",{skill_id = self.skill_data.skill_id,launcher = self.launcher_car.car_data.seat_num})
                    self:OnActEnd()
                end
            end)
        end
    else
        self:OnActEnd()
    end
end