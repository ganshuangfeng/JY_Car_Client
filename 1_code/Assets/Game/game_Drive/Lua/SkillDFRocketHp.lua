-- 创建时间:2021-01-04
-- 技能动画效果类：吸金炸弹
local basefunc = require "Game/Common/basefunc"

SkillDFRocketHp = basefunc.class(SkillBase)

local C = SkillDFRocketHp

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillDFRocketHp.super.ctor(self,skill_data)
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
    
    local skill_data = self.skill_data
    if skill_data.process_no then
        local data = DriveLogicProcess.get_process_data_by_father_process_no(skill_data.process_no)
        if data and next(data) then
            for k,v in ipairs(data) do
                if v.obj_car_modify_property then
                    DriveLogicProcess.set_process_data_use(v.process_no)
                    local obj_car_modify_property = v.obj_car_modify_property
                    dump(obj_car_modify_property,"<color=yellow>炸弹技能的数据：obj_car_modify_property</color>")
                    if obj_car_modify_property and (obj_car_modify_property.modify_key_name == "hp" or obj_car_modify_property.modify_key_name == "hd") then
                        DriveLogicProcess.set_process_data_use(v.process_no)
                        self.damage_count = obj_car_modify_property.modify_value
                        self.damage_obj_data = obj_car_modify_property
                        self.modify_car_no = obj_car_modify_property.car_no
                    end
                end
            end
        end
    end
    self.lab_center = RoadAwardManager.GetRoadAward({road_id = DriveMapManager.ServerPosConversionRoadId (self.skill_data.pos)})

    self:OnTriggerMain()
end

local down_time = 1

function C:OnTriggerMain()
    if self.lab_center and self.lab_center.OnSelectSkill then
        self.lab_center:OnSelectSkill(1,function()
            self:PlayRocketAttack()
            local seq = DoTweenSequence.Create()
            seq:AppendInterval(down_time)
            seq:AppendCallback(function()
                self:OnTriggerEnd()
            end)
        end)
    else
        self:PlayRocketAttack()
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(down_time)
        seq:AppendCallback(function()
            self:OnTriggerEnd()
        end)
    end
end

function C:PlayRocketAttack()
    local fx_pre = newObject("df_rocket_fx",GameObject.Find("Canvas/LayerLv3").transform)
    local effecter_pos = self.effecter_car:GetUICenterPosition()
    local boom_pre = newObject("daodan_baozha",GameObject.Find("Canvas/LayerLv3").transform)
    boom_pre.transform.localPosition = self.effecter_car:GetUICenterPosition()
    boom_pre.gameObject:SetActive(false)
    fx_pre.transform.localPosition = Vector3.New(effecter_pos.x,effecter_pos.y + 3000,0)
    local seq = DoTweenSequence.Create()
    seq:Append(fx_pre.transform:DOLocalMoveY(effecter_pos.y + 100,down_time):SetEase(Enum.Ease.InCubic))
    seq:Join(fx_pre.transform:DOScale(Vector3.New(1,1,1),down_time):SetEase(Enum.Ease.InCubic))
    seq:AppendCallback(function()
        AudioManager.PlaySound(audio_config.drive.com_main_map_dongfengdaodan1.audio_name)
        -- DriveAnimManager.PlayShakeScreen(DriveModel.camera3dParent,1,Vector3.New(0.5,0.5,0))
        boom_pre.gameObject:SetActive(true)
        destroy(fx_pre)
    end)
    seq:AppendInterval(1.8)
    seq:AppendCallback(function()
        destroy(boom_pre)
    end)
end

function C:OnTriggerEnd()
    --伤害，金币结算
    self.obj_datas = self:GetObjs()
    for i,v in ipairs(self.obj_datas) do
        self:PlayDamageFx(v.obj_car_modify_property)
        self.effecter_car:PlayOnAttack(v.obj_car_modify_property.modify_value)
        self:PlayObjData(v)

        DriveAnimManager.PlayBoomFx(GameObject.Find("Canvas/LayerLv3").transform,self.effecter_car:GetUICenterPosition(),nil,self.skill_cfg.level)
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(1)
        seq:OnForceKill(function()
            if self.lab_center and self.lab_center.PlayNewRocket then
                self.lab_center:PlayNewRocket(1,function()
                    if self.obj_datas and i == #self.obj_datas then
                        self:OnActEnd()
                    end
                end)
            else
                if self.obj_datas and i == #self.obj_datas then
                    self:OnActEnd()
                end
            end
        end)
    end
end