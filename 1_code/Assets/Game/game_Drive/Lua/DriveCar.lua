-- 游戏车辆类
local basefunc = require "Game/Common/basefunc"
DriveCar = basefunc.class()

local M = DriveCar
M.name = "DriveCar"

function M.Create(car_data)
    return M.New(car_data)
end

function M:MyExit()
    self:RemoveListener()
    if self.move_timer then
        self.move_timer:Stop()
    end
    self.move_timer = nil
    destroy(self.gameObject)
    if self[self.config.car_type] then
        self[self.config.car_type]:MyExit()
    end
    if IsEquals(self.get_props) then
        destroy(self.get_props)
    end
    clear_table(self)
end

function M:ctor(car_data)
    self.car_data = car_data
    dump(self.car_data,"<color=yellow>车的数据</color>")
    if self.car_data.id then
        local a,b = GameModuleManager.RunFun({_goto = "sys_car_manager",car_type_id = self.car_data.id},"GetCarCfg")
        self.config = b
    end
    dump(self.config,"<color=yellow>车的配置</color>")
	local parent = DriveMapManager.car_node.transform
    local star = self.car_data.star
    star = star and star + 1 or 0
	self.gameObject = newObject(self.config.car_name .. "_" .. star, parent)
	self.transform = self.gameObject.transform
    basefunc.GeneratingVar(self.transform,self)
    -- self.animation_curve_tutor = self.transform:GetComponent("AnimationCurveTutor")
    -- self.use_ac_index = self.animation_curve_tutor.useIndex
    -- self.animation_curves = self.animation_curve_tutor.AnimationCurves
    -- dump(self.use_ac_index,"<color=yellow>当前选择的曲线</color>")

    self.cur_xianduan = 1
    -- self.car_canvas = self.car.transform:GetComponent("Canvas")
    self.cs = self.gameObject:GetComponentsInChildren(typeof(UnityEngine.Canvas), true)

    --如果车辆存在动画则将动画脚本挂上
    if self.config and self.config.car_type and _G[self.config.car_type] then
        self[self.config.car_type] = _G[self.config.car_type].Create(self)
    end
    --是否反转方向
    self.reverse_flag = false
    self:MakeListener()
	self:AddListener()
    self:InitUI()
    self:Refresh()
end

function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:MakeListener()
	self.listener = {}
    self.listener["player_info_item_hp_zero"] = basefunc.handler(self,self.on_show_hp_zero)
    self.listener["player_info_item_hd_zero"] = basefunc.handler(self,self.on_show_hd_zero)
	self.listener["drive_game_process_data_msg_begin"] = basefunc.handler(self,self.on_drive_game_process_data_msg_begin)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:InitUI()
    
end

function M:Refresh(car_data)
    if car_data and self.car_data.id ~= car_data.id then
        --不是同一辆车了，重新创建
        self:MyExit()
        self:ctor(car_data)
        return
    end
    self.car_data = car_data or self.car_data

    self:RefreshTransform()
    self:RefreshShield()
    self:RefreshDamageFrog()
end

function M:RefreshData(data)
    self.car_data = data
end

-- 设置层级
function M:SetLayer(order)
	-- local cha = order - self.car_canvas.sortingOrder
	-- for i = 0, self.cs.Length - 1 do
	-- 	self.cs[i].sortingOrder = self.cs[i].sortingOrder + cha
	-- end
end

function M:RefreshTransform()
    local map_vec = DriveMapManager.ServerPosConversionMapVector(self.car_data.pos)
    dump(map_vec,"<color=white>当前车的坐标</color>")
    self.transform.position = map_vec
    local euler_z = DriveMapManager.CarMapEulerZ(self.transform.position)
    -- dump(euler_z,"<color=white>euler_z当前角度</color>")
    if self.reverse_flag then
        self.car.localRotation = Quaternion:SetEuler(0,0,euler_z + 180)
    else
        self.car.localRotation = Quaternion:SetEuler(0,0,euler_z)
    end
    self.car.transform.localPosition = Vector3.zero
end

function M:GetCarRotation()

    local euler_z = DriveMapManager.CarMapEulerZ(self.transform.position)
    -- dump(euler_z,"<color=white>euler_z当前角度</color>")
    if self.reverse_flag then
        return Vector3.New(0,0,euler_z + 180)
    else
        return Vector3.New(0,0,euler_z)
    end
end

