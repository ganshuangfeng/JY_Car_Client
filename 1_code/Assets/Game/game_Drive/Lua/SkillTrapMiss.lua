-- 创建时间:2021-01-05
local basefunc = require "Game/Common/basefunc"

SkillTrapMiss = basefunc.class(SkillBase)

local C = SkillTrapMiss
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillTrapMiss.super.ctor(self,skill_data)
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
    -- dump(self.skill_data,"self.skill_data")
    local rbb = RoadBarrierManager.GetRoadBarrier(self.skill_data.owner_id)
    DriveAnimManager.PlayAttributeChangeFx("miss_fx","com_img_miss","",true,rbb.transform.position)
    local fx_pre = GameObject.Instantiate(rbb.gameObject)
    fx_pre.transform:Find("luzhang"):GetComponent("Animator").enabled = false
    -- fx_pre.transform:Find("luzhang/@item_img"):GetComponent("Image").material = nil
    fx_pre.transform:SetParent(GameObject.Find("3DNode/map_node").transform)
    fx_pre.transform.position = rbb.transform.position

    local seq = DoTweenSequence.Create()
    -- seq:Append(fx_pre.transform:GetComponent("CanvasGroup"):DOFade(0,1))
    seq:AppendCallback(function()
        destroy(fx_pre.gameObject)
        self:PlayObjData(self.obj_data)
    end)
    self:OnActEnd()
end