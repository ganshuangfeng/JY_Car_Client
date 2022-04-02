-- 创建时间:2021-02-22
-- 技能动画效果类：坦克big技能
local basefunc = require "Game/Common/basefunc"

SkillAddBulletNum = basefunc.class(SkillBase)

local C = SkillAddBulletNum

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAddBulletNum.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.skill_change  then
            return true
        end
    end
end

function C:MyExitSubclass()
end

function C:OnTriggerBefore()
    DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx","com_img_djbc_map3","",true,self.launcher_car:GetCenterPosition(),function()
        self:OnActEnd()
    end)
end

function C:OnTriggerMain()
    local objs = self:GetObjs()
    local seq = DoTweenSequence.Create()
    local seq_1 = DoTweenSequence.Create()
    local launcher = self.launcher_car.car_data.car_no
    for k,v in ipairs(objs) do 
        if v.skill_change then
            local skill_datas = SkillManager.GetSkillByOwner({owner_type = v.owner_data.owner_type,owner_id = v.owner_data.owner_id})
            local head_skill
            for _k,skill in pairs(skill_datas) do 
                if skill.tank_head_bullet then
                    head_skill = skill.tank_head_bullet
                end
            end
            if v.owner_data.owner_id == self.launcher_car.car_data.car_no then
                seq:AppendCallback(function()
                    if head_skill then
                        head_skill:Add(true)
                    end
                end)
                seq:AppendInterval(0.2)
            else
                seq_1:AppendCallback(function()
                    if head_skill then
                        head_skill:Add(true)
                    end
                end)
                seq_1:AppendInterval(0.2)
            end
            DriveLogicProcess.set_process_data_use(v.process_no)
        end
    end
    seq:AppendCallback(function()
        self:OnActEnd()
    end)
end

function C:OnTriggerEnd()
    self:OnActEnd()
end