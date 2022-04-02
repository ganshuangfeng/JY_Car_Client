-- 创建时间:2021-02-21
-- 游戏坦克车辆脚本
local basefunc = require "Game/Common/basefunc"
DriveCarTank = basefunc.class()

local C = DriveCarTank
C.name = "DriveCarTank"

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
    self.listener["logic_drive_game_process_data_msg_player_action"] = basefunc.handler(self,self.on_drive_game_process_data_msg_player_action)
    -- self.listener["car_move_end"] = basefunc.handler(self,self.on_car_move_end)
    self.listener["car_move_slide"] = basefunc.handler(self,self.on_car_move_slide)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end
--默认的攻击范围（服务器数据）
local normal_effect_radius = 600
--图片的范围
local base_size = 3.076924 * (normal_effect_radius / 720)

function C:MyExit()
    self:RemoveListener()
    clear_table(self)
end

function C:ctor(super)
    self.super = super
    self.animator = self.super.car_paotai_3d.transform:Find("tank_weapon"):GetComponent("Animator")
    self.animator.enabled = false
    self:MakeListener()
    self:AddListener()
    self.effect_field_radius = normal_effect_radius * 1
    self.super.field_1_img.transform.localScale = Vector3.one * base_size
    --重写GetCenterPosition 方法
    self.super.GetCenterPosition = function(_self)
        return _self.model.transform.position
    end
    self.super.GetUICenterPosition = function(_self)
        return DriveModel.Get3DTo2DPoint(_self:GetCenterPosition())
    end
end

function C:SetNormalEffectRadius(radius)
    normal_effect_radius = radius
    base_size = 3.076924 * (normal_effect_radius / 720)
    self.effect_field_radius = normal_effect_radius * 1
    self.super.field_1_img.transform.localScale = Vector3.one * base_size
end

--将炮台对准指定位置
function C:MoveTurretTowardsCar(target_pos,callback)
    local m_pos = self.super:GetCenterPosition()
    local m_rotation = self.super.car.localEulerAngles.z
    local dis = {x = target_pos.x - m_pos.x,y = target_pos.y - m_pos.y}
    local euler_z = (180 / math.pi * tls.pToAngleSelf(dis))
    dump({m_rotation = m_rotation, euler_z = euler_z,target_pos = target_pos,m_pos = m_pos},"<color=red>炮台旋转</color>")
    --当前偏转角 + 本地坦克偏转角
    euler_z = - (euler_z - m_rotation)
    local seq = DoTweenSequence.Create()
    if euler_z ~= 0 then
        AudioManager.PlaySound(audio_config.drive.com_main_hushi_paotazhuandong.audio_name)
    end
    seq:Append(self.super.car_paotai_3d.transform:DOLocalRotate(Vector3.New(-90,0,euler_z),1))
    seq:OnForceKill(function()
        if callback then callback(dis) end
    end)
end

--复位炮台
function C:ResetTurretRotation(callback)
    local seq = DoTweenSequence.Create()
    seq:Append(self.super.car_paotai_3d.transform:DOLocalRotate(Vector3.New(-90,0,0),1))
    seq:OnForceKill(function()
        if callback then callback() end
    end)
end

--炮台开火
function C:TurretFire(is_big,callback_1,callback_2)
    local _animator = self.super.car_paotai_3d.transform:GetComponent("Animator")
    self.animator = self.super.car_paotai_3d.transform:Find("tank_weapon"):GetComponent("Animator")
    _animator.enabled = true
    self.animator.enabled = true
    local obj
    self.super.fire_obj.gameObject:SetActive(false)
    self.super.big_fire_obj.gameObject:SetActive(false)
    if is_big then
        obj =  GameObject.Instantiate(self.super.big_fire_obj)
        obj.transform.position = self.super.big_fire_obj.position
        obj.transform.rotation = self.super.big_fire_obj.rotation
    else
        obj = GameObject.Instantiate(self.super.fire_obj)
        obj.transform.position = self.super.fire_obj.position
        obj.transform.rotation = self.super.fire_obj.rotation
    end
    _animator:Play("tanke_kaipao_3d",0,0)
    self.animator:Play("tanke_kaipao_3d",0,0)
    if self.target_obj then
        destroy(self.target_obj)
        self.target_obj = nil
    end
    local seq = DoTweenSequence.Create()
    seq:AppendCallback(function()
        if callback_1 then callback_1()end
        obj.gameObject:SetActive(true)
        if is_big then
            AudioManager.PlaySound(audio_config.drive.com_main_hushi_dakaipao.audio_name)
        else
            AudioManager.PlaySound(audio_config.drive.com_main_hushi_xiaokaipao.audio_name)
        end
    end)
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        if callback_2 then callback_2()end
    end)
    seq:AppendInterval(5)
    seq:AppendCallback(function()
        destroy(obj.gameObject)
    end)
