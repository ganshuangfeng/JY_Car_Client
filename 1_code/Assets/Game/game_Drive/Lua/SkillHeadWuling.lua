-- 创建时间:2021-01-06
-- 技能动画效果类：强行追尾
local basefunc = require "Game/Common/basefunc"

SkillHeadWuling = basefunc.class(SkillBase)

local C = SkillHeadWuling
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillHeadWuling.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd") then
            return true
        end
    end
end

function C:OnTriggerBefore()
    Event.Brocast("notify_car_skill_start",self.skill_cfg.server_id)
    DriveAnimManager.PlaySkillNameFx(GameObject.Find("Canvas/LayerLv3").transform,self.launcher_car:GetUICenterPosition(),self.skill_cfg.name,function()
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
    DriveAnimManager.PlayCrash(GameObject.Find("Canvas/LayerLv3").transform,
        self.launcher_car.gameObject,
        self.launcher_car:GetUICenterPosition(),
        self.effecter_car:GetUICenterPosition(),function()
            self:OnTriggerEnd()
        end)
end

function C:OnTriggerEnd()
    self.obj_datas = self:GetObjs()
    for i,v in ipairs(self.obj_datas) do
        self:PlayObjData(v)
        local modify_value = v[v.key].modify_value or 0
        DriveAnimManager.PlayHpChangeFx(GameObject.Find("Canvas/LayerLv3").transform,modify_value,self.effecter_car:GetUICenterPosition(),1,nil,1000)
        self.effecter_car:PlayOnAttack(modify_value)
    end
    DriveAnimManager.PlayBoomFx(GameObject.Find("Canvas/LayerLv3").transform,self.effecter_car:GetUICenterPosition(),nil,function()
        self:OnActEnd()
    end)
end