function M:get_drive_car_move_data(data)
    local obj_car_move = data.obj_car_move
    local move_cfg = self.config.move_config[obj_car_move.type]
    if obj_car_move.type_id then
        move_cfg = SysCarManager.GetMoveCfg(obj_car_move.type_id)
    end
    local up_a = move_cfg.up_a or 0
    local down_a = move_cfg.down_a or 0
    local max_v = move_cfg.max_v or 0
    local min_v = move_cfg.min_v or 0
    local random_min = move_cfg.random_min or 5
    local random_max = move_cfg.random_max or 8

    if move_cfg.max_move_num and move_cfg.max_move_num < obj_car_move.move_nums then
        local n = obj_car_move.move_nums / move_cfg.max_move_num
        up_a = up_a * n
        max_v = max_v * n
    end

    local cur_v = 0 --当前速度

    if obj_car_move.type == "big_youmen" then
    elseif obj_car_move.type == "small_youmen" then
        --小油门匀速滑动
        cur_v = move_cfg.min_v
    elseif obj_car_move.type == "sprint" then
    elseif obj_car_move.type == "ptg_crash" then
        cur_v = move_cfg.min_v
    else
        cur_v = move_cfg.min_v
    end

    if not data.obj_car_move.random_stop_speed_num then
        math.randomseed(data.process_no)
        data.obj_car_move.random_stop_speed_num = math.random(random_min,random_max)
        if data.obj_car_move.random_stop_speed_num > math.abs(obj_car_move.move_nums) then
            data.obj_car_move.random_stop_speed_num = math.abs(obj_car_move.move_nums)
        end
    end
    local symbol = data.obj_car_move.move_nums / math.abs(data.obj_car_move.move_nums)
    local stop_speed_num = data.obj_car_move.random_stop_speed_num --最后匀速运动的格子数
    local move_all_len = get_move_all_len(obj_car_move.pos,obj_car_move.move_nums) --移动的总长度
    local move_stop_speed_len = get_move_all_len(obj_car_move.pos + obj_car_move.move_nums - stop_speed_num * symbol,stop_speed_num * symbol)
    local move_stop_speed_t = move_stop_speed_len / min_v
    local move_up_speed_len,move_uniform_speed_len,move_down_speed_len,move_up_speed_t,move_uniform_speed_t,move_down_speed_t = get_moveDis_in_speedType(move_all_len - move_stop_speed_len,cur_v,up_a,down_a,max_v,min_v)
    local move_all_t = move_up_speed_t + move_uniform_speed_t + move_down_speed_t + move_stop_speed_t

    local car_move_data = {}
    car_move_data.up_a = up_a
    car_move_data.down_a = down_a
    car_move_data.max_v = max_v
    car_move_data.min_v = min_v
    car_move_data.cur_v = cur_v
    car_move_data.stop_speed_num = stop_speed_num

    car_move_data.len = {
        all_val = move_all_len,
        up_val = move_up_speed_len,
        uniform_val = move_uniform_speed_len,
        down_val = move_down_speed_len,
        stop_val = move_stop_speed_len,
        func = get_useTime_by_moveDis
    }

    car_move_data.t = {
        all_val = move_all_t,
        up_val = move_up_speed_t,
        uniform_val = move_uniform_speed_t,
        down_val = move_down_speed_t,
        stop_val = move_stop_speed_t,
        func = get_moveDis_by_useTime
    }
    -- dump(car_move_data,"<color=yellow>移动数据 car_move_data</color>")
    return car_move_data
end

function M:get_drive_car_move_point_time(data)
    -- dump(data,"<color=yellow>移动数据obj_car_move</color>")
    local obj_car_move = data.obj_car_move
    local car_move_data = self:get_drive_car_move_data(data)
    local cur_v = car_move_data.cur_v
    local car_move_type_data = car_move_data.len

    local cur_move_len = 0
    local cur_move_t = 0
    local delta_len = 0
    local delta_t = 0
    local cur_state = 1 --1:加速状态，2：匀速状态，3：减速状态，4：匀速停止状态

    local time_point = {}
    local f = obj_car_move.move_nums / math.abs(obj_car_move.move_nums)
    for i=1,math.abs(obj_car_move.move_nums + f),1 do
        time_point[i] = {}
        time_point[i].pos = obj_car_move.pos + i * f - 1 * f
        time_point[i].car_id = self.car_data.car_id
        time_point[i].car_no = self.car_data.car_no
        time_point[i].seat_num = self.car_data.seat_num
    end

    time_point[1].time = 0
    for i=2,#time_point do
        delta_t = 0
        delta_len = get_move_all_len(time_point[i - 1].pos,f)
        cur_move_len = cur_move_len + delta_len
        if cur_move_len > car_move_type_data.all_val then
            cur_move_len = car_move_type_data.all_val
        end

        cur_state,cur_v,delta_t = compute_state_data_by_time_or_dis(cur_state,cur_v,delta_len,cur_move_len,car_move_type_data.up_val,car_move_type_data.uniform_val,car_move_type_data.down_val,car_move_type_data.stop_val,car_move_type_data.all_val,car_move_type_data.func,car_move_data.up_a,car_move_data.down_a,car_move_data.max_v,car_move_data.min_v)
        cur_move_t = cur_move_t + delta_t
        time_point[i].time = cur_move_t
        if cur_state == 5 then
            break
        end
    end
    dump({delta_len = delta_len,delta_t = delta_t,cur_move_t = cur_move_t,cur_move_len = cur_move_len,cur_v = cur_v ,cur_state = cur_state,car_no = self.car_data.car_no ,car_move_data = car_move_data},
    "<color=white>移动时间计算参数和结果</color>")
    dump(time_point,"<color=yellow>运动到开奖位置时间点？？？？？</color>")
    return time_point
