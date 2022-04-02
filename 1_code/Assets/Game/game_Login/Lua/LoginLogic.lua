LoginLogic = {}
local M = LoginLogic

package.loaded["Game.game_Login.Lua.LoginModel"] = nil
require "Game.game_Login.Lua.LoginModel"

package.loaded["Game.game_Login.Lua.LoginPanel"] = nil
require "Game.game_Login.Lua.LoginPanel"

package.loaded["Game.game_Login.Lua.ClauseHintPanel"] = nil
require "Game.game_Login.Lua.ClauseHintPanel"

local this  -- 单例
local loginModel
local listener
local function AddListener()
    listener = {}
    for msg, cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg, cbk in pairs(listener) do
        Event.RemoveListener(msg, cbk)
    end
    listener = nil
end

function M.Init()
    M.Exit()
    this = M
    AddListener()
    LoginModel.Init()
    LoginPanel.Create()
    LoginHelper.AutoLogin()
    AudioManager.PlaySceneBGM(audio_config.game.com_main_map_denglu.audio_name)
    return this
end

function M.Exit()
    dump(M,"<color=red>登录进入场景</color>")
    if this then
        RemoveLister()
        LoginModel.Exit()
        LoginPanel.Exit()
        this = nil
    end
end

return M