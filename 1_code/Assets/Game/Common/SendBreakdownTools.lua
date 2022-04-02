SendBreakdownTools = {}
local M = SendBreakdownTools

local openSendBreakdownInfo = true
local showSendBreakdownInfo = true
local last_errorinfo = {}
function SendBreakdownTools.SendBreakdownInfoToServer(errorInfo, stack)
    if openSendBreakdownInfo and errorInfo and stack then
        if last_errorinfo[errorInfo] then
            return
        end
        last_errorinfo[errorInfo] = true

        local base_msg = ""
        base_msg = base_msg .. "Version:" .. gameMgr:GetVersionNumber() .. "\n"
        base_msg = base_msg .. "Device:" .. gameRuntimePlatform .. "\n"
        base_msg = base_msg .. "Platform:" .. (gameMgr:getMarketPlatform() or "nil") .. "\n"
        base_msg = base_msg .. "Channel:" .. (gameMgr:getMarketChannel() or "nil") .. "\n"

        local error = base_msg .. errorInfo .. "  " .. stack
        if string.len(error) >= 64 * 1024 then
            error = string.sub(error, 1, 64 * 1000)
        end
        --发向服务器
        Network.SendRequest("client_breakdown_info", {error = error})
    end
    if showSendBreakdownInfo then
        local path
        if AppDefine.IsEDITOR() then
            path = Application.dataPath
        else
            path = AppDefine.LOCAL_DATA_PATH
        end
        File.WriteAllText(path .. "/last_login_channel.txt", "")
        local id = ""
        if MainModel and MainModel.UserInfo and MainModel.UserInfo.user_id then
            id = MainModel.UserInfo.user_id
        end
        if AppDefine.IsEDITOR() then
            --根据配置将error发向服务器
            HintPanel.Create({show_yes_btn = true,msg = id .. "<size=15>发生崩溃，点击确定自动通知开发人员" .. errorInfo .. "</size>"})
        else
            --根据配置将error发向服务器
            HintPanel.Create({show_yes_btn = true,msg =  id .. "发生崩溃，点击确定自动通知开发人员"})
        end
    end
end
