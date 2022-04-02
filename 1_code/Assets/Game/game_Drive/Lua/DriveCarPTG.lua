-- 创建时间:2021-02-24
-- 游戏电锯车车辆脚本
local basefunc = require "Game/Common/basefunc"
DriveCarPTG = basefunc.class()

local C = DriveCarPTG
C.name = "DriveCarPTG"

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
    self.listener["car_move_end"] = basefunc.handler(self,self.on_car_move_end)
    self.listener["car_move_slide"] = basefunc.handler(self,self.on_car_move_slide)
    self.listener["car_move_to_pos"] = basefunc.handler(self,self.on_car_move_to_pos)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
    self:RemoveListener()
    clear_table(self)
end

function C:ctor(super)
    self.super = super
    self.target_range = 6
    self.lock_show_range = true
    if not self.super.transform:GetComponent("CanvasGroup") then
        self.super.gameObject:AddComponent( typeof(UnityEngine.CanvasGroup))
    end
    self:MakeListener()
    self:AddListener()
end

--移动到指定位置的动画
function C:MoveToPosAnim(target_pos,obj_car_move,cbk,rewrite_move_call)
    local calculate_move_num = function(pos_1,pos_2)
        if not self.super.reverse_flag then
            local dis = (pos_1 - pos_2) % DriveMapManager.map_count
            if dis == 0 then dis = DriveMapManager.map_count end
            return dis 
        else
            local dis = (pos_1 - pos_2) % DriveMapManager.map_count
            if dis == 0 then return -DriveMapManager.map_count end
            return dis - DriveMapManager.map_count
        end
    end
    local default_move_config_id = 7
    local move_num
    if target_pos then
        move_num = calculate_move_num(target_pos , self.super.car_data.pos)
    end
    --伪造一份obj_car_move数据
    if obj_car_move then obj_car_move.move_nums = move_num end
    local obj_car_move = obj_car_move or {
        key = "obj_car_move",
        obj_car_move = {
            move_nums = move_num,
            pos = self.super.car_data.pos,
            random_stop_speed_num = 0,
            --移动的数据
            type_id = default_move_config_id,
            type = "ptg_crash"
        }
    }
    local pre_state
    local rewrite_move_call = rewrite_move_call or function(data)
        if pre_state ~= 5 and data.cur_state == 5 then
            --在这里直接停止移动
            if  self.super.move_timer then
                self.super.move_timer:Stop()
            end
            self.super.move_timer = nil
            if cbk then cbk() end
        end
        pre_state = data.cur_state
    end
    self.super:drive_car_move(obj_car_move,nil,rewrite_move_call)
end

--冲撞移动动画
function C:PlayCrash(target_pos,callback)
    self:MoveToPosAnim(target_pos,nil,callback)
end

