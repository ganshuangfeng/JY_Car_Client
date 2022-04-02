basefunc =  require "Game.Common.basefunc"
--Framework >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
require "Game.Common.define"
require "Game.Common.printfunc"

require "Game.Framework.events"
require "Game.Framework.Network"
require "Game.Framework.NetworkImageManager"
require "Game.Framework.GameManager"
require "Game.Framework.LoadHelper"
require "Game.Framework.SceneHelper"
require "Game.Framework.LoginHelper"
require "Game.Framework.MainModel"

--Common >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--工具类
util = require "Game.Common.3rd.cjson.util"
require "Game.Common.3rd.cjson.json2lua"
require "Game.Common.3rd.cjson.lua2json"
require "Game.Common.cardID_vertify"
require "Game.Common.ewmTools"
require "Game.Common.tools"
require "Game.Common.functions"
require "Game.Common.Vector2D"
require "Game.Common.StringHelper"
require "Game.Common.MathExtend"
require "Game.Common.GMTools"
require "Game.Common.LoginTool"
require "Game.Common.SendBreakdownTools"
require "Game.Common.DeepLinkHelper"
require "Game.Common.DataBSSystem" --数据埋点系统

--枚举类
require "Game.Common.normal_enum"
errorCode = require "Game.Common.error_code"

--管理器
require "Game.Common.AudioManager"
require "Game.Common.SpineManager"
require "Game.Common.DOTweenManager"
require "Game.Common.DoTweenSequence"
require "Game.Common.TimerManager"
require "Game.Common.CachePrefabManager"

--系统类
require "Game.Common.ADRewardMgr"
require "Game.Common.ADManager" --广告系统

require "Game.GameCommon.Lua.Enum"
require "Game.GameCommon.Lua.GameModuleManager"
require "Game.GameCommon.Lua.GameEnterManager"
require "Game.GameModule.sys_permission.Lua.PermissionManager"

--GameCommon >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
require "Game.GameCommon.Lua.GameGlobalOnOff"
ext_require_audio("Game.GameCommon.Lua.audio_game_config","game")
-- 组件
require "Game.GameCommon.Lua.NetwordWaitScene"
require "Game.GameCommon.Lua.NetwordWaitNode"
require "Game.GameCommon.Lua.TipsShowUpText"
require "Game.GameCommon.Lua.HintPanel"

require "Game.GameCommon.Lua.HotUpdatePanel"
require "Game.GameCommon.Lua.HotUpdateSmallPanel"

require "Game.GameCommon.Lua.ComFlyAnim"
require "Game.GameCommon.Lua.ComShowTips"


MainLogic = {}
local M = MainLogic

local hasInitAppPurchasing = false

local listener
local function AddListener()
    listener={}
    --网络状态
    listener["ServerConnecteSucceed"] = M.OnServerConnecteSucceed
    listener["ServerConnecteFail"] = M.OnServerConnecteFail
    listener["ServerDisconnect"] = M.OnServerDisconnect
    
    --登录状态
    listener["login_succeed"] = M.login_succeed
    listener["login_fail"] = M.login_fail
    listener["player_quit_succeed"] = M.player_quit_succeed
    listener["will_kick_reason_relogin"] = M.will_kick_reason_relogin
    --场景切换
    listener["scene_enter"] = M.scene_enter
    listener["scene_exit"] = M.scene_exit
    
    listener["deeplink_notify_msg"] = M.deeplink_notify_msg

    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(listener) do
        Event.RemoveListener(msg, cbk)
    end
    listener=nil
end


function M.Init()
    M.ShowFPS()
    M.SetDebugLog()
    M.BBSSSendStartFirst()
    M.BBSSSendFirstInit()
    MainModel.Init()
    Network.Init()
    NetworkImageManager.Init()
    DOTweenManager.Init()
    AudioManager.Init()
    TimerManager.Init()
    GameModuleManager.Init()
    PermissionManager.Init()
    ADManager.Init()
    AddListener()    

    --前往登录
    GameManager.Goto({_goto = "game_Login"})
end

function M.Exit()
    Network.Exit()
    RemoveLister()
    MainModel.Exit()
end

--服务器重连成功
function M.OnServerConnecteSucceed()
    --由LoginHelper登录
    Event.Brocast("server_connecte_succeed")
end

--服务器连接失败
function M.OnServerConnecteFail()
    Event.Brocast("server_connecte_fail")
    HintPanel.Create({show_yes_btn = true,msg = "您连接服务器失败，需要重新登录",yes_callback = function ()
        GameManager.Goto({_goto = "game_Login"})
    end})
end

--服务器断开
function M.OnServerDisconnect()
    Event.Brocast("server_disconnecte")
end

--登录成功
function M.login_succeed(data)
    dump(data,"<color=white>data</color>")
    MainModel.InitPlayerData(data)
    SceneHelper.SetLocationServer(data.location)
    SceneHelper.SetGameIDServer(data.game_id)
    GMTools.AddGesture()
    GameModuleManager.InitConfig()

    local login_complete = function ()
        Event.Brocast("login_complete")
    end

    if not data.logined then
        if not GameManager.Goto({_goto = "game_Hall",backcall = login_complete}) then
            login_complete() 
        end
    else
        --断线重连登录完成
        --恢复到服务器场景
        -- SceneHelper.GotoSceneServer()
        if not SceneHelper.GotoSceneServer() then
            if not GameManager.Goto({_goto = "game_Hall",backcall = login_complete}) then
                login_complete() 
            end
        end
    end
end

--登录失败
function M.login_fail(data)
    MainModel.InitPlayerData(data)
    Event.Brocast("login_complete_fail")
