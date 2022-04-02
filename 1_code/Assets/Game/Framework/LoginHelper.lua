--by:甘双丰 处理登录流程
require "Game.game_Login.Lua.LoginYoukeSDK"
require "Game.game_Login.Lua.LoginWechatSDK"

local basefunc = require "Game.Common.basefunc"
LoginHelper = {}
local M = LoginHelper
-- 大版本URL配置
local update_download_config = require "Game.game_Login.Lua.update_download_config"
local m_login_data --登录数据
local logined --登录过
local instance_id --服务器实例
local channel_type_key = "channel_type_key" --当前渠道类型

--登录渠道类型
M.ChannelType = {
    youke = "youke",
    wechat = "wechat"
}

--登录渠道sdk
M.ChannelSdk = {
    youke = LoginYoukeSDK,
    wechat = LoginWechatSDK,
}

--登录ip相关>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local IP_KEY = "sever_ip"
local ip_list = {}
local ip_login --登录ip

local ip_check = function(ip)
    if not ip_list or not next(ip_list) then return end
    for i,v in ipairs(ip_list) do
        if v == ip then
            return true
        end        
    end    
end

local ip_set_login_ip = function(ip)
    dump(ip,"<color=white>ip</color>")
    if not ip then return end
    ip_login = ip
    AppConst.SocketAddress = ip_login
end

local ip_setup = function()
    ip_list = {}
    local serverList = gameMgr:getServerList()
    if serverList and serverList.Length > 0 then
        for i = 0, serverList.Length - 1, 1 do
            table.insert(ip_list, serverList[i])
        end
    end

    if PlayerPrefs.HasKey(IP_KEY) then
        local ip = PlayerPrefs.GetString(IP_KEY, "")
        if ip and ip ~= "" then
            if ip_check(ip) then
                ip_set_login_ip(ip)
                return
            end
        end
    end

    dump(ip_list,"<color=white>ip_list</color>")

    --默认使用第一个ip
    ip_set_login_ip(ip_list[1])
end

function M.ip_change(ip)
    if not ip or type(ip) ~= "string" then return end
    if not ip_check(ip) then
        table.insert(ip_list,1,ip)
    end
    ip_set_login_ip(ip_list[1])
end

function M.ip_save(ip)
    print("save sever ip:", ip)
    if not ip then ip = ip_login end
    if not ip or ip == "" then return end
    PlayerPrefs.SetString(IP_KEY, ip_login)
end

function M.ip_delete()
    PlayerPrefs.DeleteKey(IP_KEY)
end

--登录相关>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local login_get_save_path = function()
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath
    else
        path = AppDefine.LOCAL_DATA_PATH
    end
    return path
end
--[[
    channel_type 0:string # 渠道类型： phone, weixin_gz , weixin,youke
    device_os 5: string # （可选）设备的操作系统
    device_id 6: string # （可选）设备的 id
    market_channel 7:string # 推广渠道
    platform 8:string # 平台（不同的账号系统）
]]
local login_build_login_data = function(channel_type)
    local deivesInfo = Util.getDeviceInfo()
    local login_data = {
        channel_type = channel_type,
        device_id = deivesInfo[0],
        device_os = deivesInfo[1],
        market_channel = gameMgr:getMarketChannel(),
        platform = gameMgr:getMarketPlatform(),
    }
    if gameRuntimePlatform == "Android" or gameRuntimePlatform == "IOS" then
        login_data.device_id = sdkMgr:GetDeviceID()
    end
    dump(login_data,"<color=white>build login_data</color>")
    return login_data
end

local login_get_local_data = function(channel_type)
    local path = login_get_save_path(channel_type)
    local data = load_json2lua(channel_type,path)
    return data
end

local login_set_local_data = function(channel_type,data)
    local path = login_get_save_path(channel_type)
    save_lua2json(data,channel_type,path)
    return data
end

--登录成功
local login_succeed = function(data)
    M.ip_save(ip_login)
    data.logined = logined
    Event.Brocast("login_succeed",data)
    
    --第一次登录成功保存登录数据 登录成功后的数据保存 login_id 等
    if not logined then
        m_login_data.login_id = data.login_id --登录成功返回用户 id （系统唯一 id）
        m_login_data.channel_type = data.channel_type or m_login_data.channel_type --渠道类型
        m_login_data.refresh_token = data.refresh_token or m_login_data.refresh_token --登录token
        m_login_data.market_channel = data.market_channel or m_login_data.market_channel --推广渠道
        login_set_local_data(m_login_data.channel_type,m_login_data)
        
        --最后一次成功登录方式保存
        UnityEngine.PlayerPrefs.SetString(channel_type_key, m_login_data.channel_type)
    end

    logined = true
    Event.Brocast("dbss_send_power",{key = "login_succes"})
