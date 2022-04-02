-- 创建时间:2020-10-15
DriveLogic = {}
local M = DriveLogic

ext_require_audio("Game.GameCommon.Lua.audio_game_config","drive")
ext_require("Game.game_Drive.Lua.DriveEffectManager")
ext_require("Game.game_Drive.Lua.DriveAnimManager")
ext_require("Game.game_Drive.Lua.DriveCarMoveHelper")
ext_require("Game.game_Drive.Lua.DriveModel")
ext_require("Game.game_Drive.Lua.DrivePanel")
ext_require("Game.game_Drive.Lua.DriveLogicProcess")
ext_require("Game.game_Drive.Lua.DriveMapManager")
ext_require("Game.game_Drive.Lua.DriveCarManager")
ext_require("Game.game_Drive.Lua.DriveSystemManager")
ext_require("Game.game_Drive.Lua.DrivePlayerManager")
ext_require("Game.game_Drive.Lua.DriveSkillCarPanel")
ext_require("Game.game_Drive.Lua.DriveClearingPanel")
ext_require("Game.game_Drive.Lua.DriveSelectSkillPanel")
ext_require("Game.game_Drive.Lua.DriveToolsContainer")
ext_require("Game.game_Drive.Lua.DriveSelectToolPanel")
ext_require("Game.game_Drive.Lua.DriveSelectToolOPPanel")
ext_require("Game.game_Drive.Lua.DriveSelectRoadAwardPanel")
ext_require("Game.game_Drive.Lua.SkillManager")
ext_require("Game.game_Drive.Lua.BuffManager")
ext_require("Game.game_Drive.Lua.ToolsManager")
ext_require("Game.game_Drive.Lua.RoadAwardManager")
ext_require("Game.game_Drive.Lua.RoadBarrierManager")
ext_require("Game.game_Drive.Lua.ObjHelper")
ext_require("Game.game_Drive.Lua.DriveBeginPanel")
ext_require("Game.game_Drive.Lua.DriveAccelerator")
ext_require("Game.game_Drive.Lua.DrivePTGAccelerator")
ext_require("Game.game_Drive.Lua.DriveDLCAccelerator")
ext_require("Game.game_Drive.Lua.DriveGameStatusPanel")
ext_require("Game.game_Drive.Lua.DriveGameInfoPanel")
ext_require("Game.game_Drive.Lua.DriveSkillBottomPanel")
ext_require("Game.game_Drive.Lua.DriveWaitTablePanel")
ext_require_audio("Game.game_Drive.Lua.audio_drive_config","drive")
local this
--自己关心的事件
local listener

local function MakeListener()
    listener = {}

    listener["EnterForeGround"] = M.OnEnterForeGround
    listener["EnterBackGround"] = M.OnEnterBackGround

    listener["login_complete"] = M.on_login_complete
    listener["server_disconnecte"] = M.on_server_disconnecte

    listener["model_nor_mg_status_no_error_msg"] = M.on_nor_mg_status_no_error_msg

    listener["model_pvp_signup_response"] = M.on_pvp_signup_response
    listener["model_driver_ready_ok_msg"] = M.on_driver_ready_ok_msg
    listener["model_pvp_quit_game_response"] = M.on_pvp_quit_game_response

    listener["model_pvp_all_info_req_response"] = M.on_pvp_all_info_req_response
    
    listener["model_drive_game_process_data_msg"] = M.on_drive_game_process_data_msg
    listener["drive_game_process_data_msg_begin"] = M.on_drive_game_process_data_msg_begin
    listener["drive_game_process_data_msg_running"] = M.on_drive_game_process_data_msg_running
    listener["drive_game_process_data_msg_end"] = M.on_drive_game_process_data_msg_end
end

local function SendRequestAllInfo()
    local status_no = DriveModel.GetStatusNo()
    status_no = status_no + 1
    DriveModel.SendRequest("pvp_all_info_req", {status_no = status_no})
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

local is_update --是否需要更新（进入前台，网络错误）
local Time = Time
local time_client
local time_server
local check_netword_cache