end

--登出成功
function M.player_quit_succeed(data)
    GameManager.Goto({_goto = "game_Login"})
    M.Exit()
    M.Init()
end

--玩家被踢下线
function M.will_kick_reason_relogin(data)
    HintPanel.Create({show_yes_btn = true,msg = "您的账号已经在其他设备登陆",
        yes_callback = function()
            GameManager.Goto({_goto = "game_Login"})
            M.Exit()
            Network.Register()
            M.Init()
        end
    })
end

--进入一个游戏
function M.EnterGame()
   
end

--从一个游戏退出
function M.ExitGame()
    --清除当前服务器上的位置
    SceneHelper.SetLocationServer()
end

--进入了一个场景
function M.scene_enter()
    Event.Brocast("EnterScene")
end

--即将退出当前场景
function M.scene_exit()
    DOTweenManager.ClearAll()
    Event.Brocast("ExitScene")
end

--设计尺寸
M.ReferenceResolution = {
    x = 1080,
    y = 2340,
}

M.MatchWidthOrHeight = {
    height = 1, --高适配
    width = 0,  --宽适配
}

function M.SetCanvasScaler(canvas_scaler,x,y,force_width_or_height)
    canvas_scaler = canvas_scaler or GameObject.Find("Canvas").transform:GetComponent("CanvasScaler")
    if force_width_or_height then
        if canvas_scaler then
            canvas_scaler.matchWidthOrHeight = force_width_or_height
        else
            print("<color=red>适配策略 Error</color>")
        end
        return
    end

    x = x or M.ReferenceResolution.x
    y = y or M.ReferenceResolution.y

    if canvas_scaler then
        canvas_scaler.referenceResolution = {x = x,y = y}

        local width = Screen.width
        local height = Screen.height
        if width / height > 1 then
            width,height = height,width
        end
        canvas_scaler.matchWidthOrHeight = M.GetScene_MatchWidthOrHeight(width, height)
    else
        print("<color=red>适配策略 Error</color>")
    end
end

function M.GetScene_MatchWidthOrHeight(width, height)
    width = width or Screen.width
    height = height or Screen.height
    if width / height > 1 then
        width, height = height, width
    end
    local screen_w_h = width / height
    local rr_w_h = M.ReferenceResolution.x / M.ReferenceResolution.y
    if screen_w_h < rr_w_h then
        return M.MatchWidthOrHeight.height
    else
        return rr_w_h / screen_w_h--M.MatchWidthOrHeight.width
    end
end

-- 决定放弃宽适配后决定写个控制背景缩放的方法
function M.SetGameBGScale(bg)
    local width = Screen.width
    local height = Screen.height
    if width / height < 1 then
        width, height = height, width
    end
    local matchWidthOrHeight = M.GetScene_MatchWidthOrHeight(width, height)
    local scale
    if matchWidthOrHeight == 1 then
        scale = (width * M.ReferenceResolution.x) / (height * M.ReferenceResolution.y)
        if scale < 1 then
            scale = 1
        end
    else
        scale = (height * M.ReferenceResolution.y) / (width * M.ReferenceResolution.x)
        if scale < 1 then
            scale = 1
        end
    end
    if IsEquals(bg) then
        bg.transform.localScale = Vector3.New(scale, scale, 1)
    end
end


function M.deeplink_notify_msg(data)
	
end

--前台
function M.OnForeGround()
    Event.Brocast("EnterForeGround")

    DeepLinkHelper.OpenDeepLink()
end

--后台
function M.OnBackGround()
    Event.Brocast("EnterBackGround")
end

-- 时间函数重写
function M.OSTimeRewrite()
    local _client_server_time_diff = 0
    local _time_zone_diff = 946656000-os.time({year=2000,month=1,day=1,hour=0,min=0,sec=0})

    if not os.old_time then

        os.old_time = os.time
        os.old_date = os.date

        function os.time(_t)
            if _t then
                return os.old_time(_t) + _time_zone_diff
            else
                return os.old_time(_t) + _client_server_time_diff
            end
        end

        function os.date(_fmt,_time)
            _time = _time or os.time()
            return os.old_date(_fmt,_time - _time_zone_diff)
        end
    end

    local client2server_time = function (server_time)
        if os.old_time and server_time then
            _client_server_time_diff = tonumber(server_time) - os.old_time()
        end
    end
end

--设置息屏时间
function M.SetSleepTimeout()
    Screen.sleepTimeout = -1
end

function M.SetDebugLog()
    AppDefine.IsDebug = true
    if gameRuntimePlatform == "IOS" or gameRuntimePlatform == "Android" then
        AppDefine.IsDebug = false
    end
end

function M.ShowFPS()
    if true then return end
    AppDefine.IsDebug = true
    local GM = GameObject.Find("GameManager")
    if GM then
        local fps = GM:GetComponent("ShowFPS")
        local rd = GM:GetComponent("RuntimeDebug")
        if fps then
            fps.enabled = true
        end
        if rd then
            rd.enabled = true
        end
    end
end

--第一次启动
local FirstInit = true
function M.BBSSSendFirstInit()
    if not FirstInit then return end
    Event.Brocast("dbss_send_e")
    Event.Brocast("dbss_send_power",{key = "up_end"})
    FirstInit = false
end

function M.BBSSSendStartFirst()
    --第一次启动app
    local first_launch_game_key = "first_launch_game"
    if PlayerPrefs.GetInt(first_launch_game_key,0) == 0 then
        Event.Brocast("dbss_send_power",{key = "start_first"})
        PlayerPrefs.SetInt(first_launch_game_key,1)
    end
end