end

--[[
    "obj_car_move" = {
-             "car_no"    = 2
-             "move_nums" = 40
-             "pos"       = 14
-             "type"      = "big_youmen"
-         }
func_call = {
    begin_call,--开始运动
    update_call,--运动中
    end_call,--运动结束

    up_sp_call,--开始加速
    uniform_sp_call,--开始匀速
    down_sp_call,--开始减速
    stop_sp_call,--开始滑行
}
rewrite_move_call = function(data)
end
]]
function M:drive_car_move(data,func_call,rewrite_move_call,block_play_process)
    self.transform:SetSiblingIndex(1)
    -- self.car_canvas.enabled = false
    -- self.car_canvas.enabled = true
    dump(data,"<color=yellow>移动数据obj_car_move</color>")
    local obj_car_move = data.obj_car_move
    self.obj_car_move = obj_car_move
    local car_move_data = self:get_drive_car_move_data(data)
    local cur_v = car_move_data.cur_v
    local car_move_type_data = car_move_data.t

    local cur_move_len = 0
    local cur_move_t = 0
    local delta_len = 0
    local delta_t = 1 / 50
    local cur_state = 1 --1:加速状态，2：匀速状态，3：减速状态，4：匀速停止状态
    local pre_state = 0 --上一个状态

    self.car_data.start_pos = self.car_data.pos
    self.car_data.end_pos = self.car_data.start_pos + self.obj_car_move.move_nums
    local shun_or_ni = obj_car_move.move_nums > 0

    if self.move_timer then
        self.move_timer:Stop()
    end
    self.move_timer = nil

    --经过格子
    self.cur_xianduan = get_curMapXianduanIdx(get_curMapIdx_by_point(self.transform.position))
    self.cur_main_point = get_curMainMapPoint_by_point(self.transform.position)

    --精度修复
    local target_pos = self.car_data.pos + obj_car_move.move_nums
    local target_position = DriveMapManager.ServerPosConversionMapVector(target_pos)
    local euler_z = DriveMapManager.CarMapEulerZ(target_position)
    local target_rotation = Quaternion:SetEuler(0,0,euler_z)

    --根据速度显示残影
    local ghost_shadow_effect = self.gameObject:GetComponent("GhostShadowEffect")
    local ghost_effect_2d = self.gameObject:GetComponent("GhostEffect2D")
    local function effect_ghost_effect_by_speen(sp)
        if obj_car_move.type == "small_youmen" then
            --小油门没有残影
            return
        end
        local fx_type = self:GetMoveFxTypeByMoveNum(obj_car_move.move_nums)
        if fx_type <= 1 then
            --二级以上特效才有残影
            return
        end
        local spawn_timeval = 0.05
        local show_or_hide = false
        if sp < 10 then
            show_or_hide = false
        else
            show_or_hide = true
            spawn_timeval = 1 / sp
        end

        local fx_type_interval_factor_cfg = {
            [2] = 0.5,
            [3] = 4,
        }
        local timeval_factor = fx_type_interval_factor_cfg[fx_type] or 1

        local effect__data = {
            ghost_shadow_effect = ghost_shadow_effect,
            ghost_effect_2d = ghost_effect_2d,
            interval = spawn_timeval * 2 / timeval_factor,
            show_or_hide = show_or_hide
        }
        DriveEffectManager.GhostEffectChange(effect__data)
    end 

    --根据状态显示残影
    local function effect_ghost_effect_by_state(state)
        if true then return end
        if obj_car_move.type == "small_youmen" then
            --小油门没有残影
            return
        end
        local spawn_timeval = 0.05
        local show_or_hide = false
        if cur_state == 1 then
            print("<color=white>开始加速</color>")
            spawn_timeval = 0.05
            show_or_hide = false
        elseif cur_state == 2 then
            print("<color=white>开始匀速</color>")
            spawn_timeval = 0.02
            show_or_hide = true
        elseif cur_state == 3 then
            print("<color=white>开始减速</color>")
            spawn_timeval = 0.02
            show_or_hide = true
        elseif cur_state == 4 then
            print("<color=white>开始滑行</color>")
            spawn_timeval = 0.05
            show_or_hide = false
        else
            spawn_timeval = 0.05
            show_or_hide = false
        end
        local effect__data = {
            gameobject = self.gameObject,
            spawn_timeval = spawn_timeval,
            show_or_hide = show_or_hide
        }
        DriveEffectManager.GhostEffect(effect__data)
    end

    -- car_move_data.target = {
    --     target_pos = target_pos,
    --     target_position = target_position,
    --     target_rotation = target_rotation,
    -- }
    local function move_call()
        if pre_state == 5 then
            return
        end

        if pre_state == 0 then
            print("<color=white>开始移动</color>")
            Event.Brocast("car_move_to_pos",{car_data = self.car_data,obj_car_move = self.obj_car_move,pos = self.car_data.pos,car_id = self.car_data.car_id,car_no = self.car_data.car_no,seat_num = self.car_data.seat_num,start_pos = self.car_data.start_pos,block_play_process = block_play_process})
            if func_call and func_call.begin_call then
                func_call.begin_call()
            end
            --添加移动拖尾
            if obj_car_move.type == "big_youmen" then
                local fx_type = self:GetMoveFxTypeByMoveNum(obj_car_move.move_nums)
                if not self.youmen_tail_fx then
                    local big_youmen_tail_config = {
                        [2] = "dayoumen_lv2",
                        [3] = "dayoumen_lv3"    
                    }
                    local tail_pre = GetPrefab(big_youmen_tail_config[fx_type])
                    if tail_pre then
                        self.youmen_tail_fx = newObject(big_youmen_tail_config[fx_type],self.tail_node)
                    end
                end
            end
            effect_ghost_effect_by_state(cur_state)
        end

        local cur_main_point,offset_dis = get_curMainMapPoint_by_point(self.transform.position,self.cur_main_point,cur_state)
        if cur_main_point.type == "main" and cur_main_point.pos ~= self.cur_main_point.pos then
            --改变了pos
            self.cur_main_point = cur_main_point
            --移动超过一个？？？认为一帧不可能移动超过一圈
            local c1 = (self.cur_main_point.pos - DriveMapManager.first_id + 1 + DriveMapManager.map_count) % DriveMapManager.map_count 
            local c2 = self.car_data.pos % DriveMapManager.map_count
            
            --倒车和一般逻辑不一样s
            if shun_or_ni then
                if c1 < c2 then 
                    c1 = c1 + DriveMapManager.map_count
                end
                local c = c1 - c2
                c = math.abs(c)
                -- dump(c,"<color=yellow>移动了的格子数？？？</color>")
                for i=1,c,1 do
                    self.car_data.pos = self.car_data.pos + 1
                    -- dump({pos = self.car_data.pos,car_id = self.car_data.car_id,car_no = self.car_data.car_no,seat_num = self.car_data.seat_num},"<color=white>pos改变</color>")
                    -- dump({cur_state = cur_state, i = i, car_data = self.car_data,obj_car_move = self.obj_car_move,pos = self.car_data.pos,car_id = self.car_data.car_id,car_no = self.car_data.car_no,seat_num = self.car_data.seat_num},"<color=white>移动到位置上????????????????????????????</color>")
                    Event.Brocast("car_move_to_pos",{car_data = self.car_data,obj_car_move = self.obj_car_move,pos = self.car_data.pos,car_id = self.car_data.car_id,car_no = self.car_data.car_no,seat_num = self.car_data.seat_num,start_pos = self.car_data.start_pos,block_play_process = block_play_process})
                    if self.car_data.pos and self.car_data.pos % DriveMapManager.map_count == 1 then
                        Event.Brocast("car_move_to_start_pos",{car_data = self.car_data,obj_car_move = self.obj_car_move, pos = self.car_data.pos,car_id = self.car_data.car_id,car_no = self.car_data.car_no,seat_num = self.car_data.seat_num,shun_or_ni = shun_or_ni})
                    end
                end
            else
                if c1 > c2 then
                    c1 = c1 - DriveMapManager.map_count
                end
                local c = c2 - c1
                -- dump(c,"<color=yellow>移动了的格子数？？？</color>")
                for i=1,c,1 do
                    self.car_data.pos = self.car_data.pos - 1
                    -- dump({pos = self.car_data.pos,car_id = self.car_data.car_id,car_no = self.car_data.car_no,seat_num = self.car_data.seat_num},"<color=white>pos改变</color>")
                    -- dump({cur_state = cur_state, i = i,car_data = self.car_data,obj_car_move = self.obj_car_move,pos = self.car_data.pos,car_id = self.car_data.car_id,car_no = self.car_data.car_no,seat_num = self.car_data.seat_num},"<color=white>移动到位置上?????????????????????????????</color>")
                    Event.Brocast("car_move_to_pos",{car_data = self.car_data,obj_car_move = self.obj_car_move,pos = self.car_data.pos,car_id = self.car_data.car_id,car_no = self.car_data.car_no,seat_num = self.car_data.seat_num,block_play_process = block_play_process})
                    if self.car_data.pos and self.car_data.pos % DriveMapManager.map_count == 1 then
                        Event.Brocast("car_move_to_start_pos",{car_data = self.car_data,obj_car_move = self.obj_car_move,pos = self.car_data.pos,car_id = self.car_data.car_id,car_no = self.car_data.car_no,seat_num = self.car_data.seat_num,shun_or_ni = shun_or_ni})
                    end
                end
            end
        end

        if func_call and func_call.update_call then
            func_call.update_call()
        end

        if pre_state ~= cur_state then
            if cur_state == 1 then
                print("<color=white>开始加速</color>")
                if func_call and func_call.up_sp_call then
                    func_call.up_sp_call()
                end
                effect_ghost_effect_by_state(cur_state)
            elseif cur_state == 2 then
                print("<color=white>开始匀速</color>")
                if func_call and func_call.uniform_sp_call then
                    func_call.uniform_sp_call()
                end
                effect_ghost_effect_by_state(cur_state)
            elseif cur_state == 3 then
                print("<color=white>开始减速</color>")
                if func_call and func_call.down_sp_call then
                    func_call.down_sp_call()
                end
                effect_ghost_effect_by_state(cur_state)
            elseif cur_state == 4 then
                print("<color=white>开始滑行</color>")
                if self.youmen_tail_fx then
                    destroy(self.youmen_tail_fx)
                    self.youmen_tail_fx = nil
                end
                Event.Brocast("car_move_slide",{car_no = self.car_data.car_no,obj_car_move= obj_car_move})
                if func_call and func_call.stop_call then
                    func_call.stop_call()
                end
                effect_ghost_effect_by_state(cur_state)
            end
        end

        if cur_state == 5 then
            dump({delta_len = delta_len,delta_t = delta_t,cur_move_t = cur_move_t,cur_move_len = cur_move_len,cur_v = cur_v ,cur_state = cur_state,car_no = self.car_data.car_no ,car_move_data = car_move_data},
            "<color=white>移动完成参数和结果</color>")
            dump(func_call, "<color=white>移动结束</color>")
            if self.youmen_tail_fx then
                destroy(self.youmen_tail_fx)
                self.youmen_tail_fx = nil
            end
            if func_call and func_call.end_call then
                func_call.end_call()
                func_call.end_call = nil
            end
            --#移动结束广播
            Event.Brocast("car_move_end",{car_data = self.car_data,car_no = self.car_data.car_no,obj_car_move= obj_car_move})
            -- self:SetLayer(1)
            effect_ghost_effect_by_state(cur_state)
        end

        pre_state = cur_state
    end

    local function move_update()
        effect_ghost_effect_by_speen(self.car_data.move_speed)
        if cur_state == 5 then
            return
        end

        local location,xianduan,angle = get_location(shun_or_ni,self.transform.position,self.cur_xianduan,delta_len)
        -- dump({[1] = {cur_move_t = cur_move_t,cur_v = cur_v ,cur_state = cur_state,cur_move_len = cur_move_len,car_no = self.car_data.car_no ,move_all_len = move_all_len, cur_state = cur_state,cur_move_len = cur_move_len,move_up_speed_len = move_up_speed_len,move_uniform_speed_len = move_uniform_speed_len,move_down_speed_len = move_down_speed_len,move_stop_speed_len= move_stop_speed_len},
        -- [2] ={cur_location = self.transform.position,cur_xianduan = self.cur_xianduan,len = delta_len,location = location,xianduan = xianduan,angle = angle}},
        -- "<color=white>移动计算参数和结果</color>")

        self.cur_xianduan = xianduan
        self.transform.position = Vector3.New(location.x,location.y,self.transform.position.z)
        self.car.localRotation = Quaternion:SetEuler(0,0,angle)

        -- self.angular_velocity = cur_v / 2
        -- if angle % 90 == 0 then
        --     -- dump({angle = angle,cur_angle = self.angle},"<color=white>转向角0 angle</color>")
        --     self.angle = angle
        --     self.car.localRotation = Quaternion:SetEuler(0,0,self.angle)
        -- elseif not self.angle then
        --     self.angle = angle
        --     -- dump({angle = angle},"<color=white>转向角1 angle</color>")
        --     self.car.localRotation = Quaternion:SetEuler(0,0,self.angle)
        -- else
        --     local delta_angle = self.angular_velocity * delta_t * 70
        --     local tar_angle 
        --     if shun_or_ni then
        --         tar_angle = self.angle + delta_angle
        --         if tar_angle > angle then
        --             tar_angle = angle
        --         end
        --     else
        --         tar_angle = self.angle - delta_angle
        --         if tar_angle < angle then
        --             tar_angle = angle
        --         end
        --     end
        --     self.angle = tar_angle
        --     -- dump({angle = angle,tar_angle = tar_angle,delta_angle = delta_angle},"<color=white>转向角2 angle</color>")
        --     self.car.localRotation = Quaternion:SetEuler(0,0,self.angle)
        -- end
    end

    local cur_dis_offset
    local pre_dis_offset
    local function correct()
        --差距过大,这里重新纠正
        if cur_state == 5 then
            local cur_dis_offset = Vec2DLength(Vec2DSub(self.transform.position, target_position))
            if not pre_dis_offset then
                pre_dis_offset = cur_dis_offset
            end

            if cur_dis_offset >= 0.001 and pre_dis_offset >= cur_dis_offset then
                cur_state = 4
            end
            pre_dis_offset = cur_dis_offset
        end
    end


    local function move()
        if not self.car_data then return end
        delta_len = 0
        cur_move_t = cur_move_t + delta_t
         --差距过大,这里重新纠正
        if cur_move_t >= car_move_type_data.all_val then
            cur_move_t = car_move_type_data.all_val
        end
        cur_state,cur_v,delta_len = compute_state_data_by_time_or_dis(cur_state,cur_v,delta_t,cur_move_t,car_move_type_data.up_val,car_move_type_data.uniform_val,car_move_type_data.down_val,car_move_type_data.stop_val,car_move_type_data.all_val,car_move_type_data.func,car_move_data.up_a,car_move_data.down_a,car_move_data.max_v,car_move_data.min_v)
        cur_move_len = cur_move_len + delta_len
        self.car_data.move_speed = cur_v
        correct()
        move_update()
        --运动回调执行
        if rewrite_move_call then
            rewrite_move_call({cur_state = cur_state})
        else
            move_call()
        end 
        if cur_state == 5 then
            if self.move_timer then
                self.move_timer:Stop()
            end
        end
    end

    self.move_timer = FixedTimer.New(
        function(  )
            move()
        end,delta_t,-1
    )
    self.move_timer:SetStopCallBack(function()
        if func_call and func_call.end_call then
            func_call.end_call()
            func_call.end_call = nil
        end
    end)
    self.move_timer:Start()
