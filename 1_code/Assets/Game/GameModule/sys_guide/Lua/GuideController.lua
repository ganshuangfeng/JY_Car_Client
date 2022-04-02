local basefunc = require "Game/Common/basefunc"
GuideController = {}
local M = GuideController
M.key = "sys_guide"

GameModuleManager.ExtLoadLua(M.key,"GuideFunction")
GameModuleManager.ExtLoadLua(M.key,"GuideHelper")
GameModuleManager.ExtLoadLua(M.key,"GuideModel")
GameModuleManager.ExtLoadLua(M.key,"GuideView")

local listener

local function AddListener()
    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if not listener then return end
    for msg,cbk in pairs(listener) do
        Event.RemoveListener(msg, cbk)
    end
    listener=nil
end

local function MakeListener()
    listener = {}
    listener["goto_scene_server"] = M.on_goto_scene_server
    listener["car_move_end"] = M.on_car_move_end
    listener["model_driver_game_settlement_msg"] = M.on_model_driver_game_settlement_msg
    listener["drive_game_process_data_msg_next"] = M.on_drive_game_process_data_msg_next
    listener["guide_step_trigger"] = M.on_guide_step_trigger
    listener["guide_step_complete"] = M.on_guide_step_complete
    listener["model_guide_step"] = M.on_model_guide_step
    listener["login_complete"] = M.on_login_complete
    listener["ExitScene"] = M.OnExitScene
    listener["EnterScene"] = M.OnEnterScene
end

-- 是否激活
function M.IsActive()
    -- 开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameModuleManager.RunFun({_goto="sys_permission", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
    end

    return true
end

-- 所有可以外部创建的UI
function M.Goto(parm)
    
end

function M.Init()
	M.Exit()
	MakeListener()
    AddListener()
    GuideModel.Init()
end

function M.Exit()
	RemoveLister()
end

function M.on_model_guide_step()
    dump(debug.traceback(),"<color=white>新手引导执行步骤 数据刷新</color>")
    M.RunGuideStep()
end

function M.on_login_complete()
    GuideModel.get_xsyd_pos()
    dump(debug.traceback(),"<color=white>新手引导执行步骤 登录完成</color>")
    -- M.RunGuideStep()
end

function M.OnExitScene()
    dump(debug.traceback(),"<color=yellow>新手引导执行步骤 退出场景？？xx</color>")
    GuideView.Close()
end

function M.OnEnterScene()
    dump(debug.traceback(),"<color=white>新手引导执行步骤 进入场景</color>")
    M.RunGuideStep({run_type = "enter_scene"})
end

local cur_step = ""
--执行每一步引导
function M.RunGuideStep(data)
    dump(debug.traceback(),"<color=white>新手引导执行步骤</color>")
    if not GuideModel.CheckGuideIsStart() then
        dump(debug.traceback(),"<color=white>引导未开始</color>")
        --引导未开始
        return
    end
    --引导完成直接退出
    if GuideModel.CheckGuideIsEnd() then
        dump(debug.traceback(),"<color=white>引导已完成</color>")
        M.Exit()
        return
    end

    local step = GuideModel.GetStep()
    dump(step,"<color=white>当前新手引导步骤</color>")
    step = step or ""
    if cur_step == step then
        print("<color=red>正在执行当前步骤</color>")
        return
    end
    local func_name = "run_step_" .. step
    local is_run
    if GuideFunction and GuideFunction[func_name] and type(GuideFunction[func_name]) == "function" then
        is_run = GuideFunction[func_name](data)
        if is_run then
            cur_step = step
        end
    else
        dump(debug.traceback(),"<color=red>默认下一步操作</color>")
        cur_step = step
        M.ChangeGuideStep()
        M.RunGuideStep()
    end
end

function M.ChangeGuideStep()
    GuideView.Close()
    if not GuideModel.CheckGuideIsStart() then
        --引导未开始
        return
    end
    --引导完成直接退出
    if GuideModel.CheckGuideIsEnd() then
        M.Exit()
        return
    end

    local step = GuideModel.GetStep()
    dump(step,"<color=white>当前新手引导步骤检查</color>")
    step = step or ""

    if cur_step ~= step then
        print("<color=red>当前步骤未执行</color>")
        return
    end

    local func_name = "check_end_step_" .. step
    local is_end
    local callback
    if GuideFunction and GuideFunction[func_name] and type(GuideFunction[func_name]) == "function" then
        is_end,callback = GuideFunction[func_name]()
    else
        is_end = true
    end

    dump(is_end,"<color=white>新手引导步骤是否完成</color>")

    if not is_end then return end
    GuideModel.SetStepNext()
    if callback then
        callback()
    end
    -- --执行下一步
    -- M.RunGuideStep()
end

function M.on_guide_step_complete()
    dump(debug.traceback(),"<color=white>新手引导步骤完成 on_guide_step_complete</color>")
    M.ChangeGuideStep()
end

function M.on_guide_step_trigger(data)
    M.RunGuideStep(data)
end

function M.on_drive_game_process_data_msg_next(data)
    if not data then return end
    if data.index == 3 and data.key == "road_award_change" then
        dump(data,"<color=green>游戏过程中的数据？？？？？？</color>")
        local step = GuideModel.GetStep()
        dump(step,"<color=green>游戏过程中的数据step？？？？？？</color>")
        if step ~= 9 then return end
        M.RunGuideStep(data)
    end
end

function M.on_car_move_end(data)
    if not data then return end
    dump(data,"<color=green>移动结束</color>")
    -- M.RunGuideStep(data)
    if data.car_data.seat_num == 1 then
        local step = GuideModel.GetStep()
        if step ~= 9 then return end
        M.RunGuideStep(data)
    end
end

function M.on_model_driver_game_settlement_msg(data)
    if not data then return end
    dump(data,"<color=green>结算</color>")
    local step = GuideModel.GetStep()
    dump(step,"<color=green>结算step</color>")
    if step ~= 10 then return end
    M.RunGuideStep(data)
end

function M.on_goto_scene_server(parm)
    --提示恢复到比赛场
    if not parm or not next(parm) or not parm.game_id or parm.game_id ~= -1 then return end
    local hint_panel = GameObject.Find("HintPanel")
    if IsEquals(hint_panel) then
        local go = hint_panel.transform:Find("@center/@close_btn")
        go.gameObject:SetActive(false)
        go = hint_panel.transform:Find("@center/scrolltext/Viewport/Content/@msg_txt")
        local txt = go.transform:GetComponent("Text")
        if not IsEquals(txt) then
            txt = go.transform:GetComponent("TMP_Text")
        end
        txt.text = "点击确定按钮继续新手引导"
    end
end