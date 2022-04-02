-- 创建时间:2021-03-26
-- 技能动画效果类：维修工具加血
local basefunc = require "Game/Common/basefunc"

SkillAddHpKit = basefunc.class(SkillAddHp)

local C = SkillAddHpKit
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAddHpKit.super.ctor(self,skill_data)
end

function C:OnTriggerBefore()
    local fx_pre = newObject("xiufu",GameObject.Find("Canvas/LayerLv3").transform)
    fx_pre.transform.position = self.launcher_car:GetUICenterPosition()
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(2.2)
    seq:AppendCallback(function()
        AudioManager.PlaySound(audio_config.drive.com_main_map_xueliangzengjia.audio_name)
        DriveAnimManager.PlayColorGlowFx(self.launcher_car.car.transform,"lvse",self.skill_cfg.level + 1)
        local _seq = DoTweenSequence.Create()
        _seq:AppendInterval(0.8)
        _seq:AppendCallback(function()
            destroy(fx_pre)
            self:OnTriggerMain()
        end)
    end)
end