end

function M:drive_car_stop(end_pos)
    -- self.car_data.pos = end_pos
    self.car_data.end_pos = end_pos
    if self.move_timer then
        self.move_timer:Stop()
    end
    self.move_timer = nil
    if self.youmen_tail_fx then
        destroy(self.youmen_tail_fx)
        self.youmen_tail_fx = nil
    end
    --刷新到当前位置
    local map_vec = DriveMapManager.ServerPosConversionMapVector(end_pos)
    self.transform.position = map_vec
    local euler_z = DriveMapManager.CarMapEulerZ(self.transform.localPosition)
    self.car.localRotation = Quaternion:SetEuler(0,0,euler_z)
    -- self:SetLayer(1)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        Event.Brocast("car_move_to_pos",{car_data = self.car_data,obj_car_move = self.obj_car_move,pos = self.car_data.pos,car_id = self.car_data.car_id,car_no = self.car_data.car_no,seat_num = self.car_data.seat_num})
        Event.Brocast("car_move_end",{car_data = self.car_data,car_no = self.car_data.car_no,obj_car_move= self.obj_car_move})
    end)
    return true
end

---获取车辆的中心位置
function M:GetCenterLocalPosition()
    local ret = Vector3.New(self.transform.localPosition.x,self.transform.localPosition.y,self.transform.localPosition.z)
    return ret
