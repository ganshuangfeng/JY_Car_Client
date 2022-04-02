-- 技能动画效果类：黑夜
local basefunc = require "Game/Common/basefunc"

SkillSystemNight = basefunc.class(SkillBase)

local C = SkillSystemNight
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillSystemNight.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        return true
    end
end

function C:RefreshSubclass()
    for seat_num,player in ipairs(DriveCarManager.cars) do  
        for k,car in ipairs(player) do 
            -- car:LightSwitch(true)
        end
    end

    DriveEffectManager.SetLight({weather = "night"})
    if self.heiye_pre then return end
    AudioManager.PlaySound(audio_config.drive.com_main_map_heiye.audio_name)
    self.heiye_pre = newObject("heiye",GameObject.Find("Canvas/LayerLv5").transform)
    self.heiye_pre.transform.localPosition = Vector3.zero
end

function C:OnDead()
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

function C:MyExitSubclass()
    for seat_num,player in ipairs(DriveCarManager.cars) do  
        for k,car in ipairs(player) do 
            car:LightSwitch(false)
        end
    end
    DriveEffectManager.SetLight({weather = "day"})
    if IsEquals(self.heiye_pre) then
        destroy(self.heiye_pre)
    end
end