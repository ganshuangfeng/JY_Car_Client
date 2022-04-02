-- 创建时间:2021-03-24
-- 技能动画效果类：禁停路障
local basefunc = require "Game/Common/basefunc"

SkillTrapForbid = basefunc.class(SkillBase)

local C = SkillTrapForbid
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillTrapForbid.super.ctor(self,skill_data)
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
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    if self.skill_data.pos then
        local rbb = RoadBarrierManager.GetRoadBarrier(self.skill_data.owner_id)
        -- rbb.gameObject:SetActive(false)
        local road_id = DriveMapManager.ServerPosConversionRoadId(self.skill_data.pos)
        local fx_pre = newObject("jinzhishiyong",DriveMapManager.GetMapPrefabByRoadID(road_id,true).transform:Find("skill_node").transform)
        fx_pre.transform.localPosition = Vector3.zero
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(2)
        seq:AppendCallback(function()
            destroy(fx_pre)
            self:OnTriggerEnd()
        end)
        DriveAnimManager.PlayNewAttributeChangeFx("normal_text_font_fx",nil,"无法获得",true,self.launcher_car:GetCenterPosition(),function()
        end)
    else
        self:OnTriggerEnd()
    end
end

function C:OnTriggerEnd()
    self:OnActEnd()
end