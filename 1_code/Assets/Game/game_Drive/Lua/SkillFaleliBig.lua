-- 创建时间:2021-01-04
-- 技能动画效果类：吸金炸弹
local basefunc = require "Game/Common/basefunc"

SkillFaleliBig = basefunc.class(SkillBase)

local C = SkillFaleliBig

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillFaleliBig.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_move or v.buff_create then
            return true
        end
    end
end

function C:OnTriggerBefore()

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.5)
    seq:AppendCallback(function()
        self.launcher_car.DriveCarFaleli:ShowBigSaw(true)
    end)
    --为车辆添加拖尾
    self.tail_fx = newObject("BIG_faleli_jiasutuowei",self.launcher_car.car.transform)
    -- self.tail_fx.transform.localPosition = Vector3.New(0,0,0)
    DriveAnimManager.PlayBigSkillNameFx("com_img_smcs_map3",self.launcher_car:GetCenterPosition(),function()
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
    local tail_fx = self.tail_fx
    local funcs = {
        stop_call = function ()
            ---移除拖尾
            if IsEquals(self.tail_fx) then
                destroy(self.tail_fx)
            elseif IsEquals(tail_fx) then
                destroy(tail_fx)
                tail_fx = nil
            end
            self:OnTriggerEnd()
        end,
        end_call = function ()
            ---移除拖尾
            if IsEquals(self.tail_fx) then
                destroy(self.tail_fx)
            elseif IsEquals(tail_fx) then
                destroy(tail_fx)
                tail_fx = nil
            end
            self:OnTriggerEnd()
        end
    }
    local objs = self:GetObjs()
    local buff_create
    local obj_car_move
    for k,v in ipairs(objs) do 
        if v.buff_create then
            buff_create = v
        elseif v.obj_car_move then
            obj_car_move = v
        end        
    end
    self:PlayObjData(obj_car_move,nil,funcs)
    self:PlayObjData(buff_create)
end

function C:OnTriggerEnd()

end