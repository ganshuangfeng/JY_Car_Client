DriveModel = {}
local M = DriveModel
local this
local listener
local m_data

--操作类型
M.OPType = {
    accelerator_all = 1,--大小油门
    accelerator_big = 2,--大油门
    accelerator_small = 3,--小油门
    select_index = 4,--选择索引
    select_road = 5,--选择道路
    select_skill = 6,--选择技能
    use_tool = 7,--使用道具
    select_tool_op = 8,--选择道具选项，1是立即使用，2是稍后使用（放入背包）
    select_clear_barrier = 10,--清除路上路障
    select_map_award = 11,--选择地图奖励
}

--所属者类型
M.OwnerType = {
    system = -1,--系统
    player = 1,--玩家
    car = 2,--车
    road = 3,--道路
    barrier = 4,--障碍
}

--动画表现时间
M.time = {
    --技能表现
    normal_skill_before_delay = 0.8, --通用技能前摇延迟

    skill_exchange_hp = 5, --交换血量动画延迟

    exchange_car_bg_fade = 0.8, --位置交换背景fade
    exchange_car_title_scale = 0.6, --位置交换美术字弹跳
    exchange_car_thunder_move_time = 0.25, --位置交换闪电移动时间
    exchange_car_thunder_wait = 1,--闪电移动完成后等待时间
    exchange_car_move_time = 3, --位置交换车辆移动时间
    exchange_car_end_wait = 0.5, -- 位置交换动画播放完成后等待
    ----------------------------------------------------
}

--游戏状态
M.GameStatus = {
    wait_table = "wait_table",      -- 报名之后，new_game 之后的，等待匹配桌子
    wait_ready = "wait_ready",      -- 玩家 join 游戏之后状态，等待准备状态
    gaming = "gaming",              -- 玩家 准备ok之后，开始游戏状态
    settlement = "settlement",      -- 结算状态
    game_over = "game_over",        -- 游戏结束状态
}

--游戏中状态
--[[
    wait_p     init          ready         ready_ok          running          game_over           settlement
]]

--游戏中的状态(表示状态切换节点,不是真正意义上的状态,玩家实际状态通过 player_op 来决定)
M.GameingStatus = {
    -- # 游戏状态改变 ，1 = game_begin , 2 = round_start , 3 =  game_over
    game_begin = "game_begin",--游戏开始
    round_start = "round_start",--回合开始
    game_over = "game_over",--游戏结束
    [1] = "game_begin",
    [2] = "round_start",
    [3] = "game_over",
}

--客户端的状态
M.ClientStatus = {
    normal = "normal", --正常状态
    recovering = "recovering", --断线重连恢复中
}

function M.SetClientStatus(status)
    if not M.ClientStatus[status] then 
        error("status " .. status .. " is nil")
        return 
    end
    M.client_status = status
end

--客户端是否正在播放某一个过程
M.play_process = false

function M.SetPlayProcess(b)
    M.play_process = b   
end

--network-------------------
local network_data_cache = {} --网络数据缓存
local network_status_no = 1 --网络消息编号

function M.NetworkDataCachePopFront()
    if not network_data_cache or not next(network_data_cache) then
        return
    end

    local min
    for no,data in pairs(network_data_cache) do
        if not min then min = no end
        if min > no then min = no end
    end
    if not min then return end
    local data = network_data_cache[min]
    network_data_cache[min] = nil
    return data
end

function M.NetworkDataCachePopBack()
    if not network_data_cache or not next(network_data_cache) then
        return
    end

    local max
    for no,data in pairs(network_data_cache) do
        if not max then max = no end
        if max < no then max = no end
    end
    if not max then return end
    local data = network_data_cache[max]
    network_data_cache[max] = nil
    return data
end

function M.NetworkDataCacheGetFront()
    if not network_data_cache or not next(network_data_cache) then
        return
    end

    local min
    for no,data in pairs(network_data_cache) do
        if not min then min = no end
        if min > no then min = no end
    end
    if not min then return end
    local data = network_data_cache[min]
    return data
end

function M.NetworkDataCacheGetBack()
    if not network_data_cache or not next(network_data_cache) then
        return
    end

    local max
    for no,data in pairs(network_data_cache) do
        if not max then max = no end
        if max < no then max = no end
    end
    if not max then return end
    local data = network_data_cache[max]
    return data
end

