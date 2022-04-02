-- 技能动画效果类：终点关闭
local basefunc = require "Game/Common/basefunc"

SkillEndOff = basefunc.class(SkillBase)

local C = SkillEndOff
local fx_name = "violent_weapon_buff_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillEndOff.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and  v.obj_car_modify_property.modify_key_name == "at"  then
            return true
        end
    end
end


function C:OnTriggerBefore()
    AudioManager.PlaySound(audio_config.drive.com_main_map_addatack.audio_name)
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    self.obj_datas = self:GetObjs()
    if self.obj_datas and next(self.obj_datas) then
        for i,v in ipairs(self.obj_datas) do
            self:PlayObjData(v)
        end
    end
    -- local fx_pre = newObject("huanjingzhongxin",GameObject.Find("Canvas/LayerLv3").transform)
    -- local img_font_cfg = {
    --     [1] = "zt_img_zzgb_z",
    --     [2] = "zt_img_zzgb_zz",
    --     [3] = "zt_img_zzgb_g",
    --     [4] = "zt_img_zzgb_b",
    -- }
    -- for i = 1,4 do 
    --     local img = fx_pre.transform:Find("huanjingzhongxin_ziti").transform:Find("@car_img" .. (i == 1 and "" or " (" .. i - 1 .. ")") ):GetComponent("Image")
    --     img.sprite = GetTexture(img_font_cfg[i])
    -- end
    local seq = DoTweenSequence.Create()
    -- seq:AppendInterval(3.5)
    seq:AppendInterval(0.5)
    seq:OnForceKill(function()
        destroy(fx_pre)
        self:OnActEnd()
    end)
end