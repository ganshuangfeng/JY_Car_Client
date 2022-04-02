-- 技能动画效果类：添加子弹上限
local basefunc = require "Game/Common/basefunc"

SkillAddTankBulletLimit = basefunc.class(SkillBase)

local C = SkillAddTankBulletLimit
local fx_name = "violent_weapon_buff_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillAddTankBulletLimit.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.buff_create then
            return true
        end
    end
end

function C:OnTriggerBefore()
    AudioManager.PlaySound(audio_config.drive.com_main_map_addatack.audio_name)
    local img_font = "com_img_djkr_map3"
    if self.skill_cfg.id == 6013 then
        img_font = "com_img_cjdjkr_map3"
    end
    DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx",img_font,"",true,self.launcher_car:GetCenterPosition(),nil,true)
    local fx_pre = newObject("tankezidanshangxian",GameObject.Find("Canvas/LayerLv3").transform)
    fx_pre.transform.localPosition = self.launcher_car:GetUICenterPosition()
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.8)
    seq:AppendCallback(function()
        self:OnTriggerMain()
    end)
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        if IsEquals(fx_pre) then
            destroy(fx_pre)
        end
    end)
end

function C:OnTriggerMain()
    local piaozi_pre = newObject("tankezidanshangxian_font",GameObject.Find("Canvas/LayerLv3").transform)
    piaozi_pre.transform.localPosition = self.launcher_car:GetUICenterPosition()
    local buff_create_data = self:GetObjs()[1]
    local modify_value = 1
    if buff_create_data and buff_create_data.buff_create and buff_create_data.buff_create.buff_data  and buff_create_data.buff_create.buff_data.other_data then
        for k,v in ipairs(buff_create_data.buff_create.buff_data.other_data) do
            if v.key == "modify_value" then
                modify_value = tonumber(v.value)
            end
        end
    end
    modify_value = modify_value or 1
    piaozi_pre.transform:Find("Text"):GetComponent("Text").text = "炮弹上限+" .. modify_value
    AudioManager.PlaySound(audio_config.drive.com_main_map_danjiakuorong.audio_name)
    local seq = DoTweenSequence.Create()
    seq:Append(piaozi_pre.transform:DOLocalMoveY(piaozi_pre.transform.localPosition.y + 100,1))
    seq:Insert(0.5,piaozi_pre.transform:GetComponent("CanvasGroup"):DOFade(0,0.5))
    seq:AppendCallback(function()
        destroy(piaozi_pre)
        self:OnActEnd()
    end)
end