--恢复网络缓存数据
function M.NetworkDataCacheRecover()
    local network_data = M.NetworkDataCacheGetFront()
    dump(network_data,"network_data")
    if network_data and next(network_data) then
        M.SetPlayProcess(false)
        Event.Brocast(network_data.proto_name,network_data.proto_name,network_data.data)
        return true
    end
end

local send_request_cache = {} --请求网络数据缓存
function M.SendRequest(name, args, callback,fix_response)
    -- dump(debug.traceback(),"<color=yellow>堆栈</color>")
    -- dump({name, args, callback,fix_response},"<color=yellow>请求网络数据</color>")
    -- dump({client_status = M.client_status, recovering = M.ClientStatus.recovering},"<color=yellow>请求网络数据</color>")
    --恢复中不能进行网络请求
    if not M.client_status == M.ClientStatus.recovering then return end
    if name == "pvp_all_info_req" then
        --限制处理消息  此时只处理指定的消息
        DriveModel.limitDealMsg = {pvp_all_info_req_response = true}
    end

    if not Network.CheckConnect() then
        send_request_cache[name] = {name = name,args = args,callback = callback,fix_response = fix_response}
    end

    Network.SendRequest(name, args, callback,fix_response)
end

--缓存请求恢复
function M.SendRequestCache()
    if not send_request_cache or not next(send_request_cache) then return end
    for k,v in pairs(send_request_cache) do
        M.SendRequest(v.name, v.args, v.callback,v.fix_response)
    end
    send_request_cache = {}
end

local function MakeListener()
    listener = {}
    --pve response
    listener["pvp_all_info_req_response"] = M.on_pvp_all_info_req_response
    listener["pvp_signup_response"] = M.on_pvp_signup_response
    listener["pvp_quit_game_response"] = M.on_pvp_quit_game_response
    --pve msg
    listener["pvp_join_msg"] = M.on_pvp_join_msg
    listener["pvp_enter_room_msg"] = M.on_pvp_enter_room_msg
    listener["pvp_game_over_msg"] = M.on_pvp_game_over_msg
    listener["pvp_auto_quit_game"] = M.on_pvp_auto_quit_game

    --drive response
    listener["drive_game_player_op_req_response"] = M.on_drive_game_player_op_req_response
    --drive msg
    listener["drive_game_process_data_msg"] = M.on_drive_game_process_data_msg
    listener["driver_ready_msg"] = M.on_driver_ready_msg
    listener["driver_ready_ok_msg"] = M.on_driver_ready_ok_msg
    listener["driver_game_begin_msg"] = M.on_driver_game_begin_msg
    listener["driver_game_over_msg"] = M.on_driver_game_over_msg
    listener["drive_game_settlement_msg"] = M.on_drive_game_settlement_msg
    listener["pvp_game_settlement_msg"] = M.on_pvp_game_settlement_msg
end