end

--炮台显示位置
function C:ShowTurretEffectField(show_lock,cbk)
    if self.show_seq then
        self.show_seq:Kill()
        self.show_seq = nil
    end
    local seq = DoTweenSequence.Create()
    self.show_seq = seq
    self:ChangeFieldColor(Color.green)
    local canvas_group = self.super.field_node.transform:GetComponent("CanvasGroup")
    -- self.super.field_node.transform.localScale = Vector3.New(0.1,0.1,1)
    -- canvas_group.alpha = 1
    seq:Append(canvas_group:DOFade(1,2):OnStart(
        function (  )
            DOFadeSpriteRender(canvas_group,1,2)
        end
    ))
    -- seq:Append(self.super.field_node.transform:DOScale(Vector3.New(1.9,1.9,1),1))
    if show_lock then
        local car_pos_datas = self:CheckCarsInRange()
        if car_pos_datas and next(car_pos_datas) then
            for k,v in ipairs(car_pos_datas) do
                seq:AppendInterval(1)
                seq:AppendCallback(self:PlayTargetInRangeAnim(v))
            end
        end
    end
    seq:AppendCallback(function()
        self.show_seq = nil
        if cbk then cbk() end
    end)
end

function C:CloseTurretEffectField(cbk)
    if self.show_seq then
        self.show_seq:Kill()
        self.show_seq = nil
    end
    if self.close_seq then
        self.close_seq:Kill()
        self.close_seq = nil
    end
    local seq = DoTweenSequence.Create()
    self.close_seq = seq
    if IsEquals(self.super.field_node) then
        local canvas_group = self.super.field_node.transform:GetComponent("CanvasGroup")
        if self:CheckCarsInRange() then
            self:ChangeFieldColor(Color.green)
        else
            self:ChangeFieldColor(Color.white)
        end
        seq:AppendInterval(1)
        seq:Append(canvas_group:DOFade(0,1):OnStart(
            function (  )
                DOFadeSpriteRender(canvas_group,0,1)
            end
        ))
        seq:AppendCallback(function()
            self.close_seq = nil
            if cbk then cbk() end
        end)
    end
end

