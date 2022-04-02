-- 创建时间:2021-01-06
-- 技能动画效果类：撕裂电锯
local basefunc = require "Game/Common/basefunc"

SkillFaleliHead = basefunc.class(SkillBase)

local C = SkillFaleliHead
function C.Create(skill_data)
    return C.New(skill_data)
end
local fx_name = "DianjuAttackFx"
function C:ctor(skill_data)
    SkillFaleliHead.super.ctor(self,skill_data)
end

function C:OnTriggerBefore()
    Event.Brocast("notify_car_skill_start",self.skill_cfg.server_id)
    DriveAnimManager.PlaySkillNameFx(GameObject.Find("Canvas/LayerLv3").transform,self.launcher_car:GetUICenterPosition(),self.skill_cfg.name,function()
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
	DriveAnimManager.PlayMoveTargetFx(GameObject.Find("Canvas/LayerLv3").transform,self.launcher_car:GetUICenterPosition()
	,self.effecter_car:GetUICenterPosition(),fx_name,0.7,false,1,function()
		self:OnTriggerEnd()
	end)
end

function C:OnTriggerEnd()
    --伤害结算
    self.obj_datas = self:GetObjs()
    for i,v in ipairs(self.obj_datas) do
        self:PlayObjData(v)
        local modify_value = v[v.key].modify_value or 0
        DriveAnimManager.PlayHpChangeFx(GameObject.Find("Canvas/LayerLv3").transform,modify_value,self.effecter_car:GetUICenterPosition(),1,nil,1000)
        self.effecter_car:PlayOnAttack()
    end
    DriveAnimManager.PlayBoomFx(GameObject.Find("Canvas/LayerLv3").transform,self.effecter_car:GetUICenterPosition(),nil,self.skill_cfg.level,function()
        self:OnActEnd()
    end)
end