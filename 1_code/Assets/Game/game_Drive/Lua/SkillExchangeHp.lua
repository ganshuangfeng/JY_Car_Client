-- 创建时间:2021-03-23
-- 技能动画效果类：交换血量
local basefunc = require "Game/Common/basefunc"

SkillExchangeHp = basefunc.class(SkillBase)

local C = SkillExchangeHp
local fx_name = "skill_addhp_upgrade_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillExchangeHp.super.ctor(self,skill_data)
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
    
	self.loop_sound_key = AudioManager.PlaySound(audio_config.drive.com_main_shengmingjiaohuan.audio_name,-1)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(DriveModel.GetTime(DriveModel.time.normal_skill_before_delay))
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
    local fx_bg = newObject("df_common_black_bg",GameObject.Find("Canvas/LayerLv3").transform)
    local fx_pre = newObject("df_hp_exchange_fx",GameObject.Find("Canvas/LayerLv4").transform)

    fx_pre.transform.position = DriveModel.Get3DTo2DPoint(DrivePlayerManager.cur_panel.transform.position)
    local tbl = basefunc.GeneratingVar(fx_pre.transform)
    for i = 1,2 do
        --预制体位置放反了
        local effecter_car = DriveCarManager.GetCarByNo(2 - i + 1)
        local cur_v = DrivePlayerManager.GetShowAttribute(effecter_car.car_data.seat_num,effecter_car.car_data.car_id,"hp")
        local total_v = DrivePlayerManager.GetShowAttribute(effecter_car.car_data.seat_num,effecter_car.car_data.car_id,"hp_max")
        tbl["player_hp_" .. i .. "_txt"].text = cur_v
        tbl["hp_progress_bar_" .. i]:GetComponent("Image").fillAmount = cur_v / total_v
    end
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(DriveModel.GetTime(DriveModel.time.skill_exchange_hp))
    seq:AppendCallback(function()
        for i,v in ipairs(self.obj_datas) do
            self:PlayObjData(v)
        end
        if self.loop_sound_key then
            AudioManager.CloseSound(self.loop_sound_key)
            self.loop_sound_key = nil
        end
        destroy(fx_bg)
        destroy(fx_pre)
        self:OnTriggerEnd()
    end)
end