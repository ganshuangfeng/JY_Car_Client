-- 创建时间:2020-12-31

LoginYoukeSDK = {}

LoginYoukeSDK.login_data = {}

function LoginYoukeSDK.LoginSdkVerify()
    local login_data = LoginHelper.GetLoginData(LoginHelper.ChannelType.youke)
    if not login_data or not next(login_data) then
        login_data = LoginHelper.BuildLoginData(LoginHelper.ChannelType.youke)
    end
    LoginYoukeSDK.OnSucceed(login_data)
end

function LoginYoukeSDK.OnSucceed(login_data)
    LoginYoukeSDK.login_data = login_data
    dump(login_data,"<color=white>login_data??????</color>")
    Event.Brocast("login_sdk_verify_succeed",login_data)
end

function LoginYoukeSDK.OnFail(login_data)
    LoginYoukeSDK.login_data = {}
    Event.Brocast("login_sdk_verify_fail",login_data)
end