local function MsgDispatch(proto_name,data)
    -- dump({proto_name = proto_name,limitDealMsg = M.limitDealMsg},"<color=green>MsgDispatch</color>")
    -- dump(data,"<color=green>MsgDispatch data</color>")
    -- dump(data.status_no,"<color=green>data.status_no</color>")
    -- dump(m_data.status_no,"<color=green>m_data.status_no</color>")
    --临时限制   一般在断线重连时生效  由logic控制
    if M.limitDealMsg and not M.limitDealMsg[proto_name] then
        dump(M.limitDealMsg,"<color=red>消息被限制</color>")
        return
    end

    if proto_name == "pvp_all_info_req_response"  then
        --all_info消息
        --未报名或者正确返回放开限制
        if data.result == -1 or data.result == 0 then
            DriveModel.limitDealMsg = nil
        elseif not data.result then
            --没有返回值直接退出场景
            DriveLogic.ExitGame()
            return
        end
    end

    --客户端恢复状态中，网络数据先缓存，客户端恢复完成后再处理
    -- dump(network_data_cache,"<color=green>network_data_cache</color>")
    -- dump(M.client_status,"<color=red>客户端当前状态：client_status</color>")
    if M.client_status == M.ClientStatus.recovering then
        if DriveLogic.status_no and data.status_no and DriveLogic.status_no == data.status_no then
            --正在恢复的状态编号和网络请求的状态编号相同不用缓存网络数据
            dump({DriveLogic_status_no = DriveLogic.status_no,data_status_no = data.status_no,data = data,proto_name = proto_name},"<color=red>recovering status_no </color>")
            return
        end
        if data.status_no then
            network_data_cache[data.status_no] = {proto_name = proto_name,data = data}
            print("<color=red>recovering network_data_cache status_no = " .. data.status_no .. " proto_name = " .. proto_name .. "</color>")
        end
        return
    end

    --客户端正在播放中，网络数据先缓存，客户端播放完成后再处理
    if M.play_process then
        if data.status_no then
            network_data_cache[data.status_no] = {proto_name = proto_name,data = data}
            print("<color=red>play_process network_data_cache status_no = " .. data.status_no .. " proto_name = " .. proto_name .. "</color>")
        end
        return
    end

    --网络错误处理
    if data.status_no then
        if proto_name == "pvp_all_info_req_response"  then
            --all_info消息
            --请求的状态和客户端当前状态相同不需要处理
            if m_data.all_info_data == data and m_data.status_no == data.status_no then
                dump(data.status_no,"<color=red>all_info消息重复</color>")
                if data.status_no and network_data_cache[data.status_no] then
                    network_data_cache[data.status_no] = nil
                end
                return
            end
            m_data.all_info_data = data
        else
            --其它消息
            --消息不连续错误，发送状态编码错误事件
            if m_data.status_no and m_data.status_no ~= data.status_no - 1 and m_data.status_no ~= data.status_no then
                --限制所有消息
                DriveModel.limitDealMsg = nil
                Event.Brocast("model_nor_mg_status_no_error_msg")
                dump({data_status_no = data.status_no,mdata_status_no = m_data.status_no},"<color=red>消息不连续错误，发送状态编码错误事件</color>")
                return
            end
        end
    end

    --数据处理
    local func = listener[proto_name]
    if not func then
        print("<color=red>brocast " .. proto_name .. " has no event" .. "</color>")
    end

    if data.status_no and network_data_cache[data.status_no] then
        network_data_cache[data.status_no] = nil
    end

    if data.status_no then
        m_data.status_no = data.status_no
    end

    func(proto_name, data)

    --网络缓存处理
    M.NetworkDataCacheRecover()
end

function M.AddListener()
    MakeListener()
    for proto_name, func in pairs(listener) do
        if proto_name == "AssetChange" then
            Event.AddListener(proto_name, func)
        else
            Event.AddListener(proto_name, MsgDispatch)
        end
    end
end

function M.RemoveMsgListener()
    for proto_name, func in pairs(listener) do
        if proto_name == "AssetChange" then
            Event.RemoveListener(proto_name, func)
        else
            Event.RemoveListener(proto_name, MsgDispatch)
        end
    end
end

function M.GetStatusNo()
    if m_data or not m_data.status_no then return 0 end
    return m_data.status_no
end

function M.Init()
    this = M
    M.InitGameData()
    M.InitClientConfig()
    M.AddListener()
    M.data = m_data
    return M
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        this = nil
        listener = nil
        m_data = nil
        M.data = nil
    end
end

function M.InitGameData()
    --初始化游戏数据
    m_data = {}
    
    m_data.speed = 1
    -- --车辆数据
    -- m_data.car_data = nil
    -- --玩家数据
    -- m_data.players_info = nil
    -- --系统数据
    -- m_data.system_data = nil
    -- --房间数据
    -- m_data.room_info = nil
    -- --座位号
    -- m_data.seat_num = nil
    -- --地图数据
    -- m_data.map_data = nil
    M.data = m_data
end

function M.InitClientConfig()
    M.ClientConfig = {}
end

local int_op_timeout = 0
local cur_int_op_timeout = 0
--修正当前倒计时时间
function M.correct_op_timeout(delta_time)
    -- dump({op_timeout = m_data.op_timeout,delta_time = delta_time},"<color=green>修正倒计时时间</color>")
    if not m_data or not m_data.op_timeout then return end
    if not delta_time then return end
    m_data.op_timeout = m_data.op_timeout - delta_time
    if m_data.op_timeout < 0 then
        m_data.op_timeout = 0
    end
    cur_int_op_timeout = math.floor(m_data.op_timeout)
    if cur_int_op_timeout ~= int_op_timeout then
        int_op_timeout = cur_int_op_timeout
        Event.Brocast("model_correct_op_timeout",{op_timeout = int_op_timeout,delta_time = delta_time})
    end
end

--没有倒计时的时候返回-1
function M.get_op_timeout()
    if not m_data or not m_data.op_timeout then return -1 end
    if m_data.op_timeout < 0 then
        m_data.op_timeout = 0
    end
    return math.floor(m_data.op_timeout)
