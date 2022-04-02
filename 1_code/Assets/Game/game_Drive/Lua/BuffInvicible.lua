local basefunc = require "Game/Common/basefunc"

BuffInvicible = basefunc.class(BuffBase)

local M = BuffInvicible
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:MakeListener()
	self.listener = {}
    self.listener["notify_show_attribute_change"] = basefunc.handler(self,self.on_notify_show_attribute_change)
end

function M:ctor(buff_data)
    BuffInvicible.super.ctor(self,buff_data)
end

--创建回调
function M:OnCreate()
    self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.1)
    seq:AppendCallback(function()
        self:OnTrigger()
    end)
end
--刷新时回调
function M:OnRefresh()
    self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    self.car:SetFbxMaterial("wudi")
    if not self.fx_pre and self.buff_data.act ~= BuffManager.act_enum.dead then
        self.fx_pre = newObject("buff_wudi",self.car.car.transform)
	end
end

--移除回调
function M:OnDead()
    dump(self.buff_data,"<color=red>无敌技能移除 buff_data</color>")
    if self.fx_pre then
        destroy(self.fx_pre)
        self.fx_pre = nil
    end
    self.car:SetHighLight(false)
    self.car:SetFbxMaterial()
    self:PlayObjs()
    self:OnActEnd()
end

function M:on_notify_show_attribute_change(parm)
    if parm.modify_key_name == "hp" and parm.modify_tag then
        for k,v in ipairs(parm.modify_tag) do 
            if v == "invincible" then
                self:PlayDefendAttack()
            end
        end
    end
end

function M:PlayDefendAttack()
    if self.fx_pre and IsEquals(self.fx_pre) then
        -- self.fx_pre.transform:Find("wudiyaoji_shouji").gameObject:SetActive(false)
        -- self.fx_pre.transform:Find("wudiyaoji_shouji").gameObject:SetActive(true)
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(0.5)
        seq:AppendCallback(function()
            if IsEquals(self.fx_pre) then
                -- self.fx_pre.transform:Find("wudiyaoji_shouji").gameObject:SetActive(false)
            end
        end)
    end
end