end

---获取车辆的中心位置
function M:GetCenterPosition()
    local ret = Vector3.New(self.transform.position.x,self.transform.position.y,self.transform.position.z)
    return ret
end

---获取车辆在UI上的位置
function M:GetUICenterPosition()
    return DriveModel.Get3DTo2DPoint(self:GetCenterPosition())
end

function M:GetCarData()
    return self.car_data
end

--受击动画
function M:PlayOnAttack(damage_count)
    if damage_count ~= 0 or not damage_count then
        if damage_count then
            self.car_data.hp = self.car_data.hp - damage_count
            self:RefreshDamageFrog()
        end
        local seq = DoTweenSequence.Create()
        seq:Append(self.car.transform:DOShakePosition(0.6,Vector3.New(0.2,0.2,0)))
        seq:OnForceKill(function()
            self.car.transform.localPosition = Vector3.zero
        end)
    end
end

--震动动画
function M:PlayShakeMove(vec,damage_count,back)
    if damage_count ~= 0 or not damage_count then
        if damage_count then
            self.car_data.hp = self.car_data.hp - damage_count
            self:RefreshDamageFrog()
        end
        local seq = DoTweenSequence.Create()
        local target_vec = Vector3.New(self.car.transform.position.x + vec.x,self.car.transform.position.y + vec.y ,self.car.transform.position.z + (vec.z or 0))
        seq:Append(self.car.transform:DOMove(target_vec,0.1):SetEase(Enum.Ease.OutBounce))
        seq:OnForceKill(function()
            self.car.transform.localPosition = Vector3.zero
        end)
    end