end

local function set_now_data(now_data)
    if not now_data or not next(now_data) then return end
    if now_data.car_data and next(now_data.car_data) then
        --车数据
        m_data.car_data = {}
        for k,v in pairs(now_data.car_data) do
            m_data.car_data[v.seat_num] = m_data.car_data[v.seat_num] or {}
            m_data.car_data[v.seat_num][v.car_id] = v        
        end
    end

    if now_data.players_info and next(now_data.players_info) then
        --玩家信息
        m_data.players_info = {}
        for k,v in pairs(now_data.players_info) do
            m_data.players_info[v.seat_num] = v
            if v.id == MainModel.UserInfo.user_id then
                m_data.seat_num = v.seat_num
            end     
        end
    end

    if now_data.system_data and next(now_data.system_data) then
        --系统数据
        m_data.system_data = now_data.system_data
    end

    --地图信息
    m_data.map_data = now_data.map_data
    if m_data.map_data.map_id == -1 then
        m_data.map_data.map_id = 4
    end
end

function M.Refresh(now_data)
    if now_data and next(now_data) then
        set_now_data(now_data)
    else
        set_now_data(m_data.end_data)
    end
end

local function process_data_s2c(process_data)
    dump(process_data,"<color=green>s_process_data</color>")
    for i,v in ipairs(process_data or {}) do
        if v and next(v) then
            local key
            if v.key then
                key = v.key
            else
                for k,_v in pairs(v) do
                    if type(_v) == "table" then
                        key = k
                        break
                    end
                end
            end

            --pos :用于确定过程播放时车辆所在的位置
            local pos = v[key].pos
            local road_id = v[key].road_id
            if pos then
                v.pos = pos
            --必须是车辆的位置才能写入pos
            elseif v[key].trigger_data and next(v[key].trigger_data) and v[key].trigger_data[1].owner_type == 2 then
                v.pos = v[key].trigger_data[1].owner_pos
            elseif v[key].owner_data and v[key].owner_data.owner_type == 2 then
                v.pos = v[key].owner_data.owner_pos
            end
            if road_id then
                v.road_id = road_id
            end
            v.key = key
            v.index = i
            v[key].pos = v.pos

            if v[v.key].skill_data then
                v[v.key].skill_id = v[v.key].skill_id or v[v.key].skill_data.skill_id
            end
        end
    end
    dump(process_data,"<color=green>c_process_data</color>")
    return process_data
end

--all_info数据
function M.on_pvp_all_info_req_response(_,data)
    dump(data,"<color=green>游戏的 pvp_all_info_req_response</color>")
    for k,v in pairs(data) do
        dump(v,"<color=green>游戏的".. k .."数据</color>")
        if k == "nor_drive_game_info" then
            for k1,v1 in pairs(v) do
                dump(v1,"<color=green>游戏的 nor_drive_game_info ".. k1 .."数据</color>")
            end
        end
    end
    if data.result ~= 0 then
        Event.Brocast("model_pvp_all_info_req_response",data)
        return
    end

    --后台进入更新时的状态编号和请求的状态编号相同,客户端已经还原到最新状态,不用再对后面的数据进行处理
    if DriveLogic.status_no == data.status_no then
        dump(DriveLogic.status_no,"<color=red>--后台进入更新时的状态编号和请求的状态编号相同,客户端已经还原到最新状态,不用再对后面的数据进行处理</color>")
        return
    end

    M.InitGameData()

    --编号
    m_data.status_no = data.status_no
    --游戏状态
    m_data.game_status = data.status
    --游戏类型 pve
    m_data.game_type = data.game_type
    --房间信息
    m_data.room_info = data.room_info
    --玩家数据
    m_data.players_info = {}
    if data.players_info and next(data.players_info) then
        for k,v in pairs(data.players_info) do
            m_data.players_info[v.seat_num] = v
            if v.id == MainModel.UserInfo.user_id then
                m_data.seat_num = v.seat_num
            end     
        end
    end

    --游戏数据
    if data.nor_drive_game_info and next(data.nor_drive_game_info) then
        --变化过程数据
        m_data.start_data = data.nor_drive_game_info.start_data
        m_data.process_data = process_data_s2c(data.nor_drive_game_info.process_data)

        m_data.end_data = data.nor_drive_game_info.end_data
        --服务器当前时间
        m_data.run_time = data.nor_drive_game_info.run_time
        --操作倒计时
        m_data.op_timeout = data.nor_drive_game_info.op_timeout
        
        --结算信息
        m_data.settlement_info = data.nor_drive_game_info.settlement_info

        --处理开始时的快照数据
        if data.nor_drive_game_info.start_data and next(data.nor_drive_game_info.start_data) then
            set_now_data(data.nor_drive_game_info.start_data)
            Event.Brocast("model_pvp_all_info_req_response",m_data)
            return
        end

        if data.nor_drive_game_info.end_data and next(data.nor_drive_game_info.end_data) then
            set_now_data(data.nor_drive_game_info.end_data)
        end
    end
    Event.Brocast("model_pvp_all_info_req_response",m_data)