local speed_up = 64 --加速倍速 !!!速度不能为1
local function set_time_scale(ts,time_c,time_s,check_netword_cache)
    -- dump({ts = ts,time_client = time_client,time_server = time_server,run_time = DriveModel.data.run_time},"<color=yellow>!!!加减速</color>")
    ts = ts or 1
    time_client = time_c
    time_server = time_s
    check_netword_cache = check_netword_cache
    Time.timeScale = ts
    if Time.timeScale == 1 then
        --正常状态设置
        DriveModel.SetClientStatus(DriveModel.ClientStatus.normal)
        if DriveModel.NetworkDataCacheRecover() then
            set_time_scale(speed_up,0,0,true)
        end
    else
        --恢复状态设置
        DriveModel.SetClientStatus(DriveModel.ClientStatus.recovering)
    end
end

--逻辑update
function M.Update()
    DrivePanel.CheckClickScreen()
    DriveModel.correct_op_timeout(Time.unscaledDeltaTime)
    -- dump({is_update = is_update,ts = Time.timeScale,time_client = time_client,time_server = time_server,run_time = DriveModel.data.run_time},"<color=yellow>!!!加减速</color>")
    if Time.timeScale == 1 then 
        return 
    end

    --恢复网络缓存的时候保持加速
    if check_netword_cache then
        local network_data = M.NetworkDataCacheGetFront()
        if not network_data or not next(network_data) then
            set_time_scale()
        end
        return
    end

    if not time_client or not time_server then
        return 
    end

    time_client = time_client + Time.deltaTime
    time_server = time_server + Time.unscaledDeltaTime

    --从后台进入追上当前服务器的时间即可
    if is_update then
        if time_client >= time_server then            
            is_update = false
            --恢复正常速度
            set_time_scale()
            return
        end
    end

    --快进到服务器当前时间就恢复
    if DriveModel and DriveModel.data and next(DriveModel.data) and DriveModel.data.run_time then
        if time_client >= time_server + DriveModel.data.run_time then
            --恢复正常速度
            set_time_scale()
            return
        end
    end
end

--物理update
function M.FixedUpdate()
	-- time_client = time_client + Time.deltaTime
end

--游戏前台消息
function M.OnEnterForeGround()
    time_client = 0
    time_server = Time.realtimeSinceStartup - time_server --在后台服务器经过了的时间
    dump({time_server = time_server,status_no = DriveModel.data.status_no},"<color=white>前台>>>>>>>>></color>")
    M.status_no = DriveModel.data.status_no
    SendRequestAllInfo()
    is_update = true
    set_time_scale(speed_up,0,0)
end

--游戏后台消息
function M.OnEnterBackGround()
    is_update = false
    time_server = Time.realtimeSinceStartup
    dump({time_server = time_server},"<color=white>后台>>>>>>>>></color>")
end

--服务器断开
function M.on_server_disconnecte()
    M.status_no = DriveModel.data.status_no
end

--游戏重新连接消息
function M.on_login_complete()
    M.status_no = DriveModel.data.status_no
    SendRequestAllInfo()
    DriveModel.SendRequestCache()
end

--网络状态错误
function M.on_nor_mg_status_no_error_msg()
    SendRequestAllInfo()
end

--初始化
function M.Init(pram)
    dump(pram,"<color=red>goto_scene_pram</color>")
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    MainLogic.EnterGame()
    this = M
    this.InitPram = pram
    if not this.InitPram.map_id then
        this.InitPram.map_id = pram.game_id
    end
    MakeListener()
    AddListener(listener)

    DriveLogicProcess.Init()
    --初始化model
    DriveModel.Init()
    DriveMapManager.Init()
    DriveCarManager.Init()
    DriveSystemManager.Init()
    
    SkillManager.Init()
    BuffManager.Init()
    ToolsManager.Init()
    RoadAwardManager.Init()
    RoadBarrierManager.Init()
    ObjHelper.Init()

    DrivePlayerManager.Init()
    --创建主界面
    DrivePanel.Init()
    AudioManager.PlaySceneBGM(audio_config.drive.com_main_map_BGM.audio_name)

    --注册循环
    if not M.update_handle then
        M.update_handle = UpdateBeat:CreateListener(M.Update,M)
    end
    UpdateBeat:AddListener(M.update_handle)
    --初始化正常时间状态
    set_time_scale()
    
    --设置相机
    DriveModel.SetCamera()

    SendRequestAllInfo()

    local obj = GameObject.Find("3DCameraRoot")
    obj.transform.localPosition = Vector3.New(0,0,-19.99)
