-- 创建时间:2021-03-25
-- 技能动画效果类：清除路障
local basefunc = require "Game/Common/basefunc"

SkillClearTrap = basefunc.class(SkillBase)

local C = SkillClearTrap
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillClearTrap.super.ctor(self,skill_data)
end

function C.CloseRoadBarrier(road_barrier,callback)
    local seq = DoTweenSequence.Create()
    local fx_pre = newObject("chanzi",GameObject.Find("Canvas/LayerLv3").transform)
    fx_pre.transform.position = DriveModel.Get3DTo2DPoint(road_barrier.transform.position)
    road_barrier.gameObject:SetActive(false)
    local sprite = road_barrier.item_img.sprite
    fx_pre.transform:Find("@zhangai_img"):GetComponent("Image").sprite = sprite
    fx_pre.transform:Find("@zhangai_img"):GetComponent("Image"):SetNativeSize()
    seq:AppendInterval(4.5)
    seq:Append(fx_pre.transform:GetComponent("CanvasGroup"):DOFade(0,1))
    seq:AppendCallback(function()
        if callback then callback() end
    end)
end

