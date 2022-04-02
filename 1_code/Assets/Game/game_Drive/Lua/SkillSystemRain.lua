-- 技能动画效果类：黑夜
local basefunc = require "Game/Common/basefunc"

SkillSystemRain = basefunc.class(SkillBase)

local C = SkillSystemRain
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillSystemRain.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        return true
    end
end


function C:RefreshSubclass()
    if self.xiayu_pre then return end
    self.xiayu_pre = newObject("xiayu",GameObject.Find("Canvas/LayerLv5").transform)
    self.xiayu_pre.transform.localPosition = Vector3.zero
    self.xiayu_pre.transform:Find("wuyun").gameObject:SetActive(true)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(2)
    seq:AppendCallback(function()
        DriveEffectManager.ScreenRain({show_or_hide = true})
        if not self.loop_sound_key then
            self.loop_sound_key = AudioManager.PlaySound(audio_config.drive.com_main_map_yutian1.audio_name,-1)
        end
        if IsEquals(self.xiayu_pre) then
            self.xiayu_pre.transform:Find("wuyun").gameObject:SetActive(false)
        end
    end)
end

function C:OnDead()
    DriveEffectManager.ScreenRain({show_or_hide = false})
    if IsEquals(self.xiayu_pre) then
        local seq = DoTweenSequence.Create({dotweenLayerKey = DriveLogicProcess.dotween_key})
        seq:AppendInterval(1)
        seq:AppendCallback(function()
            self.xiayu_pre.transform:Find("fangqing").gameObject:SetActive(true)
            if self.loop_sound_key then
                AudioManager.CloseSound(self.loop_sound_key)
                self.loop_sound_key = nil
            end
        end)
        seq:AppendInterval(2)
        seq:AppendCallback(function()
            self:OnActEnd()
        end)
    else
        local fangqing_pre
        local seq = DoTweenSequence.Create({dotweenLayerKey = DriveLogicProcess.dotween_key})
        seq:AppendInterval(1)
        seq:AppendCallback(function()
            fangqing_pre = newObject("fangqing",GameObject.Find("Canvas/LayerLv5").transform)
        end)
        seq:AppendInterval(2)
        seq:AppendCallback(function()
            destroy(fangqing_pre)
            self:OnActEnd()
        end)
    end
end

function C:MyExitSubclass()
    if self.loop_sound_key then
        AudioManager.CloseSound(self.loop_sound_key)
        self.loop_sound_key = nil
    end
    DriveEffectManager.ScreenRain({show_or_hide = false})
    if IsEquals(self.xiayu_pre) then
        destroy(self.xiayu_pre)
    end
end