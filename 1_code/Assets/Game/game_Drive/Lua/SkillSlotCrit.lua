-- 创建时间:2021-03-11
local basefunc = require "Game/Common/basefunc"

SkillSlotCrit = basefunc.class(SkillBase)

local C = SkillSlotCrit

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillSlotCrit.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.buff_create or v.buff_change then
            return true
        end
    end
end

function C:OnTriggerBefore()
    AudioManager.PlaySound(audio_config.drive.com_main_baojizhuangzhi.audio_name)
    local skill_data = self.skill_data
    if skill_data.process_no then
        local data = DriveLogicProcess.get_process_data_by_father_process_no(skill_data.process_no)
        if data and next(data) then
            for k,v in ipairs(data) do
                if v.buff_create then
                    self.buff_cfg = BuffManager.GetBuffCfgById(v.buff_create.buff_id)
                end
            end
        end
    end
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
        local fx_pre = newObject("buff_baoji_fx",GameObject.Find("Canvas/LayerLv3").transform)
        fx_pre.transform:Find("buff_fx/@icon_buff_fx/Text"):GetComponent("TMP_Text").text = TMPNormalStringConvertTMPSpriteStr("+") .. TMPNormalStringConvertTMPSpriteStr(tostring(modify_value))
        fx_pre.transform.position = DriveModel.Get3DTo2DPoint(self.launcher_car:GetCenterPosition())
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
end

function C:OnChange()
    self.launcher_car = DriveCarManager.GetCarByNo(self.skill_data.owner_id)
    self:OnTriggerBefore()
end