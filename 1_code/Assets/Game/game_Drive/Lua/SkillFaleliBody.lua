-- 创建时间:2021-01-06
-- 技能动画效果类：路过电锯伤害
local basefunc = require "Game/Common/basefunc"

SkillFaleliBody = basefunc.class(SkillBase)

local C = SkillFaleliBody
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillFaleliBody.super.ctor(self,skill_data)
end

function C:MakeListener()
    self.listener = {}
    self.listener["car_move_to_pos"] = basefunc.handler(self,self.on_car_move_to_pos)
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
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    local fx_obj_1
    if self.launcher_car and self.launcher_car.DriveCarFaleli and self.launcher_car.DriveCarFaleli.add_chain_saw then
        fx_obj_1 = newObject("qiegejineng_1",self.effecter_car.car.transform)
    else
        fx_obj_1 = newObject("qiegejineng",self.effecter_car.car.transform)
    end
    if self.launcher_car and self.launcher_car.DriveCarFaleli and self.launcher_car.DriveCarFaleli.big_skill_status then
        fx_obj_1.transform:Find("1").gameObject:SetActive(false)
        fx_obj_1.transform:Find("2").gameObject:SetActive(true)
    end
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1)
    seq:OnForceKill(function()
        destroy(fx_obj_1)
    end)

    self:OnTriggerEnd()
end

function C:OnTriggerEnd()
    --伤害结算
    self.obj_data = self:GetObj(true)
    self.obj_datas = self:GetObjs()
    local seq = DoTweenSequence.Create()
    for k,v in ipairs(self.obj_datas) do
        self:PlayObjData(v)
        seq:AppendCallback(function()
            self:PlayDamageFx(v[v.key])
        end) 
        seq:AppendInterval(0.2)
    end
    if self.launcher_car and self.launcher_car.DriveCarFaleli and self.launcher_car.DriveCarFaleli.big_skill_status then
        AudioManager.PlaySound(audio_config.drive.com_main_falali_dianjuqiege1.audio_name)
        DriveAnimManager.PlayShakeScreen(DriveModel.camera3dParent,0.5)
    else
        AudioManager.PlaySound(audio_config.drive.com_main_falali_dianjuqiege.audio_name)
    end
    self.effecter_car:PlayOnAttack(self.obj_data[self.obj_data.key].modify_value)

    self:OnActEnd()
end

function C:OnMiss(car_no)
    DriveAnimManager.PlayAttributeChangeFx("miss_fx","com_img_miss_map3","",true,DriveCarManager.GetCarByNo(car_no):GetCenterPosition())
end

function C:on_car_move_to_pos(data)
    local my_car
    if self.skill_data and self.skill_data.owner_type == 2 then
        my_car = self.skill_data.owner_id
    else
        my_car = self.launcher
    end
    if data.car_no == my_car then
        for seat_num,cars in ipairs(DriveCarManager.cars) do
            for k, v in ipairs(cars) do
                if v and v.car_data and my_car ~= v.car_data.car_no and DriveMapManager.ServerPosConversionRoadId(data.pos) == DriveMapManager.ServerPosConversionRoadId(v.car_data.pos) then
                    local process_data = DriveLogicProcess.get_current_process_data()
                    for _k,_v in ipairs(process_data) do
                        if _v.key == "skill_trigger" and _v.skill_trigger.skill_id == self.skill_cfg.id and _v.pos and _v.pos == data.pos then
                            return
                        end
                    end
                    self:OnMiss(v.car_data.car_no)
                end
            end
        end
    end
end