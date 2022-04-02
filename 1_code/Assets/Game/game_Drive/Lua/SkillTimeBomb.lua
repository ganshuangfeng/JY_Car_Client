-- 创建时间:2021-03-24
-- 技能动画效果类：定时炸弹
local basefunc = require "Game/Common/basefunc"

SkillTimeBomb = basefunc.class(SkillBase)

local effect_range = 3

local C = SkillTimeBomb
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillTimeBomb.super.ctor(self,skill_data)
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
    self.owner_barrier:PlayOnBoom(function()
        self:OnTriggerMain()
        local _seq = DoTweenSequence.Create()
        _seq:AppendInterval(0.1)
        _seq:AppendCallback(function()
            self.owner_barrier.gameObject:SetActive(false)
        end)
    end)
end

function C:OnTriggerMain()
    local main_seq = DoTweenSequence.Create()
    for i = 0,effect_range do
        main_seq:AppendInterval(0.1)
        main_seq:AppendCallback(function()
            for j = 1,2 do
                local road_id = DriveMapManager.ServerPosConversionRoadId(self.owner_barrier.road_barrier_data.road_id + i *(j == 1 and -1 or 1))
                local boom_fx = newObject("dingshizhadan",GameObject.Find("Canvas/LayerLv3").transform)
                boom_fx.transform.position = DriveModel.Get3DTo2DPoint(DriveMapManager.GetGameMapByRoadID(road_id,true).transform.position)
                local seq = DoTweenSequence.Create()
                seq:AppendInterval(1.5)
                seq:AppendCallback(function()
                    destroy(boom_fx)
                end)
            end
        end)
    end
    main_seq:AppendCallback(function()
        local obj_datas = self:GetObjs()
        for k,v in ipairs(obj_datas) do
            local obj_data = v[v.key]
            local modify_value = obj_data.modify_value or 0
            if obj_data.modify_key_name == "hp" or obj_data.modify_key_name =="hd" then
                self:PlayDamageFx(obj_data)
                self.effecter_car:PlayOnAttack(modify_value)
                self:PlayObjData(v)           
            end
        end
    end)
    main_seq:AppendCallback(function()
        self:OnTriggerEnd()
    end)
end

function C:OnTriggerEnd()
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.5)
    seq:AppendCallback(function()
        self:OnActEnd()
    end)
end