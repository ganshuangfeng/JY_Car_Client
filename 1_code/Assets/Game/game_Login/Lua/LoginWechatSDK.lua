-- 创建时间:2020-12-31

LoginWechatSDK = {}
LoginWechatSDK.login_data = {}

local function wechatTokenToLogin(login_data)
    local function callback(json_data)
        local verify_data = json2lua(json_data)
        dump(verify_data, "[LOGIN] wechatTokenToLogin verify_data:")
        if not verify_data or verify_data.result ~= 0 then
            LoginWechatSDK.OnFail(login_data,verify_data)
            return
        end

        LoginWechatSDK.OnSucceed(login_data,verify_data)
    end

    print("<color=white>sdkMgr login</color>")
    sdkMgr:Login("", callback)
end

function LoginWechatSDK.LoginSdkVerify()
    local login_data = LoginHelper.GetLoginData(LoginHelper.ChannelType.wechat)
    if not login_data or not next(login_data) then
        login_data = LoginHelper.BuildLoginData(LoginHelper.ChannelType.wechat)
    end
    if login_data.login_id and login_data.appid and login_data.refresh_token then
        local tbl = {}
        tbl.appid = login_data.appid
        tbl.refresh_token = login_data.refresh_token
        login_data.channel_args = lua2json(tbl)

        LoginWechatSDK.OnSucceed(login_data)
    else
        wechatTokenToLogin(login_data)
    end
end

--验证成功
function LoginWechatSDK.OnSucceed(login_data,verify_data)
    login_data.appid = verify_data.appid
    login_data.refresh_token = verify_data.refresh_token
    login_data.channel_args = lua2json(verify_data)
    LoginWechatSDK.login_data = login_data
    Event.Brocast("login_sdk_verify_succeed",login_data)
    Event.Brocast("dbss_send_power",{key = "login_wechat"})
end

--验证失败
function LoginWechatSDK.OnFail(login_data,verify_data)
    if verify_data.result == -5 then
        HintPanel.Create({show_yes_btn = true,msg =  "登陆微信错误(" .. login_data.channel_type .. ":" .. verify_data.errno .. ")"})
    elseif verify_data.result == -4 then
        HintPanel.ErrorMsg(3032)
    elseif verify_data.result == -2 then
        HintPanel.ErrorMsg(3031)
    elseif verify_data.result == -3 then
        HintPanel.ErrorMsg(3033)
    else
        HintPanel.ErrorMsg(verify_data.result)
    end

    login_data.appid = verify_data.appid
    login_data.refresh_token = nil --验证失败需要重新获取 refresh_token
    login_data.channel_args = nil
    LoginWechatSDK.login_data = login_data
    Event.Brocast("login_sdk_verify_fail",login_data)
end