end

--直接设置位置（传送技能）
function M:TransferPosition(position)
    if position then
        self.car_data.pos = position
        self:RefreshTransform()
    end
end

function M:PlayDead(cbk)
    if self.dead_seq then return end
    local obj = newObject("cheliangsunhui",GameObject.Find("3DNode").transform)
    obj.transform.position = self.car.transform.position
    obj.transform.rotation = self.car.transform.rotation
    local obj_2 = newObject("tongyong_baozha",self.car.transform)
    obj_2.gameObject:SetActive(false)
    self.dead_seq = DoTweenSequence.Create()
    AudioManager.PlaySound(audio_config.drive.com_main_map_chehuibaozha.audio_name)
    self.dead_seq:Append(self.car.transform:DOShakePosition(4,Vector3.New(0.2,0.2,0)))
    self.dead_seq:AppendCallback(function()
        destroy(obj)
        obj_2.gameObject:SetActive(true)
        DriveAnimManager.PlayShakeScreen(DriveModel.camera3dParent,1)
    end)
    self.dead_seq:AppendInterval(2)
    self.dead_seq:AppendCallback(function()
        if self.model then
            self.model.transform.localPosition = Vector3.zero
        end
        --#临时代码 判断一下游戏是否结束
        if DriveModel.data.settlement_info and DriveModel.data.settlement_info.win_reason == 1 then
            DriveClearingPanel.Create(DriveModel.data.settlement_info)
            DriveModel.data.settlement_info = nil
        end
        if cbk then cbk() end
    end)
    self.dead_seq:AppendInterval(5)
    self.dead_seq:OnForceKill(function()
        destroy(obj_2)
    end)
