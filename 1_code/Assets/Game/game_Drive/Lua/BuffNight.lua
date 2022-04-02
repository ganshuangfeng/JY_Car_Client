local basefunc = require "Game/Common/basefunc"

BuffNight = basefunc.class(BuffBase)

local M = BuffNight
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffNight.super.ctor(self,buff_data)
end

--刷新回调
function M:OnRefresh()
    dump({data = self.buff_data,cfg = self.buff_cfg},"黑夜buff_refresh")
    self:SetBuffModify(self.buff_data,self.buff_cfg)
end

--创建回调
function M:OnCreate()
    dump(self.buff_data,"<color=red>黑夜技能创建</color>")
    self:SetBuffModify(self.buff_data,self.buff_cfg)
    self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    local piaozi_pre = newObject("tankezidanshangxian_font",GameObject.Find("Canvas/LayerLv3").transform)
    piaozi_pre.transform.localPosition = self.car:GetUICenterPosition()
    local modify_value = 20
    for k,v in ipairs(self.buff_data.other_data) do
        if v.key == "modify_value" then
            modify_value = tonumber(v.value)
        end
    end
    piaozi_pre.transform:Find("Text"):GetComponent("Text").text = "Miss率提升" .. modify_value .. "%"
    local _seq = DoTweenSequence.Create()
    _seq:Append(piaozi_pre.transform:DOLocalMoveY(piaozi_pre.transform.localPosition.y + 100,2))
    _seq:Insert(1,piaozi_pre.transform:GetComponent("CanvasGroup"):DOFade(0,1))
    _seq:AppendCallback(function()
        destroy(piaozi_pre)
    end)
    self:OnTrigger()
end

--移除回调
function M:OnDead()
    dump(self.buff_data,"<color=red>黑夜技能移除 buff_data</color>")
    self.buff_data.modify_type = 1
    self.buff_data.modify_value = 144
    self.buff_data.modify_key_name = "attack_radius"
    local car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    --修改攻击范围
    if car.set_effect_field_radius then
        car:set_effect_field_radius(self.buff_data)
    elseif car[car.config.car_type].set_effect_field_radius then
        car[car.config.car_type]:set_effect_field_radius(self.buff_data)
    else
        dump(car,"<color=red>未实现修改攻击范围方法</color>")
    end
    self:PlayObjs()
    self:OnActEnd()
end