-- 创建时间:2021-02-22
-- 技能动画效果类：坦克big技能
local basefunc = require "Game/Common/basefunc"

SkillTankBig = basefunc.class(SkillBase)

local C = SkillTankBig

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillTankBig.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd")  then
            return true
        end
    end
end

function C:MyExitSubclass()
    self:PlayScreenBorken(false)
end

function C:OnTriggerBefore()
    DriveAnimManager.PlayBigSkillNameFx("com_img_hlqk_map3",self.launcher_car:GetCenterPosition(),function()
        -- set_order_in_layer(self.launcher_car.car,2)
        AudioManager.PlayOldBGM()
        self:OnTriggerMain()
    end)
    local skill_datas = SkillManager.GetSkillByOwner({owner_type = self.skill_data.owner_type,owner_id = self.skill_data.owner_id})
    for k,v in pairs(skill_datas) do 
        if v.tank_head_bullet then
            self.bullet_skill = v.tank_head_bullet
        end
    end
    
    if self.launcher == DriveModel.data.seat_num then
        --通知DriveSkillCarPanel播放技能特效
        Event.Brocast("notify_car_skill_start",self.skill_cfg.id)
    end
end

function C:FireByDamageData(cbk)
    self.obj_datas = self:GetObjs()

    local seq  = DoTweenSequence.Create()
    for k,v in ipairs(self.obj_datas) do
        DriveLogicProcess.set_process_data_use(v.process_no)
        local obj_data = v[v.key]
        if k == 1 then
            seq:AppendCallback(function()
                local parent = self.launcher_car.fire_node
                -- local parent = GameObject.Find("Canvas/LayerLv3").transform
                local obj = newObject("BIG_tanke_xuli",parent)
                -- obj.transform.position = DriveModel.Get3DTo2DPoint(self.launcher_car.fire_node.position)
                self["fire_xuli_obj_" .. k] = obj
            end)
            seq:AppendInterval(0.8)
        end
        seq:AppendInterval(0.2)
        seq:AppendCallback(function()
            if self.bullet_skill then
                self.bullet_skill:Remove(false)
            end
            self.launcher_car.DriveCarTank:TurretFire(true,function()
                if IsEquals(self["fire_xuli_obj_" .. k]) then
                    destroy(self["fire_xuli_obj_" .. k])
                end
                self["fire_xuli_obj_" .. k] = nil
                DriveAnimManager.PlayShakeScreen(self.launcher_car.transform,0.3,Vector3.New(0.2,0.2,0))
                local car_dis = math.abs(self.launcher_car.car_data.pos - self.effecter_car.car_data.pos) % DriveMapManager.map_count
                car_dis = math.min(car_dis,math.abs(DriveMapManager.map_count - car_dis))
                if car_dis <= 1 then
                    --当两车相邻时不播放炮弹飞的动画
                    self:PlayScreenBorken(true,k,#self.obj_datas)
                    self:PlayBoom()
                    self.effecter_car:PlayOnAttack(obj_data.modify_value)
                    self:PlayDamageFx(obj_data)
                else
                    self:PlayShellFly(function()
                        self:PlayScreenBorken(true,k,#self.obj_datas)
                        self:PlayBoom()
                        self.effecter_car:PlayOnAttack(obj_data.modify_value)
                        self:PlayDamageFx(obj_data)
                    end)
                end
                if obj_data.modify_value then
                    self:PlayObjData(v)
                end
            end,function()
            end)
        end)
        seq:AppendInterval(0.2)
    end
    seq:AppendInterval(1.3)
    seq:OnForceKill(function()
        if cbk then cbk() end
        self.launcher_car.DriveCarTank:ResetTurretRotation()
        self:PlayAniScreenBorken(0,0.2)
    end)
end

function C:OnTriggerMain()
    local seq = DoTweenSequence.Create()
    if self.bullet_skill then
        local max_count = self.bullet_skill.max_bullet_count
        local cur_count = self.bullet_skill.bullet_count
        if max_count - cur_count > 0 then
            for i = 1,max_count - cur_count do 
                seq:AppendCallback(function()
                    self.bullet_skill:Add(true)
                end)
                seq:AppendInterval(0.2)
            end
        end
    end
    self.launcher_car.DriveCarTank:MoveTurretTowardsCar(self.effecter_car:GetCenterPosition(),function()
        self:FireByDamageData(function()
            self:OnTriggerEnd()
        end)
    end)
end

function C:OnTriggerEnd()
    -- self.launcher_car.car.transform:GetComponent("Canvas").sortingOrder = 1
    self:OnActEnd()
end

function C:PlayScreenBorken(show_or_hide,num,lenght)
    if self.effecter_car and self.effecter_car.car_data then
        if self.effecter_car.car_data.seat_num ~= DriveModel.data.seat_num then return end
    end
    num = num or 0
    lenght = lenght or 1
    show_or_hide = show_or_hide or false
    local select = 0
    local n = num / lenght 
    if n == 1 / lenght then
        select = 0
    elseif n > 1 / lenght and n <= 2 / lenght then
        select = 1
    elseif n > 2 / lenght and n < 1 then
        select = 2
    else
        select = 3
    end

    local effect_data = {
        show_or_hide = show_or_hide,
        -- normal_scale = 1, -- num * 0.1,
        select = select
    }
    DriveEffectManager.ScreenBroken(effect_data)
end

function C:PlayAniScreenBorken(end_v,duration)
    if self.effecter_car and self.effecter_car.car_data then
        if self.effecter_car.car_data.seat_num ~= DriveModel.data.seat_num then return end
    end
    local set_screen_broken = function(show_or_hide,scale)
        scale = scale or 0
        show_or_hide = show_or_hide or false
        local effect_data = {
            show_or_hide = show_or_hide,
            -- normal_scale = scale
        }
        DriveEffectManager.ScreenBroken(effect_data)
    end
    local screen_broken = GameObject.Find("2DNode/2DCamera"):GetComponent("ScreenBroken")
    local start_v = screen_broken.normalScale or 1
    end_v = end_v or 0
    duration = duration or 1
    local cur_v = start_v
    self.DOTAniScreenBorken = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
			function(value)
				cur_v = start_v
                set_screen_broken(true,cur_v)
                return cur_v
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				cur_v = value
				set_screen_broken(true,cur_v)
            end
        ),
        end_v,
		duration
	)
    self.DOTAniScreenBorken:OnKill(function()
        set_screen_broken(false,cur_v)
    end)
	self.DOTAniScreenBorken:SetEase(Enum.Ease.Linear)
