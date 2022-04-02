-- 创建时间:2021-01-21
-- 技能动画效果类：位置传送
local basefunc = require "Game/Common/basefunc"

SkillSelectBarrier = basefunc.class(SkillBase)

local C = SkillSelectBarrier
function C.Create(skill_data)
    dump(skill_data,"<color=yellow>路障技能创建？？？？</color>")
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillSelectBarrier.super.ctor(self, skill_data)
end

function C:MyExitSubclass()
    if self.set_fx_pre then
        destroy(self.set_fx_pre)
        self.set_fx_pre = nil
    end
end

function C:MakeListener()
    self.listener = {}
    self.listener["logic_drive_game_process_data_msg_player_action"] = basefunc.handler(self,self.on_player_action)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        return true
    end
end

function C:OnTriggerBefore()
    if self.set_fx_pre then
        destroy(self.set_fx_pre)
        self.set_fx_pre = nil
    end
    local seq = DoTweenSequence.Create()
    seq:AppendCallback(function()
        -- DriveAnimManager.PlayColorGlowFx(self.launcher_car.car.transform,"jinse",self.skill_cfg.level + 1,function()
            -- if self.launcher_car.car_data.seat_num ~= DriveModel.data.seat_num then
            if false then
                --不是自己的车才播放效果
                self.set_fx_pre = DriveAnimManager.PlaySelectBarrierIconFx(DriveMapManager.GetMapAssets(self.skill_cfg.icon),self.launcher_car:GetUICenterPosition(),function()
                    self:OnTriggerMain()
                end)
            else
                self:OnTriggerMain()
            end
        -- end)
    end)
end
function C:OnTriggerMain()
    self:OnTriggerEnd()
end

function C:OnTriggerEnd()
    self:PlayObjs()
    self:OnActEnd()
end

function C:on_player_action()
    if self.set_fx_pre then
        destroy(self.set_fx_pre)
        self.set_fx_pre = nil
    end
end
