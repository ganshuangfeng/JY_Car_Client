-- 创建时间:2021-03-17
-- 技能动画效果类：平头哥蓄力
local basefunc = require "Game/Common/basefunc"

SkillDLCStorage = basefunc.class(SkillBase)

local C = SkillDLCStorage
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillDLCStorage.super.ctor(self,skill_data)
    local car = DriveCarManager.GetCarByNo(self.skill_data.owner_id)
    self.gameObject = newObject("SkillDLCStorage",car.tail_node.transform)
    self.transform = self.gameObject.transform
    self.transform.localPosition = Vector3.New(0.15,0,0)
    self.transform.localScale = Vector3.New(0.9,0.9,0.9)
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
        local mine_num = self.skill_data.mine_num
        local max_mine_num = self.skill_data.max_mine_num
        if self.gameObject then
            self.num_txt.text = mine_num .. "/" .. max_mine_num
            if self.progress_img then
                local fill_amount = tonumber(mine_num) / tonumber(max_mine_num)
                self.progress_img:GetComponent("SpriteRenderer").size = {x = progress_max_width * fill_amount,y = progress_max_height}
            end
        end
        Event.Brocast("refresh_dlc_storage",{mine_num = mine_num,max_mine_num = max_mine_num,owner_id = self.skill_data.owner_id})
    end
end

function C:OnChange(data)
    local mine_num,max_mine_num = self:ChangeStorage(data.skill_data.other_data)
    if self.gameObject then
        self.num_txt.text = mine_num .. "/" .. max_mine_num
        if self.progress_img then
            local fill_amount = tonumber(mine_num) / tonumber(max_mine_num)
            self.progress_img:GetComponent("SpriteRenderer").size = {x = progress_max_width * fill_amount,y = progress_max_height}
        end
    end
    Event.Brocast("refresh_dlc_storage",{mine_num = mine_num,max_mine_num = max_mine_num,owner_id = self.skill_data.owner_id})
    self:OnActEnd()
end

function C:ChangeStorage(other_data)
    local mine_num
    local max_mine_num
    if other_data and next(other_data) then
        for k,v in ipairs(other_data) do
            if v.key == "mine_num" then
                mine_num = tonumber (v.value)
                if self.mine_num then
                    local change_value = tonumber(mine_num) - tonumber(self.mine_num)
                    if change_value > 0 then
                        self:PlayAddAnim(change_value)
                    end
                end
                self.mine_num = mine_num
            elseif v.key == "max_mine_num" then
                max_mine_num = tonumber(v.value)
                self.max_mine_num = max_mine_num
            end
        end
    end
    return mine_num,max_mine_num
end

function C:PlayAddAnim(change_value)
    AudioManager.PlaySound(audio_config.drive.com_main_map_huodedilei.audio_name)
    local fx_pre = newObject("tank_bullet_add",GameObject.Find("Canvas/LayerLv3").transform)
    local fx_tbl = basefunc.GeneratingVar(fx_pre.transform)
    fx_tbl.num_txt.text = TMPNormalStringConvertTMPSpriteStr("+") .. TMPNormalStringConvertTMPSpriteStr(tostring(change_value))
    fx_tbl.icon_img.sprite = GetTexture("com_icon_dl_1_1_map3")
    fx_tbl.icon_img.transform.localScale = Vector3.New(2,2,1)
    fx_tbl.icon_img.transform.localPosition = Vector3.New(-60,0,0)
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