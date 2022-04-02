-- 创建时间:2021-02-24
-- 游戏电锯车车辆脚本
local basefunc = require "Game/Common/basefunc"
DriveCarFaleli = basefunc.class()

local C = DriveCarFaleli
C.name = "DriveCarFaleli"

function C.Create(super)
    return C.New(super)
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
	self.listener = {}
    self.listener["logic_drive_game_process_data_msg_player_op"] = basefunc.handler(self,self.on_drive_game_process_data_msg_player_op)
    self.listener["car_move_end"] = basefunc.handler(self,self.on_car_move_end)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
    if self.big_saw_sound_key then
        AudioManager.CloseSound(self.big_saw_sound_key)
        self.big_saw_sound_key = nil
    end
    if self.small_saw_sound_key then
        AudioManager.CloseSound(self.small_saw_sound_key)
        self.small_saw_sound_key = nil
    end
    self:RemoveListener()
    clear_table(self)
end

function C:ctor(super)
    self.super = super
    self:MakeListener()
    self:AddListener()
    for i = 1,2 do
        self["normal_idle_" .. i] = self.super["car_chilun_" .. i].transform:Find("PT_xuanzhuanlizi_xuanhuan")
        self["normal_close" .. i] = self.super["car_chilun_" .. i].transform:Find("PT_xuanzhuanlizi_tingzhi")
        self["big_idle_" .. i] = self.super["car_chilun_" .. i].transform:Find("BIG_xuanzhuanlizi_xuanhuan")
        self["big_close_" .. i] = self.super["car_chilun_" .. i].transform:Find("BIG_xuanzhuanlizi_tingzhi")
    end
end

function C:OpenSaw()
    for i = 1,2 do
        self["normal_idle_" .. i].gameObject:SetActive(true)
    end
end

function C:CloseSaw()
    for i = 1,2 do
        if self["normal_idle_" .. i].gameObject.activeSelf then
            self["normal_idle_" .. i].gameObject:SetActive(false)
            self["normal_close" .. i].gameObject:SetActive(true)
            local seq = DoTweenSequence.Create({dotweenLayerKey = DriveLogicProcess.dotween_key})
            seq:AppendInterval(1.75)
            seq:OnForceKill(function()
                self["normal_close" .. i].gameObject:SetActive(false)
                if self.small_saw_sound_key  then
                    AudioManager.CloseSound(self.small_saw_sound_key)
                    self.small_saw_sound_key = nil
                end
            end)
        end
        if self["big_idle_" .. i].gameObject.activeSelf then
            self["big_idle_" .. i].gameObject:SetActive(false)
            self["big_close_" .. i].gameObject:SetActive(true)
            local seq = DoTweenSequence.Create({dotweenLayerKey = DriveLogicProcess.dotween_key})
            seq:AppendInterval(1.75)
            seq:OnForceKill(function()
                self["big_close_" .. i].gameObject:SetActive(false)
                self.big_skill_status = false
                if self.big_saw_sound_key then
                    AudioManager.CloseSound(self.big_saw_sound_key)
                    self.big_saw_sound_key = nil
                end
            end)
        end
    end
end

function C:ShowBigSaw(b)
    self.big_skill_status = b
    if b then
        for i = 1,2 do
            self["big_idle_" .. i].gameObject:SetActive(true)
        end
    else
        for i = 1,2 do
            if self["big_idle_" .. i].gameObject.activeSelf then
                self["big_idle_" .. i].gameObject:SetActive(false)
                self["big_close_" .. i].gameObject:SetActive(true)
                local seq = DoTweenSequence.Create()
                seq:AppendInterval(1.75)
                seq:AppendCallback(function()
                    self["big_close_" .. i].gameObject:SetActive(false)
                    if self.big_saw_sound_key then
                        AudioManager.CloseSound(self.big_saw_sound_key)
                        self.big_saw_sound_key = nil
                    end
                end)
            end
        end
    end
end

--流程控制 回合开始时转动电锯
function C:on_drive_game_process_data_msg_player_op(data)
	local player_op = DriveModel.data.players_info[self.super.car_data.seat_num].player_op
    if not player_op then
		return
	end
    
	if player_op.op_type == DriveModel.OPType.accelerator_all 
        or player_op.op_type == DriveModel.OPType.accelerator_big 
        or player_op.op_type == DriveModel.OPType.accelerator_small then
        -- self.super.normal_saw_fx.gameObject:SetActive(true)
    --为车辆添加拖尾
        self:ShowBigSaw(false)
		self:OpenSaw()
    end
end

--流程控制 移动结束后 停止旋转
function C:on_car_move_end(data)
    if data.car_no == self.super.car_data.car_no then
        self:CloseSaw()
    end
end

function C:SetChainSaw(bool)
    self.add_chain_saw = bool
    if bool then
        for i = 1,2 do
            self["normal_idle_" .. i] = self.super["car_chilun_" .. i].transform:Find("PT_xuanqianghua_xuanhuan_1") or self.super["car_chilun_" .. i].transform:Find("PT_xuanzhuanlizi_xuanhuan")
        end
    end
end

------------------------通用需要重写的几个方法
function C:SetHighLight(enabled,color)
    if self.super.model and self.super.model.transform:Find("falali") and self.super.model.transform:Find("falali"):GetComponent("Highlighter") then
        local component = self.super.model.transform:Find("falali"):GetComponent("Highlighter")
        component.enabled = enabled
        if color then
            component.tween.gradient.color = color
        end
    end
end


function C:SetFbxMaterial(material_name)
    if self.super.model then
        local material
        if material_name then
            material = GetMaterial("falali_" .. material_name)
        else
            material = GetMaterial("falali_level1_4")
        end
        if material then
            if IsEquals (self.super.model:Find("falali/falali_level1")) then
                self.super.model:Find("falali/falali_level1"):GetComponent("SkinnedMeshRenderer").material = material
                -- self.super.car_paotai_3d:Find("tank_body"):GetComponent("SkinnedMeshRenderer").material = material
                -- self.super.car_paotai_3d:Find("tank_weapon"):GetComponent("SkinnedMeshRenderer").material = material
                self.current_material_name = material_name
            end
        else
            dump("法拉利的材质球不存在:" .. (material_name or "nil"))
        end
    end
end
function C:PlayCarBoomFly(cbk)
    if self.super.car and self.super.car.transform:GetComponent("Animator") then
        local animator = self.super.car.transform:GetComponent("Animator")
        animator.enabled = true
        animator:Play("cheliang_dilei",0,0)
        animator.speed = 2/3
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(1.5)
        seq:AppendCallback(function()
            animator.enabled = false
            self.super.model.transform.localPosition = Vector3.zero
            self.super.model.transform.localRotation = Quaternion:SetEuler(-90,0,0)
            if cbk then cbk() end
        end)
    end
end