end

function M.Exit()
    set_time_scale()
    if this then
        this = nil
        if M.update_handle then
            UpdateBeat:RemoveListener(M.update_handle)	
        end
        M.update_handle = nil

        if M.fixed_update_handle then
            FixedUpdateBeat:RemoveListener(M.fixed_update_handle)	
        end
        M.fixed_update_handle = nil

        audioMgr:CloseSound()
        RemoveMsgListener(listener)

        DriveLogicProcess.Exit()
        DriveMapManager.Exit()
        DriveCarManager.Exit()
        DriveSystemManager.Exit()
        SkillManager.Exit()
        BuffManager.Exit()
        ToolsManager.Exit()
        RoadAwardManager.Exit()
        RoadBarrierManager.Exit()
        ObjHelper.Exit()
        DrivePlayerManager.Exit()
        DrivePanel.Exit()
        DriveModel.Exit()
    end
end

function M.ExitGame()
    Event.Brocast("drive_logic_exit_game")
    MainLogic.ExitGame()
    GameManager.Goto({_goto = "game_Hall"})
end

function M.on_pvp_signup_response(data)
    if data.result == 0 then return end
    HintPanel.ErrorMsg(data.result,function (  )
        M.ExitGame()
    end)
end

function M.on_driver_ready_ok_msg(data)
    dump(data,"<color=yellow>on_driver_ready_ok_msg</color>")
    SendRequestAllInfo()
end

function M.on_pvp_all_info_req_response(data)
    dump(data,"<color=yellow>on_pvp_all_info_req_response</color>")
    if data.result and data.result ~= 0 then
        if data.result == -1 then
            local car_id = this.InitPram.car_id
            local game_id = this.InitPram.game_id
            DriveModel.SendRequest("pvp_signup",{id = game_id,car_id = car_id})
            return
        end

        HintPanel.ErrorMsg(data.result,function (  )
            M.ExitGame()
        end)
        return
    end

    if data.start_data and next(data.start_data) and data.process_data and next(data.process_data) then
        --刷新
        Event.Brocast("logic_pvp_all_info_req_response",data)
        local new_data = {
            process_data = data.process_data,
            end_data = data.end_data,
            status_no = data.status_no
        }
        --回放
        Event.Brocast("drive_game_process_data_msg","drive_game_process_data_msg",new_data)
        --加速
        set_time_scale(speed_up,0,0)
    else
        --刷新
        Event.Brocast("logic_pvp_all_info_req_response",data)
    end
end

function M.on_pvp_quit_game_response()
    M.ExitGame()
end

function M.on_drive_game_process_data_msg()
    local process_time = DriveLogicProcess.on_drive_game_process_data_msg()

    dump(process_time,"<color=yellow>客户端的表现时间process_all_time</color>")
    DriveModel.SendRequest("drive_set_movie_time",{time = process_time})
end

function M.on_drive_game_process_data_msg_begin()
    print("<color=yellow>on_drive_game_process_data_msg_begin</color>")
    DriveModel.SetPlayProcess(true)
    --需要玩家操作消息
    for k,v in pairs(DriveModel.data.players_info) do
        v.player_op = nil
    end
    --玩家操作信息
    for k,v in pairs(DriveModel.data.players_info) do
        v.player_action = nil
    end
end

function M.on_drive_game_process_data_msg_running(data)
    -- print("<color=yellow>on_drive_game_process_data_msg_running</color>")
end

function M.on_drive_game_process_data_msg_end()
    print("<color=yellow>on_drive_game_process_data_msg_end</color>")
    --当前队列数据处理完毕，刷新到当前状态
    DriveModel.Refresh()
    Event.Brocast("logic_round_end")

    --恢复网络缓存数据
    if DriveModel.NetworkDataCacheRecover() then return end

    DriveModel.SetPlayProcess(false)
    --发送回合结束消息到服务器，进行状态切换
    print("<color=purple>发送回合结束消息到服务器，进行状态切换</color>")
    DriveModel.SendRequest("drive_finish_movie") --回合结束消息

    if DriveModel.data.game_status == DriveModel.GameStatus.game_over then
        local _data = {
            status = DriveModel.GameStatus.game_over,
        }
        Event.Brocast("logic_pvp_game_over_msg",_data)
    end
end

return M