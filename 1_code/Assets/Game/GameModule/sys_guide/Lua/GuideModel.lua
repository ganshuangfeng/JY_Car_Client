local basefunc = require "Game.Common.basefunc"
GuideModel = {}
local M = GuideModel

GameModuleManager.ExtLoadLua(GuideController.key,"GuideConfig")
local step
local save_key = "guide"

local listener
local function MakeListener()
    listener = {}
    listener["get_xsyd_pos_response"] = M.on_get_xsyd_pos_response
    listener["set_xsyd_pos_response"] = M.on_set_xsyd_pos_response
    listener["on_xsyd_pos_change"] = M.on_xsyd_pos_change
end

local function AddListener()
    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveListener()
    if not listener then return end
    for msg,cbk in pairs(listener) do
        Event.RemoveListener(msg, cbk)
    end
    listener = nil
end

function M.Init()
    M.Exit()
    MakeListener()
    AddListener()
	M.m_data = {}
    M.InitConfig()
end

function M.Exit()
    RemoveListener()
end

function M.InitConfig()
    M.config = {}
    for k,v in pairs(GuideConfig) do
        M.config[v.step] = v
    end
end

function M.GetStep()
    if step then return step end
    step = UnityEngine.PlayerPrefs.GetInt(save_key .. MainModel.UserInfo.user_id,0)
    return step
end

function M.SetStep(cur_step)
    step = cur_step
    if not step then return end
    UnityEngine.PlayerPrefs.SetInt(save_key .. MainModel.UserInfo.user_id,step)
end

function M.SetStepNext()
    M.SetStep(step + 1)
    M.set_xsyd_pos()
end

function M.get_xsyd_pos()
    Network.SendRequest("get_xsyd_pos")
    -- Event.Brocast("get_xsyd_pos_response","get_xsyd_pos_response",{result = 0,pos = 11})  
end

function M.set_xsyd_pos()
    local data = {
        pos = step
    }
    Network.SendRequest("set_xsyd_pos",data)
end

function M.on_get_xsyd_pos_response(_,data)
    dump(data,"<color=green>on_get_xsyd_pos_response新手引导步骤</color>")
    if data.result ~= 0 then
        TipsShowUpText.Create(errorCode[data.result])
        return
    end
    if data.pos == 0 then data.pos = 1 end
    M.SetStep(data.pos)
    Event.Brocast("model_guide_step")
end

function M.on_set_xsyd_pos_response(_,data)
    dump(data,"<color=white>新手引导步骤</color>")
    if data.result ~= 0 then
        TipsShowUpText.Create(errorCode[data.result])
        return
    end
    -- M.SetStep(data.pos)
    -- Event.Brocast("model_guide_step")
end

function M.on_xsyd_pos_change(data)
    M.SetStep(data.guide_step)
    Event.Brocast("model_guide_step")
end

function M.CheckGuideIsStart()
    if not step then return false end
    return step ~= 0
end

function M.CheckGuideIsEnd()
    if not step then return true end
    return step > #M.config
end

function M.GetCurSetpCfg()
    return M.config[step]
end