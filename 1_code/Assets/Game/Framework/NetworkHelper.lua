NetworkHelper = {}
local M = NetworkHelper

local listener
local function AddListener()
    listener={}
    listener["network_connect"] = M.OnConnecte
    listener["network_exception"] = M.OnException
    listener["network_disconnect"] = M.OnDisconnect
    listener["network_sendrequest_exception"] = M.OnSendRequestException

    listener["EnterForeGround"] = M.OnEnterForeGround
    listener["EnterBackGround"] = M.OnEnterBackGround

    for msg, cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(listener) do
        Event.RemoveListener(msg, cbk)
    end
    listener = nil
end

-----------------------------------------心跳-------------------------------------------
local heartbeat_timer
local heartbeat_interval = 1
local heartbeat_lost_num = 0 --心跳丢失数量
local heartbeat_lost_num_max = 300
local heartbeat_lost_duration = 0 --心跳丢失时长
local heartbeat_lost_duration_max = 300
local heartbeat_stop
local heartbeat_start
local heartbeat

heartbeat = function (  )
    --正常的链接状态才进行心跳
    if not Network.CheckConnect() then return end

    heartbeat_lost_duration = heartbeat_lost_duration + heartbeat_interval
    heartbeat_lost_num = heartbeat_lost_num + 1

    Network.SendRequest("heartbeat",nil,function ()
        heartbeat_lost_num = 0
        heartbeat_lost_duration = 0
    end)

    if heartbeat_lost_num > heartbeat_lost_num_max or heartbeat_lost_duration > heartbeat_lost_duration_max then
        --丢失过多  触发网络异常
        Network.DestroyConnect()
        --停止心跳
        heartbeat_stop()
        print("<color=red>heartbeat exception</color>")
    end
end

heartbeat_stop = function (  )
    if heartbeat_timer then
        heartbeat_timer:Stop()
    end
    heartbeat_lost_num = 0
    heartbeat_lost_duration = 0
end

heartbeat_start = function(  )
    heartbeat_stop(  )
    heartbeat_timer = Timer.New(function (  )
        heartbeat()
    end, heartbeat_interval, -1, nil, true)
    heartbeat_timer:Start()
end

-----------------------------------------重连-------------------------------------------
local connect_server_timer
local connect_server_interval = 3
local connect_server_num = 0 --连接服务器次数
local connect_server_num_max = 16 --最多尝试16次连接

local connect_server_stop
local connect_server_start
local connect_server

connect_server_stop = function (  )
    if connect_server_timer then
        connect_server_timer:Stop()
    end
    connect_server_num = 0
end

connect_server_start = function (  )
    connect_server_stop()
    connect_server_timer = Timer.New(function (  )
        connect_server()
    end, connect_server_interval, -1, nil, true)
    connect_server_timer:Start()

    --立即发起一次重连
    connect_server()
end

connect_server = function (  )
    --连接已经成功
    if Network.CheckConnect() then return end

    --发起一次重连
    Network:SendConnect()
    connect_server_num = connect_server_num + 1

    if connect_server_num > connect_server_num_max then
        --多次连接失败 不再继续连接，跳转到登陆场景
        connect_server_stop()
        Event.Brocast("ServerConnecteFail")
        print("<color=red>connect_server exception</color>")
    end
end

--服务器连接异常
function M.OnException()
    TipsShowUpText.Create("服务器连接异常")
    --停止心跳
    heartbeat_stop()
    Event.Brocast("ServerDisconnect")
end

--服务器连接断开
function M.OnDisconnect()
    TipsShowUpText.Create("服务器连接断开")
    --停止心跳
    heartbeat_stop()
    Event.Brocast("ServerDisconnect")
end

--服务器重连成功
function M.OnConnecte()
    --开始心跳
    heartbeat_start()
    connect_server_stop()
    print("<color=yellow>服务器重连成功</color>")
    Event.Brocast("ServerConnecteSucceed")
end

function M.OnSendRequestException(data)
    --忽略心跳请求
    if data.name and (data.name == "heartbeat" or data.name == "client_breakdown_info") then return end
    --重连服务器
    connect_server_start()
end

function M.OnEnterForeGround()
    if Network.CheckConnect() then return end
    --重连服务器
    connect_server_start()
end

function M.OnEnterBackGround()
    
end

AddListener()