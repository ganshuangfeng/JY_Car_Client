-- 创建时间:2021-04-16
-- 技能动画效果类：地雷车安装地雷
local basefunc = require "Game/Common/basefunc"

SkillLandmineCarBig = basefunc.class(SkillBase)

local C = SkillLandmineCarBig
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillLandmineCarBig.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.road_barrier_change then
            return true
        end
    end
end

function C:OnTriggerBefore()
    DriveAnimManager.PlayBigSkillNameFx("com_img_tjzy_map3",self.launcher_car:GetCenterPosition(),function()
        -- set_order_in_layer(self.launcher_car.car,2)
        AudioManager.PlayOldBGM()
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
    self.obj_datas = self:GetObjs()
    local seq = DoTweenSequence.Create()
    for k,v in ipairs(self.obj_datas) do
        DriveLogicProcess.set_process_data_use(v.process_no)
    end
    table.sort(self.obj_datas,function(a,b)
        return a.road_barrier_change.road_barrier_data.road_id < b.road_barrier_change.road_barrier_data.road_id
    end)
    local landmines_parent = GameObject.Find("3DNode").transform
    for i = 1,#self.obj_datas do
        math.randomseed(self.skill_data.process_no .. i)
        local fx_pre = newObject("RoadBarrierCarBigLandmine",landmines_parent)
        fx_pre.transform:Find("luzhang"):GetComponent("Animator").enabled = false
        fx_pre.transform:Find("luzhang/tongyongdi").gameObject:SetActive(false)
        fx_pre.transform:Find("luzhang/@yanwu").gameObject:SetActive(false)
        fx_pre.transform.position = self.launcher_car.model.transform.position
        fx_pre.gameObject:SetActive(false)
        local fashe_pre
        seq:AppendCallback(function()
            AudioManager.PlaySound(audio_config.drive.com_main_map_fashelei.audio_name)
            fashe_pre = newObject("dileiche_fashe",self.launcher_car.transform)
        end)
        seq:AppendInterval(0.2)
        seq:AppendCallback(function()
            if IsEquals(fashe_pre) then
                destroy(fashe_pre)
            end
            fx_pre.gameObject:SetActive(true)
            local target_pos = Vector3.New((math.random() - 0.5) * 5 / 0.5,math.random(40,50),0.96)
            local _seq = DoTweenSequence.Create()
            _seq:Append(fx_pre.transform:DOMove(target_pos,0.5):SetEase(Enum.Ease.Linear))
            _seq:AppendCallback(function()
                destroy(fx_pre)
            end)
        end)
    end
    seq:AppendInterval(0.5)
    for k,v in ipairs(self.obj_datas) do
        seq:AppendInterval(0.3)
        seq:AppendCallback(function()
            RoadBarrierManager.AddRoadBarrier(v.road_barrier_change.road_barrier_data)
        end)
    end
    seq:AppendCallback(function()
        self:OnActEnd()
    end)
end