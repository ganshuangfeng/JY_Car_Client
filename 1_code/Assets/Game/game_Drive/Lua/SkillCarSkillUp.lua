-- 创建时间:2021-01-04
-- 技能动画效果类：吸金炸弹
local basefunc = require "Game/Common/basefunc"

SkillCarSkillUp = basefunc.class(SkillBase)

local C = SkillCarSkillUp

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillCarSkillUp.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_skill_up then
            return true
        end
    end
end


function C:OnTriggerBefore()
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    self.obj_data = self:GetObj()
    if not self.obj_data.old_skill_id or not self.obj_data.new_skill_id then 
        self:OnActEnd()
        return
    end
    local desc_map = {
        car_head = "车头+1",
        car_body = "车身+1",
        car_tail = "车尾+1"
    }
    DriveAnimManager.PlayColorGlowFx(self.launcher_car.car.transform,"jinse",self.skill_cfg.level + 1,function()
        if self.launcher == DriveModel.data.seat_num then
            self:PlayObj()
            -- Event.Brocast("notify_car_skill_upgrade",self.old_skill_id,self.old_skill_id)
        end
        AudioManager.PlaySound(audio_config.drive.com_main_map_chetoucheshencheweishengji.audio_name)
        DriveAnimManager.PlayCarSkillUpFx(desc_map[self.obj_data.skill_tag],self.launcher_car:GetUICenterPosition(),function()
            self:OnActEnd()
        end)
    end)
end