end

function M:on_show_hp_zero(data)
    if data.car_no == self.car_data.car_no then
        self:PlayDead()
    end
end

function M:on_show_hd_zero(data)
    if data.car_no ~= self.car_data.car_no then return end
    if self.shield and IsEquals(self.shield) then
        destroy(self.shield)
    end
end

--设置护盾相关
function M:RefreshShield()
    if self.car_data.hd > 0 then
        if not self.shield or not IsEquals(self.shield) then
            self.shield = newObject("buff_hudun",self.car.transform)
            local cx = self.shield.transform:Find("buff_hudun/chuxian")
            if IsEquals(cx) then
                cx.gameObject:SetActive(false)
            end
        end
    else
        if self.shield and IsEquals(self.shield) then
            destroy(self.shield)
        end
    end
end

--设置受伤烟雾
function M:RefreshDamageFrog()
    local frog_limit_cfg = {
        [1] = 0.5,
        [2] = 0.2
    }
    if self.car_data.hp and self.car_data.hp_max then
        local cur_value = self.car_data.hp / self.car_data.hp_max
        if self.damage_frog then
            destroy(self.damage_frog.gameObject)
            self.damage_frog = nil
        end
        for i = #frog_limit_cfg, 1,-1 do 
            if cur_value < frog_limit_cfg[i] then
                self.damage_frog = newObject("maoyan",self.car.transform)
                self.damage_frog.transform:Find(i .. "").gameObject:SetActive(true)
                break
            end
        end
    end
end

function M:ActiveAccTail(acc_type,move_num,b)
    if acc_type == "small_youmen" then
        if not self.small_tail or not IsEquals(self.small_tail) then
            self.small_tail = newObject("xiaoyoumen_weiqi",self.tail_node)
        end
        self.small_tail.gameObject:SetActive(false)
        self.small_tail.gameObject:SetActive(b)
    elseif acc_type == "big_youmen" then
        local fx_type = self:GetMoveFxTypeByMoveNum(move_num)
        if fx_type >= 1 then
            if not self.big_tail or not IsEquals(self.big_tail) then
                self.big_tail = newObject("dayoumen_weiqi",self.tail_node)
            end
            self.big_tail.gameObject:SetActive(false)
            self.big_tail.gameObject:SetActive(b)
        end
    end
end

function M:GetMoveFxTypeByMoveNum(move_num)
    local ret = 1
    local move_num = math.abs(move_num)
    if self.config.move_config["big_youmen"] and self.config.move_config["big_youmen"].fx_type_config then
        local fx_type_config = self.config.move_config["big_youmen"].fx_type_config
        for k,v in ipairs(fx_type_config) do
            if move_num < v then
                ret = k
                break
            end
            if k == #fx_type_config and move_num >= v then
                ret = #fx_type_config + 1
            end
        end
    end
    return ret
end

function M:on_drive_game_process_data_msg_begin(  )
	self.virtual_circle_start = DriveCarManager.GetVirtualCircle({is_start = true,seat_num = self.seat_num})
	self.virtual_circle_end = DriveCarManager.GetVirtualCircle({seat_num = self.seat_num})
	self.virtual_circle_offset = 0
end

