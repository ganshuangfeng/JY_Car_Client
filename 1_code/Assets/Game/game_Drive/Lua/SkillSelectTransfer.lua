-- 创建时间:2021-01-21
-- 技能动画效果类：位置传送
local basefunc = require "Game/Common/basefunc"

SkillSelectTransfer = basefunc.class(SkillBase)

local C = SkillSelectTransfer
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillSelectTransfer.super.ctor(self, skill_data)
end

function C:SetObjData()
    if not self.skill_data or not next(self.skill_data) then
        return
    end
    if self.skill_data.process_no then
        local data = DriveLogicProcess.get_process_data_by_father_process_no(self.skill_data.process_no)
        if data and next(data) then
            dump(data[1], "传送技能的传送数据")
            self.obj_car_transfer = data[1].obj_car_transfer
            return true
        end
    end
end

function C:OnTriggerBefore()
        self:OnTriggerMain()
end
function C:OnTriggerMain()
    self:SetObjData()
    if self.obj_car_transfer then
        self.launcher_car:TransferPosition(self.obj_car_transfer.end_pos)
        self:OnTriggerEnd()
    else
        self:OnTriggerEnd()
    end
    -- self.launcher_car:TransferPosition(self.end_pos)
end

function C:OnTriggerEnd()
    self:OnActEnd()
end
