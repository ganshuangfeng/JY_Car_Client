DriveLogicProcess = {}
local M = DriveLogicProcess
M.dotween_key = "DriveLogicProcess"
local this

--自己关心的事件
local listener

local function MakeListener()
    listener = {}
    listener["car_move_to_pos"] = M.on_car_move_to_pos
    -- listener["car_move_end"] = M.on_car_move_end

    listener["process_play_next"] = M.on_process_play_next
    listener["process_play_by_no"] = M.on_process_play_by_no
end

local function AddListener(listener)
    for proto_name, func in pairs(listener) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveMsgListener(listener)
    for proto_name, func in pairs(listener) do
        Event.RemoveListener(proto_name, func)
    end
end

local process_data
local process_data_by_no

--初始化
function M.Init()
    this = M
    process_data = {}
    process_data_by_no = {}
    MakeListener()
    AddListener(listener)
end

function M.Exit()
    if this then
        this = nil
        process_data = nil
        process_data_by_no = nil
        RemoveMsgListener(listener)
        DOTweenManager.KillLayerKeyTween(M.dotween_key)
    end
end

--方法-------------------------------------------
function M.get_process_data_by_father_process_no(father_process_no)
    local ret = {}
    if process_data and father_process_no then
        for i,v in ipairs(process_data) do
            if v.father_process_no and v.father_process_no == father_process_no then
                ret[#ret+1] = v
            end
        end
    end
    return ret
end
--按process_no获取process_data
function M.get_process_data_by_process_no(process_no)
    if process_data and process_no then
        for i,v in ipairs(process_data) do
            if v.process_no and v.process_no == process_no then
                return v
            end
        end
    end
end

function M.get_current_process_data()
    return process_data
end
function M.set_process_data_use(process_no)
    if process_data_by_no[process_no] then
        process_data_by_no[process_no].use = true
    end
end

--设置每个过程数据的pos,需要考虑 移动,障碍...
function M.set_process_data_structure()
    local process_data_structure = {}
    local index = 1
    local build_data 
    build_data = function(v)
        if not process_data_structure[index] or not next(process_data_structure[index]) then
            process_data_structure[index] = {}
        end
        if v.pos then
            if not next(process_data_structure[index]) and not process_data_structure[index].pos then
                process_data_structure[index].pos = v.pos
            end
            if process_data_structure[index].pos == v.pos then
                process_data_structure[index][#process_data_structure[index] + 1] = v
            else
                index = index + 1
                build_data(v)
            end
        else
            process_data_structure[index][#process_data_structure[index] + 1] = v
        end
    end
    for i,v in ipairs(process_data) do
        build_data(v)
    end

    dump(process_data_structure,"<color=red>新的数据结构 process_data_structure</color>")

    local index = 1
    local pds = {}

    local action_structrue = {}

    for i1,v1 in ipairs(process_data_structure) do
        for i,v in ipairs(v1) do
            
        end        
    end

    for i,v in ipairs(process_data) do
        if not (v.player_action or string.match(v.key,"obj")) then
            break
        end
        if not v.build and v.player_action then
            action_structrue[#action_structrue + 1] = v
            v.build = true
        end
        if not v.build and string.match(v.key,"obj") then
            action_structrue[#action_structrue + 1] = v
            v.build = true
            if v.pos and not action_structrue.pos then
                action_structrue.pos = v.pos
            end
        end
    end
    pds[index] = pds[index] or {}
    pds[index][#pds[index] + 1] = action_structrue

    index = index + 1



    dump(process_data_structure,"<color=red>新的数据结构 process_data_structure</color>")

    -- local car_move_num = {}
    -- for i,v in ipairs(process_data) do
    --     if v.obj_car_move then
    --         car_move_num[v.obj_car_move.car_no] = car_move_num[v.obj_car_move.car_no] or 0
    --         car_move_num[v.obj_car_move.car_no] = car_move_num[v.obj_car_move.car_no] + v.obj_car_move.move_nums
    --     end
    --     if v.skill_trigger and v.skill_trigger.skill_id == 29 then
    --         --路障
    --         car_move_num[v.skill_trigger.receive_car_no[1]] = v.skill_trigger.pos
    --     end
    -- end

    -- for i,v in ipairs(process_data) do
    --     if (v.status_change and not v.status_change.pos) or v.player_op then
    --         local cars = DriveCarManager.GetCarBySeat(v[v.key].seat_num)
    --         for car_no,car in pairs(cars) do
    --             if car_move_num[car_no] then
    --                 v.pos = car.car_data.pos + car_move_num[car_no]
    --                 v[v.key].pos = v.pos
    --             else
    --                 v.pos = car.car_data.pos
    --                 v[v.key].pos = v.pos
    --             end
    --         end
    --     end
    -- end

end

--方法-------------------------------------------
function M.on_drive_game_process_data_msg()
    --处理数据
    process_data = DriveModel.data.process_data
    for i,v in ipairs(process_data) do
        process_data_by_no[v.process_no] = v
    end

    dump(process_data,"<color=yellow>流程开始》》》》》》》》》》》》》》》》》</color>")

    Event.Brocast("drive_game_process_data_msg_begin")
    M.on_process_play_next()

    local car_move_time = DriveCarManager.GetCarMoveTime(process_data)
    return car_move_time + 30
end

function M.check_process_start()
    if not process_data or not next(process_data) then return end
    return not process_data[1].use
end

function M.check_process_end()
    if not process_data or not next(process_data) then return end
    for i,v in ipairs(process_data) do
        if not v.use then return end
    end
    return process_data[#process_data].use and not process_data[#process_data].end_refresh
end

--流程是否暂停
local is_pause = false
function M.set_process_pause(b)
    is_pause = b    
end

function M.check_process_pause()
    return is_pause
end

function M.check_process_obj_car_move()
    for k,v in pairs(process_data) do
        if v.obj_car_move then
            return true
        end
    end
end

function M.get_no_process(data)
    for i,v in ipairs(process_data) do
        if data.process_no and v.process_no == data.process_no then
            return v
        end
    end
end

function M.on_process_play_by_no(data,funcs,other_data)
    local pd_no = M.get_no_process(data)
    dump(pd_no)
    if pd_no and next(pd_no) then
        M.play_process(pd_no,funcs,other_data)
    end
end

function M.get_next_process()
    for i,v in ipairs(process_data) do
        if not v.use then
            return v
        end
    end
end

function M.on_process_play_next()
    local pd_next = M.get_next_process()
    if M.check_process_pause() then 
        --流程暂停 
        return 
    end
    -- dump(pd_next,"<color=blue>play_process_next</color>")
    -- dump(debug.traceback(),"<color=white>play_process_next</color>")

    Event.Brocast("drive_game_process_data_msg_next",pd_next)

    if M.check_process_start() then
        Event.Brocast("drive_game_process_data_msg_start")
    end
    
    if M.check_process_end() then
        --播放完成
        process_data[#process_data].end_refresh = true
        Event.Brocast("drive_game_process_data_msg_end")
    end

    if not pd_next or pd_next.use then return end
    local pd = pd_next[pd_next.key]
    if pd.pos then
        --检查车辆pos是否匹配，不匹配等到车辆移动到该位置再执行下一条
        if pd.car_no then
            --车
            local car = DriveCarManager.GetCar(pd)
            if car and car.car_data.pos == pd.pos then
                M.play_process(pd_next)
            end
        elseif pd.trigger_data and next(pd.trigger_data) and pd.trigger_data[1].owner_type == 2 then
            local car = DriveCarManager.GetCar({car_no = pd.trigger_data[1].owner_id})
            if car and car.car_data.pos == pd.pos then
                M.play_process(pd_next)
            end
        elseif pd.owner_data and pd.owner_data.owner_type == 2 then
            --车
            local car = DriveCarManager.GetCar({car_no = pd.owner_data.owner_id})
            if car and car.car_data.pos == pd.pos then
                M.play_process(pd_next)
            end
        else
            local cars = DriveCarManager.GetAllCar()
            for seat_num,v in pairs(cars) do
                for car_no,car in pairs(v) do
                    if car.car_data.pos == pd.pos then
                        M.play_process(pd_next)
                        return
                    end
                end
            end
        end
    else
        if (pd_next.status_change or pd_next.player_op) then
            if not M.check_process_obj_car_move() then
                M.play_process(pd_next)
            elseif pd_next.car_move_end then
                M.play_process(pd_next)
            end
        else
            M.play_process(pd_next)
        end
    end
end

function M.on_car_move_to_pos(data)
    if data.car_data.end_pos == data.car_data.pos then
        for i,v in ipairs(process_data) do
            if (v.status_change or v.player_op) then
                v.car_move_end = true
            end
        end
    end
    if not data.block_play_process then
        M.on_process_play_next()
    end
end

function M.set_car_move_end()
    if process_data and next(process_data) then
        for i,v in ipairs(process_data) do
            if (v.status_change or v.player_op) then
                v.car_move_end = true
            end
        end
    end
end

function M.on_car_move_end(data)
    if data.car_data.end_pos == data.car_data.pos then
        for i,v in ipairs(process_data) do
            if (v.status_change or v.player_op) then
                v.car_move_end = true
            end
        end
    end
    M.on_process_play_next()
end

function M.play_process(data,funcs,other_data)
    Event.Brocast("drive_game_process_data_msg_running")
    dump({data = data,funcs = funcs,other_data = other_data},"<color=blue>play_process</color>")
    dump(debug.traceback(),"<color=blue>play_process_stack</color>")
    M.set_process_data_use(data.process_no)
    local key = "play_process_"
    key = key .. data.key
    local value = data[data.key]
    if not M[key] or type(M[key]) ~= "function" then
        key = data.key
        M.play_process_(data,funcs,other_data)
        return
    end
    -- print("<color=green>已实现过程 " .. key .. " 的方法</color>")
    M[key](data,funcs,other_data)
end

function M.play_process_(data,funcs,other_data)
    local key = data.key
    print("<color=red>！！！未实现过程 " .. key .. " 的方法</color>")
    if not key then key = "" end
    -- data.funcs = funcs
    -- data.other_data = other_data
    Event.Brocast("play_process_" .. key,data,funcs,other_data)
end

function M.play_process_status_change(data)
    dump(data,"<color=yellow>play_process_status_change</color>")
    local m_data = data[data.key]
    --游戏状态改变
    if m_data.seat_num then
        DriveModel.data.players_info[m_data.seat_num].status = DriveModel.GameingStatus[m_data.status]
    else
        for k,v in pairs(DriveModel.data.players_info) do
            v.status = DriveModel.GameingStatus[m_data.status]
            v.status_pos = m_data.pos
        end
    end

    if DriveModel.GameingStatus[m_data.status] == DriveModel.GameingStatus.game_over then
        DriveModel.data.game_status = DriveModel.GameStatus.game_over

        --车辆移动到终点停止
        if m_data.pos and m_data.seat_num then
            local v
            local car_no
            for i = #DriveModel.data.process_data,1,-1 do
                v = DriveModel.data.process_data[i]
                if v.obj_car_move then
                    car_no = v.obj_car_move.car_no
                    v = nil
                    break
                end
            end
            if car_no then
                local car_data = {
                    car_no = car_no,
                    pos = m_data.pos,
                }
                -- Event.Brocast("play_process_obj_car_stop",car_data)
            end
        end
    end

    Event.Brocast("logic_drive_game_process_data_msg_status_change",m_data)

    Event.Brocast("process_play_next")
end

function M.play_process_player_op(data)
    dump(data,"<color=yellow>play_process_player_op</color>")
    local m_data = data[data.key]
    DriveModel.data.player_op = data
    --需要玩家操作消息
    for k,v in pairs(DriveModel.data.players_info) do
        v.player_op = nil
    end
    DriveModel.data.players_info[m_data.seat_num].player_op = m_data
    if DriveModel.client_status == DriveModel.ClientStatus.normal then
        --正常状态需要更新倒计时
        DriveModel.data.op_timeout = m_data.op_timeout
    end
    if ToolsManager and ToolsManager.m_data then
        ToolsManager.check_play_award_box_tool_create(function()
            Event.Brocast("logic_drive_game_process_data_msg_player_op",data)
            Event.Brocast("process_play_next")
            
        end)
    else
    end
end

function M.play_process_player_action(data)
    local m_data = data[data.key]
    --玩家操作信息
    for k,v in pairs(DriveModel.data.players_info) do
        v.player_action = nil
    end
    DriveModel.data.players_info[m_data.seat_num].player_action = m_data
    Event.Brocast("logic_drive_game_process_data_msg_player_action",m_data)

    if m_data.op_type == DriveModel.OPType.select_skill 
        or m_data.op_type == DriveModel.OPType.select_tool_op or m_data.op_type == DriveModel.OPType.select_map_award then
        dump(data,"<color=green>play_process_player_action:不需要播放下一步</color>")
        --选择技能的action在选择技能界面动画播放完成后进行下一步
    else
        Event.Brocast("process_play_next")
    end
end

return M