end

--登录失败
local login_fail = function(data)
    M.ip_delete()
    Network.DestroyConnect()
    NetwordWaitScene.RemoveAll()
    HintPanel.ErrorMsg(data.result)
    Event.Brocast("login_fail",data)
    Event.Brocast("dbss_send_power",{key = "login_fail"})
end

--检查服务器状态
local login_check_sever_status = function()
    local serverStatus = gameMgr:getServerStatus() or ""
    print("serverStatus: ")
    if serverStatus == "" then
        return true
    end

    local result = false
    local segs = basefunc.string.split(serverStatus, "#")
    local text = ""
    if #segs ~= 2 then
        text = serverStatus
    else
        text = segs[2]
        if string.lower(segs[1]) == "on" then
            result = true
        end
    end

    if not result then
        --服务器状态异常，不能登录
        HintPanel.Create({show_yes_btn = true,msg =  text})
    end
    print("serverStatus result :",result)
    return result
end

--检查服务器实例 服务器运行实例 id，客户端据此判断是否需要重启 走更新流程
local login_check_sever_instance = function(data)
    if instance_id ~= nil and instance_id ~= data.instance_id then
        HintPanel.Create({show_yes_btn = true,msg = "服务器更新完毕，请重启游戏",
        yes_callback = function()
                gameMgr:QuitAll()
            end
        })
    end
    instance_id = data.instance_id
    return true
end

--登录sdk验证
local login_sdk_verify = function(channel_type)
    M.ChannelSdk[channel_type].LoginSdkVerify()
end

--获取版本url
function M.get_update_download_url(channel, platform)
    channel = channel or gameMgr:getMarketChannel()
    platform = platform or gameMgr:getMarketPlatform()

    local cfg = update_download_config
    if cfg then
        if cfg.info and cfg.info[channel] then
            local url
            if gameRuntimePlatform == "IOS" then
                url = cfg.info[channel].ios_url
            else
                url = cfg.info[channel].url
            end
            if url then
                return url
            end
        end

        if cfg.platform_info and cfg.platform_info[platform] then
            local url
            if gameRuntimePlatform == "IOS" then
                url = cfg.platform_info[platform].ios_url
            else
                url = cfg.platform_info[platform].url
            end
            if url then
                return url
            end
        end
    end
    if gameRuntimePlatform == "IOS" then
        return cfg.info.normal.ios_url
    else
        return cfg.info.normal.url
    end
end

--登录检查，是否需要重新安装，是否需要更新，是否需要重启
local login_check = function()
    --需要强制更新大版本
    if gameMgr:ReinstallApp() then
        print("Has Reinstall App need restart ....")
        Directory.Delete(resMgr.DataPath, true)
        HintPanel.Create({show_yes_btn = true,msg =  "下载最新版本，全新体验升级", yes_callback = function()
            local url = M.get_update_download_url()
            url = url or "www.baidu.com"
            UnityEngine.Application.OpenURL(url)

            if Directory.Exists(resMgr.DataPath) then
                Directory.Delete(resMgr.DataPath, true)
            end
            gameMgr:QuitAll()
        end})
        return
	end

    --需要有更新且重启
    if gameMgr:HasUpdated() and gameMgr:NeedRestart() then
		print("Has Update need restart ....")
		HintPanel.Create({show_yes_btn = true,msg =  "更新完毕，请重启游戏", yes_callback = function ()
			gameMgr:QuitAll()
		end})
		return
	end

    return true
end

--发起登录
local login_by_channel_type = function(channel_type)
    if not login_check() then return end

    if not login_check_sever_status() then return end

    --sdk开始验证
    login_sdk_verify(channel_type)
end

--登录渠道检查
local login_check_channel_type = function(channel_type)
    if not channel_type or channel_type == "" then
        --最后没有登录过不进行自动登录
        return
    end

    if not M.ChannelType[channel_type] then
        --没有对应渠道
        dump(M.ChannelType,"<color=white>当前所有登录的渠道类型</color>")
        return
    end

    return true
end

--服务器连接后登录
local server_connecte_succeed = function()
    print("<color=yellow>连接服务器成功，开始登录</color>")
    dump(m_login_data,"<color=white>登录数据</color>")
    if not m_login_data then
        return
    end
    Network.SendRequest("login",m_login_data)
