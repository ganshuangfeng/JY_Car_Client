-- 创建时间:2021-02-24
-- 游戏安装车车辆脚本
local basefunc = require "Game/Common/basefunc"
DriveCarLandmine = basefunc.class()

local C = DriveCarLandmine
C.name = "DriveCarLandmine"

function C.Create(super)
    return C.New(super)
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
	self.listener = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
    self:RemoveListener()
    clear_table(self)
end

function C:ctor(super)
    self.super = super
    self.target_range = 6
    self.lock_show_range = true
    if not self.super.transform:GetComponent("CanvasGroup") then
        self.super.gameObject:AddComponent( typeof(UnityEngine.CanvasGroup))
    end
    self:MakeListener()
    self:AddListener()
end

function C:PlayCarBoomFly(cbk)
    if self.super.car and self.super.car.transform:GetComponent("Animator") then
        local animator = self.super.car.transform:GetComponent("Animator")
        animator.enabled = true
        animator:Play("cheliang_dilei",0,0)
        animator.speed = 2/3
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(1.5)
        seq:AppendCallback(function()
            animator.enabled = false
            self.super.model.transform.localPosition = Vector3.zero
            self.super.model.transform.localRotation = Quaternion:SetEuler(-90,0,0)
            if cbk then cbk() end
        end)
    end
end