end

--process数据
function M.on_drive_game_process_data_msg(_,data)
    dump(data,"<color=green>drive_game_process_data_msg</color>")
    m_data.start_data = data.start_data or m_data.start_data
    m_data.end_data = data.end_data

    --改变过程
    m_data.process_data = process_data_s2c(data.process_data)
    
    --最终结果
    if data.end_data and next(data.end_data) then
        set_now_data(data.end_data)
    end
    dump(m_data.players_info,"<color=green>players_info</color>")
    dump(m_data.car_data,"<color=green>car_data</color>")
    dump(m_data.system_data,"<color=green>system_data</color>")
    Event.Brocast("model_drive_game_process_data_msg")
end

--pve response
--报名
function M.on_pvp_signup_response(_,data)
    dump(data,"<color=green>on_pvp_signup_response</color>")
    network_data_cache = {}
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
        Event.Brocast("model_pvp_signup_response",data)
        return
    end
    M.InitGameData()
    --报名成功，wait_table 匹配中状态
    m_data.game_status = this.GameStatus.wait_table
    m_data.game_id = data.game_id
    -- data.map_id = 2 --临时代码
    m_data.map_id = data.map_id
    m_data.map_data = {}
    m_data.map_data.map_id = data.map_id

    --新手引导
    if m_data.map_data.map_id == -1 then
        m_data.map_data.map_id = 4
    end
    Event.Brocast("model_pvp_signup_response",data)
end

--退出游戏
function M.on_pvp_quit_game_response(_,data)
    dump(data,"<color=green>on_pvp_quit_game_response</color>")
    if data.result ~= 0 and data.result ~= 1004 then
        HintPanel.ErrorMsg(data.result)
        return
    end
    M.InitGameData()
    Event.Brocast("model_pvp_quit_game_response")
end

--pve msg
function M.on_pvp_enter_room_msg(_,data)
    dump(data,"<color=green>on_pvp_enter_room_msg</color>")
    m_data.players_info = m_data.players_info or {}
    for k,v in pairs(data.players_info) do
        m_data.players_info[v.seat_num] = v
        if v.id == MainModel.UserInfo.user_id then
            m_data.seat_num = v.seat_num
        end
    end
    m_data.room_info = data.room_info
    --#进入房间，wait_ready状态
    m_data.game_status = this.GameStatus.wait_ready
    Event.Brocast("model_pvp_enter_room_msg",data)
end

function M.on_pvp_join_msg(_,data)
    dump(data,"<color=green>on_pvp_join_msg</color>")
    m_data.players_info = m_data.players_info or {}
    m_data.players_info[data.player_info.seat_num] = data.player_info
    Event.Brocast("model_pvp_join_msg",data)
end

function M.on_pvp_game_over_msg(_,data)
    dump(data,"<color=green>on_pvp_game_over_msg</color>")
    -- m_data.game_status = data.status
    Event.Brocast("model_pvp_game_over_msg",data)
end

function M.on_pvp_auto_quit_game(data)
    dump(data,"<color=green>on_pvp_auto_quit_game</color>")
    -- if data.result ~= 0 then
    --     HintPanel.ErrorMsg(data.result)
    --     return
    -- end
    M.InitGameData()
    Event.Brocast("model_pvp_quit_game_response")  
end

--drive response
--玩家通用请求操作
function M.on_drive_game_player_op_req_response(_,data)
    dump(data,"<color=green>on_drive_game_player_op_req_response</color>")
    if data.result ~= 0 then
        TipsShowUpText.Create(errorCode[data.result])
        -- return
    end
    Event.Brocast("model_drive_game_player_op_req_response",data)
end

