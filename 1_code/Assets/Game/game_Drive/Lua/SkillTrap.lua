-- 创建时间:2021-01-05
local basefunc = require "Game/Common/basefunc"

SkillTrap = basefunc.class(SkillBase)

local C = SkillTrap
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillTrap.super.ctor(self,skill_data)
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
    AudioManager.PlaySound(audio_config.drive.com_main_map_zhuangjiluzhang.audio_name)
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    DriveAnimManager.PlayShakeScreen(DriveModel.camera3dParent,0.2)
    -- dump(self.skill_data,"self.skill_data")
    local rbb = RoadBarrierManager.GetRoadBarrier(self.skill_data.owner_id)
    rbb.gameObject:SetActive(false)
    local fx_pre = newObject("road_barrier_on_trap",GameObject.Find("Canvas/LayerLv3").transform)
    fx_pre.transform.position = DriveModel.Get3DTo2DPoint(rbb.transform.position)
    fx_pre.transform:Find("luzhang"):GetComponent("Animator"):Play("luzhang_zhuangji",0,0)
    self.effecter_car:PlayOnAttack()

    self.obj_data = self:GetObj(true)
    if self.obj_data then
        DriveLogicProcess.set_process_data_use(self.obj_data.process_no)
    end

    --停止车辆移动
    local car_data = {
        car_no = self.launcher_car.car_data.car_no,
        pos = self.skill_data.pos,
    }
    Event.Brocast("play_process_obj_car_stop",car_data)

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        self:PlayObjData(self.obj_data)
    end)
    seq:AppendInterval(0.5)
    seq:AppendCallback(function()
        self:OnTriggerEnd()
        destroy(fx_pre)
    end)
end

function C:OnTriggerEnd()

end