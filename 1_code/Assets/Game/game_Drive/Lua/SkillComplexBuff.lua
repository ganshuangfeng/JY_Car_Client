-- 技能动画效果类：黑夜
local basefunc = require "Game/Common/basefunc"

SkillComplexBuff = basefunc.class(SkillBase)

local C = SkillComplexBuff
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillComplexBuff.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.buff_create or v.buff_change or v.obj_car_modify_property then
            return true
        end
    end
end

function C:OnTriggerBefore()
    if self.skill_data and self.skill_data.trigger_msg then
        if self.skill_data.trigger_msg == "on_create_after" or self.skill_data.trigger_msg == "on_refresh_after" then
            local objs = self:GetObjs()
            if objs and next(objs) then
                for k,v in ipairs(objs) do
                    if v.obj_car_modify_property then
                        self:PlayObjData(v)
                    end
                end
                self:OnActEnd()
                return
            end
        end
    end
    self.obj_datas = self:GetObjs()
    if self.obj_datas and next(self.obj_datas) then
        DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx","com_img_clsj_map3","",true,self.launcher_car:GetCenterPosition(),function()
            self:OnTriggerMain()
        end,true)
    else
        self:OnActEnd()
    end
end

function C:OnTriggerMain()
    self.obj_datas = self:GetObjs()
    local other_datas = {}
    for k,v in ipairs(self.obj_datas) do 
        if v.buff_create then
            local k_v_other_data = {}
            if v.buff_create and v.buff_create.buff_data and v.buff_create.buff_data.other_data then
                for k,v in ipairs(v.buff_create.buff_data.other_data) do
                    k_v_other_data[v.key] = v.value 
                end
                other_datas[#other_datas + 1] = k_v_other_data
            end
        end
        if v.buff_change then
            local k_v_other_data = {}
            if v.buff_change and v.buff_change.buff_data and v.buff_change.buff_data.other_data then
                for k,v in ipairs(v.buff_change.buff_data.other_data) do
                    k_v_other_data[v.key] = v.value 
                end
                other_datas[#other_datas + 1] = k_v_other_data
            end
        end
        if v.obj_car_modify_property then
            self:PlayObjData(v)
        end
    end
    local seq = DoTweenSequence.Create()
    for k,v in ipairs(other_datas) do
        local desc
        local modify_key_name_map = {
            bj_gl = "暴击概率",
            sp = "圈数",
            at = "攻击",
            hp_max = "生命上限",
            bullet_max = "子弹上限",
            attack_radius = "攻击范围"
        }
        if modify_key_name_map[v.modify_key_name] and tonumber(v.modify_value) > 0 then
            desc = modify_key_name_map[v.modify_key_name] .. "+" .. v.modify_value .. (tonumber(v.modify_type) == 2 and "%" or "")
        end
        if desc then
            seq:AppendCallback(function()
                AudioManager.PlaySound(audio_config.drive.com_main_map_cheliangshengji.audio_name)
                local piaozi_pre = newObject("tankezidanshangxian_font",GameObject.Find("Canvas/LayerLv3").transform)
                piaozi_pre.transform.localPosition = self.launcher_car:GetUICenterPosition()
                piaozi_pre.transform:Find("Text"):GetComponent("Text").text = desc
                local _seq = DoTweenSequence.Create()
                _seq:Append(piaozi_pre.transform:DOLocalMoveY(piaozi_pre.transform.localPosition.y + 100,1))
                _seq:Insert(0.5,piaozi_pre.transform:GetComponent("CanvasGroup"):DOFade(0,0.5))
                _seq:AppendCallback(function()
                    destroy(piaozi_pre)
                end)
            end)
            seq:AppendInterval(0.8)
        end
    end
    seq:AppendCallback(function()
        self:OnActEnd()
    end)
end

function C:OnChange()
    self.launcher_car = DriveCarManager.GetCarByNo(self.skill_data.owner_id)
    self:OnTriggerBefore()
end