--创建范围提示
function C:CreateEffectRange()
    if self.range_pres then
        self:CloseEffectRange()
    end
    for i = 1,self.target_range do
        self.range_pres = self.range_pres or {}
        if self.super.reverse_flag then
            self.range_pres[#self.range_pres+1] = self:CreateEffectRangeItem(self.super.car_data.pos - i,i == self.target_range)
        else
            self.range_pres[#self.range_pres+1] = self:CreateEffectRangeItem(self.super.car_data.pos + i,i == self.target_range)
        end
    end

end

function C:CloseEffectRange()
    if not self.range_pres then return end
    for k,v in ipairs(self.range_pres) do
        destroy(v.pre)
    end
    self.range_pres = nil
end

function C:CreateEffectRangeItem(pos,is_head)
    local road_id = DriveMapManager.ServerPosConversionMapPos(pos)
    local pre = newObject("PtgTargetSkill_1",GameObject.Find("Canvas/LayerLv1").transform)
    pre.transform.localPosition = DrivePanel.Instance().map_parent.transform.localPosition
    local node = pre.transform:Find("@tail_node/@tail_" .. road_id)
    node.gameObject:SetActive(true)
    local tbl = basefunc.GeneratingVar(node.transform)
    if is_head then
    end
    return {
        pre = pre,
        tbl = tbl,
        node = node
    }
end

--烧胎动画
function C:PlayBurnOut(callback_1,callback)
    
    local range_pres = {}
    local seq = DoTweenSequence.Create()
    local set_in_range = function(bool)
        for k,v in ipairs(range_pres) do
            if v.tbl then 
                v.tbl["show_tail"].gameObject:SetActive(not bool)
                v.tbl["in_range_tail"].gameObject:SetActive(bool)
            end
        end
    end
    seq:AppendInterval(1.5)
    seq:AppendCallback(function()
        if callback_1 then callback_1() end
        set_in_range(true)
    end)
    seq:AppendInterval(0.5)
    seq:AppendCallback(function()
        for k,v in ipairs(range_pres) do
            destroy(v.pre)
        end
    end)
    seq:AppendInterval(0.5)
    seq:AppendCallback(function()
        range_pres = nil
        if callback then callback() end
    end)
end

function C:CreateShaoTaiPre(only_anim)
    local seq = DoTweenSequence.Create()
    seq:Append(self.super.model.transform:DOLocalMove(Vector3.New(self.super.model.transform.localPosition.x - 0.4,0,0),0.7):SetEase(Enum.Ease.OutBounce))
    if not only_anim then
        self.shaotai_sound_key = AudioManager.PlaySound(audio_config.drive.com_main_map_shaotai.audio_name,-1)
        self.shaotai_pre = newObject("ZWC_shaotai",self.super.model.transform)
        -- self.shaotai_pre_2 = newObject("ptg_shaotai_2",self.super.model.transform)
    end
end

function C:CloseShaoTaiPre()
    self.super.model.transform.localPosition = Vector3.zero
    destroy(self.shaotai_pre)
    if self.shaotai_sound_key then
        AudioManager.CloseSound(self.shaotai_sound_key)
        self.shaotai_sound_key = nil
    end
    -- destroy(self.shaotai_pre_2)
end

--回弹动画
function C:PlayJumpBack(target_pos,callback)
    -- local jump_pre_2 = newObject("ptg_chuansong",DriveMapManager.GetGameMapByRoadID(DriveMapManager.ServerPosConversionRoadId(target_pos),true).transform)
    
    local seq = DoTweenSequence.Create()
    local fx_time = 1
    seq:AppendInterval(fx_time/2)
    seq:AppendCallback(function()
        if callback then callback() end
    end)
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        -- destroy(jump_pre_2)
        -- destroy(jump_pre_1)
    end)
end

function C:DestroyRangePres()
    if self.range_pres and next(self.range_pres) then
        for k,v in pairs(self.range_pres) do 
            if IsEquals(v.gameObject) then
                destroy(v.gameObject)
            end
        end
        self.range_pres = nil
    end
end

--流程控制 开始操作时直接显示范围不消失
function C:on_drive_game_process_data_msg_player_op(data)
	local player_op = DriveModel.data.players_info[self.super.car_data.seat_num].player_op
    if not player_op then
		return
	end
    
	if player_op.op_type == DriveModel.OPType.accelerator_all 
        or player_op.op_type == DriveModel.OPType.accelerator_big 
        or player_op.op_type == DriveModel.OPType.accelerator_small then
        self:DestroyRangePres()
        local range = self.attack_radius or 5
        local range_pres
        if self.super.reverse_flag then
            range_pres = DriveMapManager.ShowMapRangNode(DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos - range),DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos - 1))
        else
            range_pres = DriveMapManager.ShowMapRangNode(DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos + 1),DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos + range))
        end
        self.range_pres = range_pres
    else
    end
end

--流程控制 如果是小油门则一直显示范围 大油门先消失移动结束后显示范围
function C:on_drive_game_process_data_msg_player_action(data)
	local player_action = DriveModel.data.players_info[self.super.car_data.seat_num].player_action
    if self.op_seq then self.op_seq:Kill() end
	if player_action then
        if player_action.op_type == DriveModel.OPType.accelerator_small then
            self:DestroyRangePres()
        else
            local seq = DoTweenSequence.Create()
            local range = self.attack_radius or 5
            local range_pres
            if self.super.reverse_flag then
                range_pres = DriveMapManager.ShowMapRangNode(DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos - 1),DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos - range))
            else
                range_pres = DriveMapManager.ShowMapRangNode(DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos + 1),DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos + range))
            end
            seq:AppendInterval(1)
            seq:AppendCallback(function()
                self:DestroyRangePres()
                for k,v in pairs(range_pres) do 
                    if IsEquals(v.gameObject) then
                        destroy(v.gameObject)
                    end
                end
            end)
		end
	end
end
--流程控制 移动开始滑行时后 如果在射程范围内则显示范围并锁定 否则消失
function C:on_car_move_slide(data)
    if data.car_no == self.super.car_data.car_no then
        self.lock_show_range = false
    end
end


--流程控制 移动结束后 如果在射程范围内则显示范围并锁定 否则消失
function C:on_car_move_end(data)
    if data.car_no == self.super.car_data.car_no then
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(1)
        seq:AppendCallback(function()
            self.lock_show_range = true
            self:CloseEffectRange()
        end)
    end
end

function C:on_car_move_to_pos()
    if not self.lock_show_range then
    end
end

function C:SetAttackRadius(attack_radius)
    if attack_radius then
        self.attack_radius = attack_radius
        local player_op = DriveModel.data.players_info[self.super.car_data.seat_num].player_op
        if not player_op then
            return
        end
        
        if player_op.op_type == DriveModel.OPType.accelerator_all 
            or player_op.op_type == DriveModel.OPType.accelerator_big 
            or player_op.op_type == DriveModel.OPType.accelerator_small then
            self:DestroyRangePres()
            local range = self.attack_radius
            local range_pres
            if self.super.reverse_flag then
                range_pres = DriveMapManager.ShowMapRangNode(DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos - range),DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos - 1))
            else
                range_pres = DriveMapManager.ShowMapRangNode(DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos + 1),DriveMapManager.ServerPosConversionMapPos(self.super.car_data.pos + range))
            end
            self.range_pres = range_pres
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