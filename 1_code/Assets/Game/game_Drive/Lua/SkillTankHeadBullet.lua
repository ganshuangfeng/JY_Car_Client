-- 创建时间:2021-02-21
-- 游戏坦克车辆脚本
local basefunc = require "Game/Common/basefunc"
SkillTankHeadBullet = basefunc.class()
local M = SkillTankHeadBullet
M.name = "SkillTankHeadBullet"

function M.Create(super)
    return M.New(super)
end

function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:MakeListener()
	self.listener = {}
    --滑动时显示
    self.listener["logic_drive_game_process_data_msg_player_action"] = basefunc.handler(self,self.on_drive_game_process_data_msg_player_action)
    self.listener["car_move_slide"] = basefunc.handler(self,self.on_car_move_slide)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
    clear_table(self)
end

function M:ctor(super)
    self.super = super
    self:MakeListener()
    self:AddListener()
    self:InitUI()
end

function M:CheckSkillIsMe()
    if true then return true end
    return DriveModel.CheckOwnerIsMe(self.super.skill_data)
end

function M:SetStyle()
    
end

local default_bullet_count = 0

function M:InitUI()
    if self.init_ui then return end
    if not self:CheckSkillIsMe() then return end

	--自己的技能
	local car = DriveCarManager.GetCarByNo(self.super.skill_data.owner_id)
    local parent = car.tail_node
    if not IsEquals(parent) then return end

    self.car = car
    self.init_ui = true
	self.gameObject = newObject("SkillTankHeadBullet",parent.transform)
    self.gameObject.name = self.super.skill_data.skill_id
	self.transform = self.gameObject.transform
    self.max_bullet_count = tonumber (self.super.skill_data.max_extra_bullet_num) or 6 --坦克子弹上限
    self.bullet_count = 0   --当前坦克子弹数量
	basefunc.GeneratingVar(self.transform, self)
	self:SetStyle()

    if self.super.skill_data.other_data then
        for k,v in ipairs(self.super.skill_data.other_data) do
            if v.key == "extra_bullet_num" then
                self.bullet_count = tonumber(v.value)
            elseif v.key == "max_extra_bullet_num" then
                self.max_bullet_count = tonumber(v.value) + default_bullet_count
            end
        end
    end
    if self.num_txt and self.num_txt.transform:GetComponent("Animator") then
        self.num_txt.transform:GetComponent("Animator").enabled = false
    end
    self:ShowBulletItem(true)
    self:RefreshView()
end

function M:Refresh()
    if not self:CheckSkillIsMe() then return end
	--自己的道具
    if not self.init_ui then
        self:InitUI()
        return
    end
    self:RefreshView()
end

function M:RefreshView(ani)
    if not self:CheckSkillIsMe() then return end
    self.bullet_count = self.bullet_count or 0
    local now_num = tonumber(self.super.skill_data.extra_bullet_num) or 0
    local cur_num = self.bullet_count or 0
    if cur_num == now_num then
        self.num_txt.text = self.bullet_count + default_bullet_count .. "/" .. self.max_bullet_count
        return
    elseif cur_num < now_num then
        for i=1,now_num - cur_num do
            self:Add(ani)
        end
    elseif cur_num > now_num then
        for i=1,cur_num - now_num do
            self:Remove(ani)
        end
    end
end

function M:Add(ani)
    self.bullet_count = self.bullet_count + 1
    if self.bullet_count == self.max_bullet_count - default_bullet_count then
        self.big_img.gameObject:SetActive(true)
    end
    AudioManager.PlaySound(audio_config.drive.com_main_map_danyaobuchong.audio_name)
    self.num_txt.text = (self.bullet_count + default_bullet_count) .. "/" .. self.max_bullet_count
    if ani then
       --增加子弹特效
        local fx_pre = newObject("tank_bullet_add",GameObject.Find("Canvas/LayerLv3").transform)
        fx_pre.transform.position = DriveCarManager.GetCarByNo(self.super.skill_data.owner_id):GetUICenterPosition()
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
end

function M:Remove(ani)
    self.bullet_count = self.bullet_count - 1
    if self.bullet_count < 0 then
        self.bullet_count = 0
    end
    if self.bullet_count <= self.max_bullet_count - default_bullet_count then
        self.big_img.gameObject:SetActive(false)
    end
    self.num_txt.text = (self.bullet_count + default_bullet_count) .. "/" .. self.max_bullet_count
end

function M:OnChange(data)
    local now_num = 0
    local now_max_value = self.max_bullet_count
    for k,v in ipairs(data.skill_data.other_data) do
        if v.key == "extra_bullet_num" then
            now_num = tonumber(v.value)
        elseif v.key == "max_extra_bullet_num" then
            now_max_value = tonumber(v.value) + default_bullet_count
        end
    end
    local cur_num = self.bullet_count or 0
    local seq = DoTweenSequence.Create()
    if cur_num < now_num then
        for i=1,now_num - cur_num do
            seq:AppendCallback(function()
                self:Add(true)
            end)
            seq:AppendInterval(0.2)
        end
    elseif cur_num > now_num then
        for i=1,cur_num - now_num do
            seq:AppendCallback(function()
                self:Remove(true)
            end)
            seq:AppendInterval(0.2)
        end
    end
    seq:OnForceKill(function()
        self.max_bullet_count = now_max_value
        self:RefreshView()
    end)
end

function M:ShowBulletItem(b)
    self.content.gameObject:SetActive(b)
end

function M:on_drive_game_process_data_msg_player_action(data)
	local player_action = DriveModel.data.players_info[self.car.car_data.seat_num].player_action
	if player_action then
        if player_action.op_type == DriveModel.OPType.accelerator_big then
            self:ShowBulletItem(false)
        else
            self:ShowBulletItem(true)
		end
	end
end

function M:on_car_move_slide(data)
    if data.car_no == self.car.car_data.car_no then
        self:ShowBulletItem(true)
    end
end

function M:PlayNoBullet()
 
    if self.num_txt and self.num_txt.transform:GetComponent("Animator") then
        local animator = self.num_txt.transform:GetComponent("Animator")
        local seq = DoTweenSequence.Create()
        animator.enabled = true
        seq:AppendInterval(1)
        seq:AppendCallback(function()
            animator.enabled = false
        end)
    end
end