--检查是否有车辆在射程内
function C:CheckCarsInRange()
    local car_pos_datas
    for _k,_v in ipairs(DriveCarManager.cars) do
        for k,v in ipairs(_v) do
            if v.car_data.car_no ~= self.super.car_data.car_no then
                local v_pos = v:GetCenterLocalPosition()
                local m_pos = self.super:GetCenterLocalPosition()
                local dis = tls.pGetDistance(m_pos,v_pos)
                if dis > (0.5 / DriveModel.scale2Dto3D) and dis < (self.effect_field_radius / DriveModel.scale2Dto3D) then
                    car_pos_datas = car_pos_datas or {}
                    car_pos_datas[#car_pos_datas+1] = v:GetUICenterPosition()
                end
            end
        end
    end
    return car_pos_datas
end


--改变范围颜色
function C:ChangeFieldColor(color)
    for i = 1,1 do
        if color == Color.white then
            self.super["field_1_img"].sprite = GetTexture("zd_img_fw_1")
        elseif color == Color.green then
            self.super["field_1_img"].sprite = GetTexture("zd_img_fw_2")
        else
            self.super["field_1_img"].color = color
        end
    end
end

function C:PlayTargetInRangeAnim(pos)
    local parent = GameObject.Find("Canvas/LayerLv3").transform
    self.target_obj = newObject("tangke_suoding",parent)
    self.target_obj.transform.position = pos
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(2)
    seq:OnForceKill(function()
        destroy(self.target_obj)
        self.target_obj = nil
    end)
end

--流程控制 开始操作时直接显示范围不消失
function C:on_drive_game_process_data_msg_player_op(data)
	local player_op = DriveModel.data.players_info[self.super.car_data.seat_num].player_op
    if not player_op then
        self:CloseTurretEffectField()
		return
	end
    
	if player_op.op_type == DriveModel.OPType.accelerator_all 
        or player_op.op_type == DriveModel.OPType.accelerator_big 
        or player_op.op_type == DriveModel.OPType.accelerator_small then
		--所有油门
		self:ShowTurretEffectField(false)
    end
end

--流程控制 如果是小油门则一直显示范围 大油门先消失移动结束后显示范围
function C:on_drive_game_process_data_msg_player_action(data)
	local player_action = DriveModel.data.players_info[self.super.car_data.seat_num].player_action
	if player_action then
        if player_action.op_type ~= DriveModel.OPType.accelerator_small then
            self:CloseTurretEffectField()
		end
	end
end
--流程控制 移动开始滑行时后 如果在射程范围内则显示范围并锁定 否则消失
function C:on_car_move_slide(data)
    if data.car_no == self.super.car_data.car_no then
        -- if self:CheckCarsInRange() then
            self:ShowTurretEffectField(false)
        -- else
            -- self:CloseTurretEffectField()
        -- end
    end
end


--流程控制 移动结束后 如果在射程范围内则显示范围并锁定 否则消失
function C:on_car_move_end(data)
    if data.car_no == self.super.car_data.car_no then
        -- if self:CheckCarsInRange() then
            self:ShowTurretEffectField(true,function()
                self:CloseTurretEffectField()
            end)
        -- else
            -- self:CloseTurretEffectField()
        -- end
    end
end

function C:set_effect_field_radius(data)
    if data.modify_type == 1 then
        --修改固定值
        --默认值为 600 (每个格子的间距)
        local normal_scale = normal_effect_radius
        local scale = 1
        if data.modify_value and data.modify_value ~= 0 then
            scale = (data.modify_value + normal_scale) / normal_scale            
        end
        self.effect_field_radius = normal_scale * scale
        self.super["field_1_img"].transform.localScale = Vector3.one * base_size * scale
    elseif data.modify_type == 2 then
        --修改百分比
        if data.modify_value then
            self.effect_field_radius = 600 * (1 + data.modify_value / 100)
            for i=1,4 do
                self.super["field_1_img"].transform.localScale = Vector3.one * base_size * (1 + data.modify_value / 100)
            end
        end
    elseif data.modify_type == 3 then
        --设置数值
        
    end
end

------------------------通用需要重写的几个方法


function C:SetFbxMaterial(material_name)
    if self.super.model then
        local material
        if material_name then
            material = GetMaterial("tank_" .. material_name)
        else
            material = GetMaterial("tank")
        end
        if material then
            if IsEquals (self.super.model:Find("tank/tank")) then
                if IsEquals(self.super.model:Find("tank/tank"):GetComponent("SkinnedMeshRenderer")) then
                    self.super.model:Find("tank/tank"):GetComponent("SkinnedMeshRenderer").material = material
                end
                if IsEquals(self.super.car_paotai_3d:Find("tank_body"):GetComponent("SkinnedMeshRenderer")) then
                    self.super.car_paotai_3d:Find("tank_body"):GetComponent("SkinnedMeshRenderer").material = material
                end
                if IsEquals(self.super.car_paotai_3d:Find("tank_weapon"):GetComponent("SkinnedMeshRenderer")) then
                    self.super.car_paotai_3d:Find("tank_weapon"):GetComponent("SkinnedMeshRenderer").material = material
                end
                self.current_material_name = material_name
            end
        else
            dump("坦克的材质球不存在:" .. (material_name or "nil"))
        end
    end
end

function C:GetCurrentFbxMaterial()
    return self.current_material_name
end

function C:SetHighLight(enabled,color)
    if self.super.model and self.super.model.transform:Find("tank") and self.super.model.transform:Find("tank"):GetComponent("Highlighter") then
        local component = self.super.model.transform:Find("tank"):GetComponent("Highlighter")
        component.enabled = enabled
        if color then
            component.tween.gradient.color = color
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
            self.super.model.transform.localPosition = Vector3.New(0.35,0,0)
            self.super.model.transform.localRotation = Quaternion:SetEuler(180,0,0)
            if cbk then cbk() end
        end)
    end
end