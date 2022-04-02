-- 创建时间:2021-03-26
-- 技能动画效果类：红灯
local basefunc = require "Game/Common/basefunc"

SkillRedLamp = basefunc.class(SkillBase)

local effect_range = 3

local C = SkillRedLamp
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillRedLamp.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if (v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd"))
            or (v.obj_player_modify_property and v.obj_player_modify_property.modify_key_name == "money") then
            return true
        end
    end
end

function C:OnTriggerBefore()
    --此技能的owner是road_barrier
    self.owner_barrier = RoadBarrierManager.GetRoadBarrier(self.skill_data.owner_id)
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    self.owner_barrier:PlayOnBoom(function()
        self:OnTriggerEnd()
    end)
end

function C:OnTriggerEnd()
    self:OnActEnd()
    -- DriveAnimManager.PlayNewAttributeChangeFx("red_lamp_art_font_fx","com_img_jt_map3","",true,self.effecter_car:GetCenterPosition(),function()
    --     self:OnActEnd()
    -- end,true)
end