local basefunc = require "Game/Common/basefunc"
EquipmentController = {}
local M = EquipmentController
M.key = "sys_equipment"

GameModuleManager.ExtLoadLua(M.key,"EquipmentModel")
GameModuleManager.ExtLoadLua(M.key,"EquipmentView")
GameModuleManager.ExtLoadLua(M.key,"EquipmentDetailView")
GameModuleManager.ExtLoadLua(M.key,"EquipmentUpView")
GameModuleManager.ExtLoadLua(M.key,"EquipmentItem")
GameModuleManager.ExtLoadLua(M.key,"EquipmentExtItem")

local this
local listener

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
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

-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end

-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.Goto(parm)
    if parm.goto_parm == "view" then
        EquipmentUpView.Close()
        return EquipmentView.Create(parm)
    elseif parm.goto_parm == "detial" then
        EquipmentView.Close()
        return EquipmentDetailView.Create(parm)
    elseif parm.goto_parm == "up" then
        return EquipmentUpView.Create(parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

function M.on_global_hint_state_set_msg(parm)
	if parm._goto == M.key then
		M.SetHintState()
	end
end

-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { _goto = M.key })
end

local function AddListener()
    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if listener then
        for msg,cbk in pairs(listener) do
            Event.RemoveListener(msg, cbk)
        end
    end
    listener=nil
end

local function MakeListener()
    listener = {}
    listener["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    listener["login_complete"] = this.on_login_complete
    listener["hall_panel_change_view"] = this.on_hall_panel_change_view
    listener["client_cur_car_change"] = this.on_client_cur_car_change
end

function M.Init()
	M.Exit()
	this = EquipmentController
	this.m_data = {}
	MakeListener()
    AddListener()
    EquipmentModel.Init()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.on_login_complete()
    EquipmentModel.query_drive_all_equipment()
end

function M.on_hall_panel_change_view()
    EquipmentView.Close()
    EquipmentDetailView.Close()
    EquipmentUpView.Close()
end

function M.on_client_cur_car_change(data)
    if true then return end
    local cur_car = SysCarManager.GetCurCar()
    local cur_id = cur_car.id
    local equipment_data = EquipmentModel.GetCarEquiment()
    dump(equipment_data,"<color=white>客户端出战车改变</color>")
    local equipment_no = {}
    for k,v in pairs(equipment_data) do
        equipment_no[k] = k
    end

    local ed_list = {}
    for k,v in pairs(equipment_data) do
        ed_list[#ed_list+1] = k
    end

    local i = 1
    local get_ed = function()
        local t = {
            no = ed_list[i],
            car_id = data.car_id
        }
        i = i + 1
        return t
    end

    local deu 
    deu = function()
        Network.SendRequest("drive_equipment_unload",get_ed(),function()
            if i == #ed_list then
                return
            else
                deu()
            end
        end,true)
    end
    deu()


    local en_list = {}
    for k,v in pairs(equipment_no) do
        en_list[#en_list+1] = k
    end
    
    local i = 1
    local get_en = function()
        local t = {
            no = en_list[i],
            car_id = data.car_id
        }
        i = i + 1
        return t
    end

    local del 
    del = function()
        Network.SendRequest("drive_equipment_load",get_en(),function()
            if i == #en_list then
                return
            else
                del()
            end
        end,true)
    end
    del()
end