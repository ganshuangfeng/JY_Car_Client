-- 创建时间:2021-01-04
-- 技能动画效果类：吸金炸弹
local basefunc = require "Game/Common/basefunc"

SkillDFRocketGold = basefunc.class(SkillBase)

local C = SkillDFRocketGold

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillDFRocketGold.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_player_modify_property then
            return true
        end
    end
end

function C:OnTriggerBefore()
    self.lab_center = RoadAwardManager.GetRoadAward(DriveMapManager.ServerPosConversionRoadId (self.skill_data.pos))
    self:OnTriggerMain()
end

local down_time = 1

function C:OnTriggerMain()
    self.lab_center:OnSelectSkill(2,function()
        self:PlayRocketAttack()
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(down_time)
        seq:AppendCallback(function()
            self:OnTriggerEnd()
        end)
    end)
end

function C:PlayRocketAttack()
    local fx_pre = newObject("gold_rocket_fx",GameObject.Find("Canvas/LayerLv3").transform)
    local effecter_pos = self.effecter_car:GetCenterPosition()
    local boom_pre = newObject("daodan_jinqianzhadan_baozha",GameObject.Find("Canvas/LayerLv3").transform)
    boom_pre.transform.position = DriveModel.Get3DTo2DPoint(self.effecter_car:GetCenterPosition())
    boom_pre.gameObject:SetActive(false)
    fx_pre.transform.position = DriveModel.Get3DTo2DPoint(Vector3.New(effecter_pos.x,effecter_pos.y + 30,0))
    local seq = DoTweenSequence.Create()
    seq:Append(fx_pre.transform:DOMoveY(effecter_pos.y + 1,down_time):SetEase(Enum.Ease.InCubic))
    seq:Join(fx_pre.transform:DOScale(Vector3.New(1,1,1),down_time):SetEase(Enum.Ease.InCubic))
    seq:AppendCallback(function()
        -- DriveAnimManager.PlayShakeScreen(DriveModel.camera3dParent,1,Vector3.New(0.5,0.5,0))
        boom_pre.gameObject:SetActive(true)
        destroy(fx_pre)
    end)
    seq:AppendInterval(2)
    seq:AppendCallback(function()
        destroy(boom_pre)
    end)
end

function C:OnTriggerEnd()
    --伤害，金币结算
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.5)
    seq:OnForceKill(function()
        --改变金币
        ComFlyAnim.Create(5,DriveModel.Get3DTo2DPoint(self.effecter_car.transform.position),DriveModel.Get3DTo2DPoint(self.launcher_car.transform.position),"jing_bi",self.gold_count,function()
            self.obj_datas = self:GetObjs()
            for i,v in ipairs(self.obj_datas) do
                self:PlayObjData(v)
                local modify_value = v[v.key].modify_value or 0
                local b = modify_value >=0
                local mv = b and "+" or ""
                local car = b and self.launcher_car or self.effecter_car
                DriveAnimManager.PlayAttributeChangeFx(nil,"zd_icon_jb_1",mv .. modify_value,b,car:GetCenterPosition(),function()
                    if modify_value > 0 then
                        AudioManager.PlaySound(audio_config.drive.com_main_map_addlosegold.audio_name)
                    end
                    if self.obj_datas and i == #self.obj_datas then
                        self:OnActEnd()
                    end
                end)
            end
        end)
        self.lab_center:PlayNewRocket(2)
    end)
end