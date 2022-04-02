-- 创建时间:2021-01-04
-- 技能动画效果类：吸金炸弹
local basefunc = require "Game/Common/basefunc"

SkillAwardBomb = basefunc.class(SkillBase)

local C = SkillAwardBomb

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAwardBomb.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if (v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd"))
            or (v.obj_player_modify_property and v.obj_player_modify_property.modify_key_name == "money")then
            return true
        end
    end
end

function C:OnTriggerBefore()
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    self:OnTriggerEnd()
end

function C:OnTriggerEnd()
    --伤害，金币结算
    self.obj_datas = self:GetObjs()
    for i,v in ipairs(self.obj_datas) do
        local obj_data = v[v.key]
        local modify_value = obj_data.modify_value or 0
        if obj_data.modify_key_name == "hp" or obj_data.modify_key_name =="hd" then
            self:PlayDamageFx(obj_data)
            self.effecter_car:PlayOnAttack(modify_value)
            self:PlayObjData(v)           
        end
    end

    DriveAnimManager.PlayBoomFx(GameObject.Find("Canvas/LayerLv3").transform,self.effecter_car:GetUICenterPosition(),nil,self.skill_cfg.level)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1)
    seq:OnForceKill(function()
        --改变金币
        if self.gold_count then
            ComFlyAnim.Create(2,self.effecter_car:GetUICenterPosition(),self.launcher_car:GetUICenterPosition(),"jing_bi",self.gold_count,function()
                local c = 0
                for i,v in ipairs(self.obj_datas) do
                    if v[v.key].modify_key_name == "money" then
                        c = c + 1
                    end
                end
                local _c = 0
                for i,v in ipairs(self.obj_datas) do
                    if v[v.key].modify_key_name == "money" then
                        _c = _c + 1
                        local modify_value = v[v.key].modify_value or 0
                        local mv = modify_value >=0 and "+" or ""
                        local car = modify_value >=0 and self.launcher_car or self.effecter_car
                        DriveAnimManager.PlayAttributeChangeFx(nil,"zd_icon_jb_1",mv .. modify_value,modify_value >= 0,car:GetCenterPosition(),function()
                            self:PlayObjData(v)
                            if modify_value > 0 then
                                AudioManager.PlaySound(audio_config.drive.com_main_map_addlosegold.audio_name)
                            end
                            if _c == c then
                                self:OnActEnd()
                            end
                        end)
                    end
                end
            end)
        else
            self:OnActEnd()
        end
    end)
end