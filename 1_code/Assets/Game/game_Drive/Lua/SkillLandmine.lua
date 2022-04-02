-- 创建时间:2021-01-05
-- 技能动画效果类：地雷
local basefunc = require "Game/Common/basefunc"

SkillLandmine = basefunc.class(SkillBase)

local C = SkillLandmine
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillLandmine.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if (v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd"))
            or (v.obj_player_modify_property and v.obj_player_modify_property.modify_key_name == "money") or v.obj_car_transfer then
            return true
        end
    end
end

function C:OnTriggerBefore()
    self.effecter_field = 1
    if self.skill_data.range then
        self.effecter_field = math.floor(tonumber(self.skill_data.range)/2)
    else
        self.effecter_field = 0
    end
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    local owner_barrier = RoadBarrierManager.GetRoadBarrier(self.skill_data.owner_id)
    owner_barrier:PlayOnBoom(function()
        self:OnTriggerEnd()
    end)
end

function C:OnTriggerEnd()
    --伤害，金币结算
    self.obj_datas = self:GetObjs()
    local miss_flag = false
    for i,v in ipairs(self.obj_datas) do
        if v.obj_car_modify_property then
            local obj_data = v[v.key]
            local modify_value = obj_data.modify_value or 0
            if obj_data.modify_key_name == "hp" or obj_data.modify_key_name =="hd" then
                self:PlayDamageFx(obj_data)
                if obj_data.modify_tag and next(obj_data.modify_tag) then
                    for k,v in ipairs(obj_data.modify_tag) do
                        if v == "miss" then
                            miss_flag = true
                        end
                    end
                end
                self.effecter_car:PlayOnAttack(modify_value)
                self:PlayObjData(v)
            end
        end
        if v.obj_car_transfer then
            --碰撞后车的位置移动数据
            self.obj_car_transfer = v.obj_car_transfer
            DriveLogicProcess.set_process_data_use(v.process_no)
        end
    end
    local owner_barrier = RoadBarrierManager.GetRoadBarrier(self.skill_data.owner_id)
    local boom_pres = {}
    AudioManager.PlaySound(audio_config.drive.com_main_map_dilei.audio_name)
    if self.effecter_field then
        for i = owner_barrier.road_barrier_data.road_id - self.effecter_field,owner_barrier.road_barrier_data.road_id + self.effecter_field do
            local fx_pre = newObject("tongyong_baozha",GameObject.Find("3DNode").transform)
            fx_pre.transform.position = DriveMapManager.ServerPosConversionMapVector(i)
            boom_pres[#boom_pres + 1] = fx_pre
        end
    else
        local fx_pre = newObject("tongyong_baozha",GameObject.Find("3DNode").transform)
        fx_pre.transform.position = owner_barrier.transform.position
        boom_pres[#boom_pres + 1] = fx_pre
    end
    if self.obj_car_transfer then
        self.effecter_car.car_data.pos = self.obj_car_transfer.end_pos
        local t = 1 + 2/3
        self.effecter_car:PlayCarBoomFly()
        local target_pos = DriveMapManager.ServerPosConversionMapVector(self.effecter_car.car_data.pos)
        DriveAnimManager.PlayBoomMove(self.effecter_car,target_pos,function()
            self.effecter_car:RefreshTransform()
            self:OnActEnd()
        end,1.5)
    else
        if not miss_flag then
            self.effecter_car:PlayCarBoomFly(function()
                self:OnActEnd()
            end)
        else
            self:OnActEnd()
        end
    end
    DriveAnimManager.PlayBoomFx(GameObject.Find("Canvas/LayerLv3").transform,self.effecter_car:GetUICenterPosition(),nil,self.skill_cfg.level,function()
        --改变金币
        for k,fx_pre in ipairs(boom_pres) do 
            destroy(fx_pre)
        end
    end)
end