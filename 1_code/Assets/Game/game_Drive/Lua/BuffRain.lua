local basefunc = require "Game/Common/basefunc"

BuffRain = basefunc.class(BuffBase)

local M = BuffRain
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffRain.super.ctor(self,buff_data)
end

function M:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and v.obj_car_modify_property.modify_key_name == "sp" then
            return true
        end
    end
end

--创建回调
function M:OnCreate()
    self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    local seq = DoTweenSequence.Create()
    local piaozi_pre = newObject("tankezidanshangxian_font",GameObject.Find("Canvas/LayerLv3").transform)
    piaozi_pre.transform.localPosition = self.car:GetUICenterPosition()
    local modify_value = 20
    for k,v in ipairs(self.buff_data.other_data) do
        if v.key == "modify_value" then
            modify_value = tonumber(v.value)
        end
    end
    piaozi_pre.transform:Find("Text"):GetComponent("Text").text = "速度降低" .. modify_value .. "%"
    local _seq = DoTweenSequence.Create()
    _seq:Append(piaozi_pre.transform:DOLocalMoveY(piaozi_pre.transform.localPosition.y + 100,2))
    _seq:Insert(1,piaozi_pre.transform:GetComponent("CanvasGroup"):DOFade(0,1))
    _seq:AppendCallback(function()
        destroy(piaozi_pre)
    end)
    seq:AppendInterval(0.1)
    seq:AppendCallback(function()
        self:OnTrigger()
    end)
end
--刷新时回调
function M:OnRefresh()
    if not self.fx_pre and self.buff_data.act ~= BuffManager.act_enum.dead then
        self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
        self.fx_pre = newObject("xiayu_cheliangshoushen",self.car.car.transform)
	end
end

--移除回调
function M:OnDead()
    dump(self.buff_data,"<color=red>下雨技能移除 buff_data</color>")
    if self.fx_pre then
        destroy(self.fx_pre)
        self.fx_pre = nil
    end
    self:PlayObjs()
    self:OnActEnd()
end