end

--登录结果验证
local login_response = function(proto_name,data)
    dump(data,"<color=white>登录数据</color>")
    if data.result ~= 0 then
        login_fail(data)
        return
    end

    dump(login_check_sever_instance(data),"<color=white>登录数据</color>")
    --服务器实例不同需要重新登录
    if not login_check_sever_instance(data) then
        return
    end

    login_succeed(data)
end

--登录sdk验证成功，可以开始登录
local login_sdk_verify_succeed = function(login_data)
    if not login_data or not next(login_data) then
        dump(login_data,"<color=red>login_data : </color>")
        return
    end

    --保存登录数据 SDK验证成功的数据保存 appid,refresh_token 等
    m_login_data = login_set_local_data(login_data.channel_type,login_data)

    if not Network.CheckConnect() then
        --连上服务器后登录
        Network.SendConnect()
        return
    end

    --发起登录
    Network.SendRequest("login",login_data)
end

--登录sdk验证失败
local login_sdk_verify_fail = function(login_data)
    NetwordWaitScene.RemoveAll()

    if not login_data or not next(login_data) then
        dump(login_data,"<color=red>login_data : </color>")
        return
    end

    --保存登录数据 SDK验证失败的数据重置 appid,refresh_token 等
    m_login_data = login_set_local_data(login_data.channel_type,login_data)
end

--玩家登出
local player_quit_response = function(proto_name, data)
    dump(data,"<color=red>player_quit_response : </color>")
    if data and data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
        return
    end
    logined = false
    instance_id = nil
    PlayerPrefs.DeleteKey(channel_type_key)
    Event.Brocast("player_quit_succeed")
end

--玩家被踢下线
local will_kick_reason = function(proto_name, data)
    dump(data,"<color=red>will_kick_reason</color>")
    if data.reason == "logout" then
        --由于后台很久了，服务器已经把代理杀了 将会自动重连登陆
        print("<color=red> server wait over time  </color>")
        logined = false
        instance_id = nil
        PlayerPrefs.DeleteKey(channel_type_key)
        Event.Brocast("player_quit_succeed")
    elseif data.reason == "relogin" then
        --有人用我的login_id在其他地方登陆
        logined = false
        instance_id = nil
        PlayerPrefs.DeleteKey(channel_type_key)
        Event.Brocast("will_kick_reason_relogin")
    else
        print("<color=red> error </color>")
    end
end

local this  -- 单例
local listener
local AddListener = function()
    listener = {}
    listener["login_sdk_verify_succeed"] = login_sdk_verify_succeed
    listener["login_sdk_verify_fail"] = login_sdk_verify_fail
    listener["login_response"] = login_response
    listener["server_connecte_succeed"] = server_connecte_succeed

    listener["will_kick_reason"] = will_kick_reason
    listener["player_quit_response"] = player_quit_response

    for msg, cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local RemoveLister = function()
    for msg, cbk in pairs(listener) do
        Event.RemoveListener(msg, cbk)
    end
    listener = nil
end

function M.Init()
    M.Exit()
    this = M
    AddListener()

    ip_setup()

    return this
end

function M.Exit()
    if this then
        RemoveLister()
        this = nil
    end
end

function M.AutoLogin()
    local channel_type = UnityEngine.PlayerPrefs.GetString(channel_type_key,"")
    dump(channel_type,"<color=white>最后登录的渠道类型</color>")

    if not login_check_channel_type(channel_type) then
        return
    end

    if channel_type == M.ChannelType.youke then
        --游客不自动登录
        return
    end

    --登录
    login_by_channel_type(channel_type)
    return true
end

function M.Login(channel_type)
    dump(channel_type,"<color=white>登录的渠道类型</color>")
    if not login_check_channel_type(channel_type) then
        return
    end

    --登录
    login_by_channel_type(channel_type)
    return true
end

function M.Logout()
    Network.SendRequest("player_quit")
end

function M.ClearLogin(channel_type)
    if not login_check_channel_type(channel_type) then
        return
    end
    m_login_data = {}
    login_set_local_data(channel_type,m_login_data)
end

function M.SaveLoginData(channel_type)
    return login_set_local_data(channel_type,m_login_data)
end

function M.GetLoginData(channel_type)
    return login_get_local_data(channel_type)
end

function M.BuildLoginData(channel_type)
    return login_build_login_data(channel_type)
end

M.Init()