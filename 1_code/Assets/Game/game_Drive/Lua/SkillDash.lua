-- 创建时间:2021-01-06
-- 技能动画效果类：冲刺
local basefunc = require "Game/Common/basefunc"

SkillDash = basefunc.class(SkillBase)

local C = SkillDash
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillDash.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_move then
            return true
        end
    end
end

function C:MakeListener()
	self.listener = {}
    self.listener["car_move_end"] = basefunc.handler(self,self.on_car_move_end)
end

function C:OnTriggerBefore()    
    DriveAnimManager.PlayNewAttributeChangeFx("skill_dash_fx","com_img_cc" .. self.skill_cfg.level,"",true,self.launcher_car:GetCenterPosition(),function()
    end)
    local fx_pre
    local seq = DoTweenSequence.Create()
    seq:AppendCallback(function()
        if self.skill_cfg.level and self.skill_cfg.level > 1 then
            AudioManager.PlaySound(audio_config.drive.com_main_falali_chongci1.audio_name)
        else
            AudioManager.PlaySound(audio_config.drive.com_main_falali_chongci.audio_name)
        end
        fx_pre = newObject("chongci_danqijiasu",self.launcher_car.transform)
        self.tail_fx = newObject("chongci",self.launcher_car.tail_node.transform)
        self.tail_fx.transform.localPosition = Vector3.New(0,0,-0.01)
        if self.launcher_car and self.launcher_car.DriveCarFaleli then
            self.launcher_car.DriveCarFaleli:OpenSaw()
        end
    end)
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        self:OnTriggerMain()
            if IsEquals(fx_pre) then
                destroy(fx_pre)
            end
    end)
end

local tail_fx
function C:OnTriggerMain()    
    --为车辆添加拖尾
    self.car_tailing_ps = self.tail_fx.transform:Find("2 (1)"):GetComponent("ParticleSystem")
    local euler_z = DriveMapManager.CarMapEulerZ(self.launcher_car.transform.localPosition)
    self.car_tailing_ps.main.startRotationMultiplier = (math.pi/180) * (euler_z - 90)
    self.tail_fx.transform:Find("chongci_bao").gameObject:SetActive(true)
    tail_fx = self.tail_fx
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.2)
    seq:AppendCallback(function()
        local funcs = {
            stop_call = function ()
                ---移除拖尾
                if IsEquals(self.tail_fx) then
                    destroy(self.tail_fx)
                elseif IsEquals(tail_fx) then
                    destroy(tail_fx)
                end
                self:OnTriggerEnd()
            end,
            end_call = function ()
                ---移除拖尾
                if IsEquals(self.tail_fx) then
                    destroy(self.tail_fx)
                elseif IsEquals(tail_fx) then
                    destroy(tail_fx)
                end
                self:OnTriggerEnd()
            end
        }
        self:PlayObj(nil,funcs)
    end)
end

function C:OnTriggerEnd()
    
end

function C:on_car_move_end(data)
    if IsEquals(self.tail_fx) then
        destroy(self.tail_fx)
    elseif IsEquals(tail_fx) then
        destroy(tail_fx)
        tail_fx = nil
    end
    ---移除拖尾
    if self.launcher_car and self.launcher_car.car_data.car_no ~= data.car_data.car_no then
        return
    end
end