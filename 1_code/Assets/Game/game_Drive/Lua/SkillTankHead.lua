-- 创建时间:2021-02-22
-- 技能动画效果类：坦克车头技能 开炮
local basefunc = require "Game/Common/basefunc"
SkillTankHead = basefunc.class(SkillBase)
ext_require("Game.game_Drive.Lua.SkillTankHeadBullet")

local C = SkillTankHead

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillTankHead.super.ctor(self,skill_data)
    self.tank_head_bullet = SkillTankHeadBullet.Create(self)
    local field = self.skill_data.attack_circle_radius
    if field then
        local car = DriveCarManager.GetCarByNo(self.skill_data.owner_id)
        car.DriveCarTank:SetNormalEffectRadius(field)
    end
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
    if self.tank_head_bullet then
        self.tank_head_bullet:MyExit()
    end
end

function C:InitUISubclass()
    if self.tank_head_bullet then
	    self.tank_head_bullet:Init()
    end
end

function C:RefreshSubclass()
    if self.tank_head_bullet then
        self.tank_head_bullet:Refresh()
    end
end

function C:RefreshData(other_data)
    for k,v in ipairs(other_data) do 
        self.skill_data[v.key] = tonumber(v.value)
    end
end

--技能改变
function C:OnChange(data)
    dump(data,"<color=yellow>坦克开炮技能改变</color>")
    self:RefreshData(data.skill_data.other_data)
    self.tank_head_bullet:OnChange(data)
    local seq = DoTweenSequence.Create()
    self:OnActEnd()
end

function C:OnTriggerBefore()
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.2)
    seq:AppendCallback(function()
        self.launcher_car.DriveCarTank:ShowTurretEffectField(true,function()
            self.launcher_car.DriveCarTank:CloseTurretEffectField()
        end)
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
    local func_1 = function(vec)
        local seq = DoTweenSequence.Create()
        self.obj_datas = self:GetObjs()
        if not self.obj_datas or not next(self.obj_datas) then
            self.tank_head_bullet:PlayNoBullet()
            self.launcher_car.DriveCarTank:ResetTurretRotation()
            self:OnActEnd()
            return
        end
        dump(self.obj_datas,"<color=white>坦克obj改变数据</color>")
        for k,v in ipairs(self.obj_datas) do
            DriveLogicProcess.set_process_data_use(v.process_no)
            local lj_flag = false
            if v[v.key] and v[v.key].modify_tag then
                for k,v in ipairs(v[v.key].modify_tag) do
                    if v == "lj" then
                        lj_flag = true
                        break
                    end
                end
            end
            if lj_flag then
                seq:AppendInterval(0.2)
            else
                seq:AppendInterval(0.5)
            end
            seq:AppendCallback(function()
                local shake_factor = 0.1
                self.launcher_car.DriveCarTank:TurretFire(false,function()
                    local car_dis = math.abs(self.launcher_car.car_data.pos - self.effecter_car.car_data.pos) % DriveMapManager.map_count
                    car_dis = math.min(car_dis,math.abs(DriveMapManager.map_count - car_dis))
                    if car_dis <= 1 then
                        --当两车相邻时不播放炮弹飞的动画
                        local shake_vec = tls.pMul(tls.pNormalize(vec),shake_factor)
                        self.launcher_car:PlayShakeMove(tls.pMul(shake_vec,-0.5),nil,true)
                        self:PlayBoom()
                        self.effecter_car:PlayShakeMove(shake_vec,v[v.key].modify_value)
                        self:PlayDamage(v,k)
                    else
                        local shake_vec = tls.pMul(tls.pNormalize(vec),shake_factor)
                        self.launcher_car:PlayShakeMove(tls.pMul(shake_vec,-0.5),nil,true)
                        self:PlayShellFly(function()
                            self:PlayBoom()
                            self.effecter_car:PlayShakeMove(shake_vec,v[v.key].modify_value)
                            self:PlayDamage(v,k)
                        end)
                    end
                end,function()
                    if k == #self.obj_datas then
                        local _seq = DoTweenSequence.Create()
                        _seq:AppendInterval(0.5)
                        _seq:AppendCallback(function()
                            self.effecter_car.car.transform.localPosition = Vector3.zero
                        end)
                        self:OnTriggerEnd()
                    end
                end)
            end)
        end
        -- seq:AppendInterval(1)
        -- seq:OnForceKill(function()
        --     self:OnTriggerEnd()
        -- end)
    end
    self.launcher_car.DriveCarTank:MoveTurretTowardsCar(self.effecter_car:GetCenterPosition(),func_1)
end

function C:PlayDamage(v,k)
    if v[v.key].modify_value then
        self:PlayDamageFx(v[v.key],function()
            if k == #self.obj_datas then
                self.launcher_car.DriveCarTank:ResetTurretRotation()
            end
        end)
        self:PlayObjData(v)
    else
        self.launcher_car.DriveCarTank:ResetTurretRotation()
    end
end

function C:OnTriggerEnd()
    self:OnActEnd()
end

function C:PlayShellFly(cbk)
    local parent = GameObject.Find("Canvas/LayerLv3").transform
    local obj
    if self.launcher_car and self.launcher_car.DriveCarTank and self.launcher_car.DriveCarTank.paodan_strengthen then
        obj = newObject("PT_paodan_1",parent)
    else
        obj = newObject("PT_paodan",parent)
    end
    obj.transform.rotation = Quaternion:SetEuler(0,0,90 - self.launcher_car.car_paotai_3d.eulerAngles.z)
    obj.transform.position = DriveModel.Get3DTo2DPoint(self.launcher_car.fire_obj.transform.position)
    local seq = DoTweenSequence.Create()
    seq:Append(obj.transform:DOMove(DriveModel.Get3DTo2DPoint(self.effecter_car:GetCenterPosition()),0.1))
    obj.transform.localScale = Vector3.New(0.5,0.5,1)
    seq:Join(obj.transform:DOScale(Vector3.New(1,1,1),0.1))
    seq:AppendCallback(function()
        obj.transform:Find("@icon_img").gameObject:SetActive(false)
        if cbk then cbk() end
    end)
    seq:AppendInterval(0.5)
    seq:OnForceKill(function()
        destroy(obj)
    end)
end

function C:PlayBoom()
    if self.tank_head_bullet then
        self.tank_head_bullet:Remove(true)
    end
    local parent = GameObject.Find("Canvas/LayerLv3").transform
    local obj
    if self.launcher_car and self.launcher_car.DriveCarTank and self.launcher_car.DriveCarTank.paodan_strengthen then
        obj = newObject("PT_tanke_paodanjizhong_1",parent)
    else
        obj = newObject("PT_tanke_paodanjizhong",parent)
    end
    AudioManager.PlaySound(audio_config.drive.com_main_hushi_paodanxiaobaozha.audio_name)
    obj.transform.position = DriveModel.Get3DTo2DPoint(self.effecter_car.car.position)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(5)
    seq:OnForceKill(function()
        destroy(obj)
    end)
end