end

function C:PlayBoom()
    local parent = GameObject.Find("Canvas/LayerLv3").transform
    local obj = newObject("BIG_tanke_paodanjizhong",parent)
    DriveAnimManager.PlayShakeScreen(DriveModel.camera3dParent,0.5,Vector3.New(0.2,0.2,0))
    obj.transform.position = DriveModel.Get3DTo2DPoint(self.effecter_car:GetCenterPosition())
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(5)
    seq:OnForceKill(function()
        destroy(obj)
    end)
end

function C:PlayShellFly(cbk)
    local parent = GameObject.Find("Canvas/LayerLv3").transform
    local obj = newObject("BIG_tanke_paodan",parent)
    obj.transform.rotation = Quaternion:SetEuler(0,0,90 - (self.launcher_car.car_paotai_3d.eulerAngles.z + 180))
    obj.transform.position = DriveModel.Get3DTo2DPoint(self.launcher_car.fire_obj.transform.position)
    local yanwu_obj = newObject("tanke_kaipao_yanwu",self.launcher_car.transform)
    local seq = DoTweenSequence.Create()
    seq:Append(obj.transform:DOMove(DriveModel.Get3DTo2DPoint(self.effecter_car:GetCenterPosition()),0.2))
    obj.transform.localScale = Vector3.New(0.5,0.5,1)
    seq:Join(obj.transform:DOScale(Vector3.New(1,1,1),0.1))
    seq:AppendCallback(function()
        destroy(obj)
        if cbk then cbk() end
    end)
    seq:AppendInterval(3)
    seq:AppendCallback(function()
        destroy(yanwu_obj)
    end)
end