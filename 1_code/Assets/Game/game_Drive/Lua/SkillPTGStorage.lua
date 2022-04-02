-- 创建时间:2021-03-17
-- 技能动画效果类：平头哥蓄力
local basefunc = require "Game/Common/basefunc"

SkillPTGStorage = basefunc.class(SkillBase)

local C = SkillPTGStorage
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillPTGStorage.super.ctor(self,skill_data)
    local car = DriveCarManager.GetCarByNo(self.skill_data.owner_id)
    self.gameObject = newObject("SkillPTGStorage",car.tail_node.transform)
    self.transform = self.gameObject.transform
    basefunc.GeneratingVar(self.transform, self)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd") then
            return true
        end
    end
end
local progress_max_width = 1.38
local progress_max_height = 0.6


function C:RefreshSubclass()
    if self.skill_data then
        local cur_storage = self.skill_data.storage_value
        local max_storage = self.skill_data.storage_value_max
        self.cur_storage = cur_storage
        self.max_storage = max_storage
        if self.gameObject then
            self.num_txt.text = cur_storage .. "/" .. max_storage
            if self.progress_img then
                local fill_amount = tonumber(cur_storage) / tonumber(max_storage)
                self.progress_img:GetComponent("SpriteRenderer").size = {x = progress_max_width * fill_amount,y = progress_max_height}
            end
        end
        Event.Brocast("refresh_ptg_storage",{cur_storage = cur_storage,max_storage = max_storage,owner_id = self.skill_data.owner_id})
    end
end

function C:OnChange(data)
    local cur_storage,max_storage = self:ChangeStorage(data.skill_data.other_data)
    if self.gameObject then
        self.num_txt.text = cur_storage .. "/" .. max_storage
        if self.progress_img then
            local fill_amount = tonumber(cur_storage) / tonumber(max_storage)
            self.progress_img:GetComponent("SpriteRenderer").size = {x = progress_max_width * fill_amount,y = progress_max_height}
        end
    end
    Event.Brocast("refresh_ptg_storage",{cur_storage = cur_storage,max_storage = max_storage,owner_id = self.skill_data.owner_id})
    self:OnActEnd()
end

function C:ChangeStorage(other_data)
    local cur_storage
    local max_storage
    if other_data and next(other_data) then
        for k,v in ipairs(other_data) do
            if v.key == "storage_value" then
                cur_storage = tonumber (v.value)
                self.cur_storage = self.cur_storage or 0
                if self.cur_storage then
                    local change_value = tonumber(cur_storage) - tonumber(self.cur_storage)
                    if change_value > 0 then
                        self:PlayAddAnim(change_value)
                    end
                end
                self.cur_storage = cur_storage
            elseif v.key == "storage_value_max" then
                max_storage = tonumber(v.value)
                self.max_storage = max_storage
            end
        end
    end
    return cur_storage,max_storage
end

function C:PlayAddAnim(change_value)
    AudioManager.PlaySound(audio_config.drive.com_main_map_huodechuneng.audio_name)
    local fx_pre = newObject("tank_bullet_add",GameObject.Find("Canvas/LayerLv3").transform)
    local fx_tbl = basefunc.GeneratingVar(fx_pre.transform)
    fx_tbl.num_txt.text = TMPNormalStringConvertTMPSpriteStr("+") .. TMPNormalStringConvertTMPSpriteStr(tostring(change_value))
    fx_tbl.icon_img.sprite = GetTexture("com_icon_nl_map3")
    fx_tbl.icon_img.transform.localScale = Vector3.New(1.5,1.5,1)
    fx_pre.transform.position = DriveCarManager.GetCarByNo(self.skill_data.owner_id):GetUICenterPosition()
    local move_y = 100
    local speed = 1
    local seq = DoTweenSequence.Create()
    fx_pre.transform:GetComponent("CanvasGroup").alpha = 0
    fx_pre.transform.localScale = Vector3.New(3,3,1)
    seq:Append(fx_pre.transform:DOScale(Vector3.New(0.4,0.4,1),0.2/speed))
    seq:Join(fx_pre:GetComponent("CanvasGroup"):DOFade(1,0.2/speed))
    seq:Append(fx_pre.transform:DOScale(Vector3.New(0.8,0.8,1),0.1/speed))
    seq:Append(fx_pre.transform:DOLocalMoveY(fx_pre.transform.localPosition.y + move_y,2.5/speed))
    seq:Insert(1.7,fx_pre:GetComponent("CanvasGroup"):DOFade(0,1))
    seq:OnForceKill(function()
        destroy(fx_pre)
    end)
end