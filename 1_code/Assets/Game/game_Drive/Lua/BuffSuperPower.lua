local basefunc = require "Game/Common/basefunc"

BuffSuperPower = basefunc.class(BuffBase)

local M = BuffSuperPower
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffSuperPower.super.ctor(self,buff_data)
end

--创建回调
function M:OnCreate()
    self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx","com_img_cnyj_map3","",true,self.car:GetCenterPosition(),function()
        AudioManager.PlaySound(audio_config.drive.com_main_map_chaonengyaoji.audio_name)
        if self.car and self.car.model then
            local seq = DoTweenSequence.Create()
            seq:Append(self.car.model.transform:DOScale(Vector3.New(3.6,3.6,3.6),1))
            self.car:SetHighLight(true)
            seq:AppendCallback(function()
                self:OnTrigger()
            end)
        else
            local seq = DoTweenSequence.Create()
            seq:AppendInterval(0.1)
            seq:AppendCallback(function()
                self:OnTrigger()
            end)
        end
    end)
end
--刷新时回调
function M:OnRefresh()
    self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    self.car:SetFbxMaterial("chaonengaoji")
    if not self.fx_pre and self.buff_data.act ~= BuffManager.act_enum.dead then
        self.fx_pre = newObject("chaonengyaoji",self.car.car.transform)
	end
end

--移除回调
function M:OnDead()
    dump(self.buff_data,"<color=red>无敌技能移除 buff_data</color>")
    if self.fx_pre then
        destroy(self.fx_pre)
        self.fx_pre = nil
    end
    self.car.model.transform.localScale = Vector3.New(3,3,3)
    self.car:SetFbxMaterial()
    self:PlayObjs()
    self:OnActEnd()
end