-- 创建时间:2021-04-23
-- 技能动画效果类：血量克隆
local basefunc = require "Game/Common/basefunc"

SkillCloneHp = basefunc.class(SkillBase)

local C = SkillCloneHp
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillCloneHp.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd")  then
            return true
        end
    end
end


function C:OnTriggerBefore()
    -- local fx_pre_1 = newObject("huanjingzhongxin",GameObject.Find("Canvas/LayerLv3").transform)
    self.loop_sound_key = AudioManager.PlaySound(audio_config.drive.com_main_map_shengmingkelong.audio_name)
    local seq = DoTweenSequence.Create()
    -- seq:AppendInterval(3.5)
    -- seq:AppendCallback(function()
    --     destroy(fx_pre_1)
    -- end)
    seq:AppendInterval(0.5)
    self.fx_pre = newObject("shengmingkelong",GameObject.Find("3DNode").transform)
    self.fx_pre.gameObject:SetActive(false)
    seq:AppendCallback(function()
        self.fx_pre.gameObject:SetActive(true)
    end)
    seq:AppendInterval(2)
    seq:AppendCallback(function()
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
    local seq = DoTweenSequence.Create()
    for i = 1,2 do 
        local effecter_car = DriveCarManager.GetCarByNo(i)
        local obj = self.fx_pre.transform:Find("xin_img1/xin_img" .. (i + 1))
        seq:Insert(0,obj.transform:DOMoveBezier(Vector3.New(effecter_car.transform.position.x,effecter_car.transform.position.y,-0.5),0.5,1))
        seq:InsertCallback(1.1,function()
            destroy(obj.gameObject)
            local cur_v = DrivePlayerManager.GetShowAttribute(effecter_car.car_data.seat_num,effecter_car.car_data.car_id,"hp")
            local total_v = DrivePlayerManager.GetShowAttribute(effecter_car.car_data.seat_num,effecter_car.car_data.car_id,"hp_max")
            local damage_fx = DriveAnimManager.PlayDamageFx("50%",effecter_car:GetCenterPosition(),cur_v,total_v / 2,total_v,function()
                if i == 2 then
                    if self.loop_sound_key then
                        AudioManager.CloseSound(self.loop_sound_key)
                        self.loop_sound_key = nil
                    end
                    self:PlayObjs()
                    destroy(self.fx_pre)
                    self:OnActEnd()
                end
            end,"hp")
            -- damage_fx.transform:Find("@damage_txt").gameObject:SetActive(false)
        end)
    end
end