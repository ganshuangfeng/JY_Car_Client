-- 技能动画效果类：黑夜
local basefunc = require "Game/Common/basefunc"

SkillReverse = basefunc.class(SkillBase)

local C = SkillReverse
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillReverse.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.skill_create then
            return true
        end
    end
end

function C:OnTriggerBefore()
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    self.obj_datas = self:GetObjs()
    local seq = DoTweenSequence.Create()
    local ui_material = GetMaterial("2DUI")
    local cars = {}
    for k,v in ipairs(self.obj_datas) do 
        local car = DriveCarManager.GetCarByNo(v.skill_create.owner_data.owner_id)
        local nz_fx_pre = newObject("nizhuanfangxiang",car.car.transform)
        nz_fx_pre.gameObject:SetActive(false)
        cars[car.car_data.car_no] = {car = car,before_material = car:GetCurrentFbxMaterial(),nz_fx_pre = nz_fx_pre}
    end

    --设置环境光
    DriveEffectManager.SetLight({weather = "night"})
    ui_material.color = Color.New(63/255,63/255,63/255)
    for k,v in pairs(cars) do 
        v.car:SetFbxMaterial("gaoliang")
    end
    seq:AppendCallback(function()
        AudioManager.PlaySound(audio_config.drive.com_main_map_nixiangjiashi.audio_name)
        destroy(fx_pre)
    end)
    seq:AppendCallback(function()
        for k,v in pairs(cars) do
            v.nz_fx_pre.gameObject:SetActive(true)
        end
    end)
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        for k,v in pairs(cars) do
            destroy(v.nz_fx_pre.gameObject)
        end
    end)
    seq:AppendInterval(1)
    for k,v in pairs(cars) do
        --旋转180度
        seq:Join(v.car.transform:DOLocalRotateQuaternion(Quaternion:SetEuler(0,0,180),1))
    end
    seq:AppendCallback(function()
        if not DriveMapManager.reverse_arrow then
            DriveMapManager.reverse_arrow = newObject("fangxiangbiaoshi",GameObject.Find("3DNode/map_node").transform)
        end
    end)
    seq:AppendInterval(2)
    seq:AppendCallback(function()
        local start_v = 0.5
        local cur_v = start_v
        local end_v = 1
        local duration = 0.5
        local DOTProcesse = DG.Tweening.DOTween.To(
            DG.Tweening.Core.DOGetter_float(
                function(value)
                    cur_v = start_v
                    DriveEffectManager.SetLight({weather = "night",light = cur_v})
                    return cur_v
                end
            ),
            DG.Tweening.Core.DOSetter_float(
                function(value)
                    cur_v = value
                    DriveEffectManager.SetLight({weather = "night",light = cur_v})
                end
            ),
            end_v,
            duration
        )
        DOTProcesse:SetEase(Enum.Ease.Linear)
    end)
    seq:AppendInterval(0.6)
    seq:OnForceKill(function()
        ui_material.color = Color.white
        DriveEffectManager.SetLight({weather = "day"})
        for k,v in pairs(cars) do 
            v.car:SetFbxMaterial(v.before_material)
            v.car.transform.localRotation = Quaternion:SetEuler(0,0,0)
        end
        self:OnActEnd()
    end)
end