--drive msg
function M.on_driver_ready_msg(_,data)
    dump(data,"<color=green>on_driver_ready_msg</color>")
    m_data.players_info[data.seat_num].ready = true
    Event.Brocast("model_driver_ready_msg",data)
end

function M.on_driver_ready_ok_msg(_,data)
    dump(data,"<color=green>on_driver_ready_ok_msg</color>")
    m_data.ready_ok = true
    --#准备完成 gaming 请求AllInfo后设置状态
    -- m_data.game_status = this.GameStatus.gaming
    Event.Brocast("model_driver_ready_ok_msg",data)
end

function M.on_driver_game_begin_msg(_,data)
    dump(data,"<color=green>on_driver_game_begin_msg</color>")
    --游戏开始--暂时不作其他处理
    Event.Brocast("model_driver_game_begin_msg")
end

function M.on_driver_game_over_msg(_,data)
    dump(data,"<color=green>on_driver_game_over_msg</color>")
    m_data.game_status = data.status or this.GameStatus.game_over
    m_data.gameover_data = data.gameover_data
    Event.Brocast("model_driver_game_over_msg",data)
end

function M.on_drive_game_settlement_msg(_,data)
    dump(data,"<color=green>on_driver_game_settlement_msg</color>")
    m_data.game_status = data.status or this.GameStatus.settlement
    m_data.settlement_info = data.settlement_info
    Event.Brocast("model_driver_game_settlement_msg",data)
end

function M.on_pvp_game_settlement_msg(_,data)
    dump(data,"<color=green>on_pvp_game_settlement_msg</color>")
    m_data.pvp_game_settlement_data = data
    Event.Brocast("model_on_pvp_game_settlement_msg",data)
end

--设置动画表现时间
function M.SetSpeed(v)
    if not v and type(v) ~= "number" then return end
    M.data = M.data or {}
    M.data.speed = v
end

function M.GetSpeed()
    if M.data and M.data.speed then
        return M.data.speed
    end  
    return 1
end

--获取表现时间
function M.GetTime(t)
    t = t or 1
    if M and M.data and M.data.speed then
        M.data.speed = M.data.speed or 1
        return t / M.data.speed
    else
        return 0.02
    end
end

--检查主体是否是玩家自己
function M.CheckOwnerIsMe(data)
    if not data or not next(data) then return end

    if data.owner_type == DriveModel.OwnerType.player and data.owner_id == DriveModel.data.seat_num then
		--不是自己的技能
		return true
	end

	if data.owner_type == DriveModel.OwnerType.car then
		--不是自己的车的技能
		local car = DriveCarManager.GetCarByNo(data.owner_id)
		if car and car.car_data.seat_num == DriveModel.data.seat_num then
			return true
		end
	end
end

--检查是否是自己的回合
function M.CheckIsMyOp()
    if DriveModel.data.players_info[DriveModel.data.seat_num].player_op then 
        return true
    else
        return false
    end
end

-- 摄像机 用于坐标转化
function M.SetCamera()
    M.camera2d = GameObject.Find("2DNode/2DCamera"):GetComponent("Camera")
    M.camera3d = GameObject.Find("3DNode/3DCameraRoot/3DCamera"):GetComponent("Camera")
    M.camera3dParent = GameObject.Find("3DNode/3DCameraRoot").transform
end
-- 2D坐标转3D坐标
function M.Get2DTo3DPoint(vec)
    vec = M.camera2d:WorldToScreenPoint(vec)
    vec = M.camera3d:ScreenToWorldPoint(vec)
    return vec
end
-- 3D坐标转2D坐标
function M.Get3DTo2DPoint(vec)
    vec = M.camera3d:WorldToScreenPoint(vec)
    vec = M.camera2d:ScreenToWorldPoint(vec)
    return vec
end

--屏幕坐标转UI坐标
function M.ScreenToWorldPoint(pos)
    local _pos = M.camera2d:ScreenToWorldPoint(pos)
    return _pos
end

M.scale2Dto3D = 100
function M.Get3DTo2DScale(scale)
    scale.x = scale.x * M.scale2Dto3D
    scale.y = scale.y * M.scale2Dto3D
    scale.z = scale.z * M.scale2Dto3D
    return scale
end

function M.Get2DTo3DScale(scale)
    scale.x = scale.x / M.scale2Dto3D
    scale.y = scale.y / M.scale2Dto3D
    scale.z = scale.z / M.scale2Dto3D
    return scale
end