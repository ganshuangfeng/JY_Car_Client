-- 创建时间:2021-01-05
-- 技能动画效果类：再来一次
local basefunc = require "Game/Common/basefunc"

SkillAgain = basefunc.class(SkillBase)

local C = SkillAgain
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAgain.super.ctor(self,skill_data)
end

function C:OnTriggerBefore()
    if self.launcher_car.car_data.seat_num == DriveModel.data.seat_num then
        DriveAccelerator.GetInstance().zailaiyici_guang.gameObject:SetActive(false)
        DriveAccelerator.GetInstance().zailaiyici_guang.gameObject:SetActive(true)
    end
    DriveAnimManager.PlaySkillAgainFx(self.launcher_car:GetCenterPosition(),function()
    end)
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    AudioManager.PlaySound(audio_config.drive.com_main_map_zailaiyici.audio_name)
    if self.launcher_car.car_data.seat_num == DriveModel.data.seat_num then
        if DriveAccelerator.GetInstance() and DriveAccelerator.GetInstance().SetState then
            DriveAccelerator.GetInstance():SetState("skill_again")
        end
    end
    self:OnTriggerEnd()
end