--设置回合提示箭头
function M:AddRoundArrow(show_arrow)
    self:CloseRoundArrow()
    self.round_arrow_fx = newObject("cheliang_huihetishi",self.fx_node.transform)
    if not show_arrow then
        self.round_arrow_fx.transform:Find("jiantou").gameObject:SetActive(false)
    end
end

--移除回合提示箭头
function M:CloseRoundArrow()
    if IsEquals(self.round_arrow_fx) then
        destroy(self.round_arrow_fx)
        self.round_arrow_fx = nil
    end
end

function M:ShowOrHideSelectRoad(data,view)
    local b = false
    if data then
     b = self.car_data.seat_num == data[data.key].seat_num
    end
    if view ~= nil then
        b = view
    end
    if not b then
        if IsEquals(self.get_props) then
            self.get_props.gameObject:SetActive(b)
        end
        return
    end

    local pos = self.car.transform.position
    if not IsEquals(self.get_props) then
        self.get_props = newObject("get_props",GameObject.Find("Canvas/LayerLv3").transform)
        self.get_props_icon_img = self.get_props.transform:Find("fx/@icon_img"):GetComponent("Image")
        self.get_props_name_txt = self.get_props.transform:Find("fx/@name_txt"):GetComponent("Text")
        local _img = self.get_props.transform:Find("fx/@bg_img"):GetComponent("Image")
        _img.sprite = GetTexture(DriveMapManager.GetMapAssets("zs_img_zzsy_bg"))
        _img = self.get_props.transform:Find("fx/@title_img"):GetComponent("Image")
        _img.sprite = GetTexture(DriveMapManager.GetMapAssets("zs_img_zzsy"))
        _img:SetNativeSize()
        _img = nil
    end
    self.get_props.transform.position = DriveModel.Get3DTo2DPoint({x = pos.x,y = pos.y + 0.8,z = pos.z})

    local skill_pd = DriveLogicProcess.get_no_process({process_no = data.father_process_no})
    local skill_cfg
    if skill_pd then
        skill_cfg = SkillManager.GetSkillCfgById(skill_pd[skill_pd.key].skill_id)
    end
    local skill_create_pd = DriveLogicProcess.get_no_process({process_no = skill_pd.father_process_no})
    local tool_cfg
    local tool_pd
    if skill_create_pd and skill_create_pd.skill_create and skill_create_pd.father_process_no then
        tool_pd = DriveLogicProcess.get_no_process({process_no = skill_create_pd.father_process_no})
        if tool_pd and tool_pd.tool_use then
            tool_cfg = ToolsManager.GetToolsCfgById(tool_pd[tool_pd.key].id)
        end
    end

    local icon
    local name
    if tool_cfg then
        icon = tool_cfg.icon
        name = tool_cfg.name
    elseif skill_cfg then
        if skill_cfg.icon then
            icon = skill_cfg.icon
        elseif skill_cfg.skill_buff_icon then
            icon = skill_cfg.skill_buff_icon
        end
        name = skill_cfg.name
    end

    if not IsEquals(self.get_props_icon_img) then
        self.get_props_icon_img = self.get_props.transform:Find("fx/@icon_img"):GetComponent("Image")
    end
    self.get_props_icon_img.sprite = GetTexture(DriveMapManager.GetMapAssets(icon))
    if not IsEquals(self.get_props_name_txt) then
        self.get_props_name_txt = self.get_props.transform:Find("fx/@name_txt"):GetComponent("Text")
    end
    self.get_props_name_txt.text = name

    self.get_props.gameObject:SetActive(b)
end

function M:LightSwitch(on_or_off)
    self.car_deng_node.gameObject:SetActive(on_or_off)
end

function M:GetCurrentFbxMaterial()
    --子类里面实现
    if self[self.config.car_type] and self[self.config.car_type].GetCurrentFbxMaterial then
        return self[self.config.car_type]:GetCurrentFbxMaterial()
    else
        return nil
    end
end

function M:SetFbxMaterial(material_name)
    --子类里面实现
    if self[self.config.car_type] and self[self.config.car_type].SetFbxMaterial then
        self[self.config.car_type]:SetFbxMaterial(material_name)
    else
        dump(self.config.car_type .. "未实现SetFbxMaterial方法，设置材质失败")
    end
end

function M:SetHighLight(enabled,color)
    --子类里面实现
    if self[self.config.car_type] and self[self.config.car_type].SetHighLight then
        self[self.config.car_type]:SetHighLight(enabled,color)
    else
        dump(self.config.car_type .. "未实现SetHighLight方法，设置Highlight失败")
    end

end
function M:PlayCarBoomFly(cbk)
    --子类里面实现
    if self[self.config.car_type] and self[self.config.car_type].PlayCarBoomFly then
        self[self.config.car_type]:PlayCarBoomFly(cbk)
    else
        dump(self.config.car_type .. "未实现PlayCarBoomFly方法，播放动画失败")
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(0.5)
        seq:AppendCallback(function()
            cbk()
        end)
    end
end