-- 创建时间:2021-05-26
-- SysCarUpgradeManager 管理器

local basefunc = require "Game/Common/basefunc"
SysCarUpgradeManager = {}
local M = SysCarUpgradeManager
M.key = "sys_car_upgrade"
GameModuleManager.ExtLoadLua(M.key,"SysCarUpgradePanel")
GameModuleManager.ExtLoadLua(M.key,"SysCarUpgradeTypeObj")
local drive_road_award_config = GameModuleManager.ExtLoadLua(M.key,"drive_road_award_config")
local drive_car_upgrade_config = GameModuleManager.ExtLoadLua(M.key,"drive_car_upgrade_config")
local drive_game_car_level_up_server = GameModuleManager.ExtLoadLua(M.key,"drive_game_car_level_up_server")
local this
local lister

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
        local a,b = GameModuleManager.RunFun({gotoui="sys_permission", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
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
    dump(parm,"parm")
    if parm.goto_parm == "view" then
        return SysCarUpgradePanel.Create(parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


local function AddListener()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["login_complete"] = this.on_login_complete
    --协议
    lister["query_drive_all_car_data_response"] = this.on_query_drive_all_car_data_response
    lister["drive_car_up_level_response"] = this.on_drive_car_up_level_response
    lister["drive_car_up_star_response"] = this.on_drive_car_up_star_response
    lister["query_drive_car_data_response"] = this.on_query_drive_car_data_response
    lister["on_drive_car_data_change"] = this.on_drive_car_data_change
end

function M.Init()
	M.Exit()

	this = SysCarUpgradeManager
	this.m_data = {}
	MakeLister()
    AddListener()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitUIConfig()
    this.car_upgrade_config = {}
    for k,v in ipairs(drive_car_upgrade_config.car_upgrade_config) do
        this.car_upgrade_config[v.car_id] = v
    end
    --类型配置
    this.car_upgrade_type_config = {}
    for k,v in ipairs(drive_car_upgrade_config.car_type_config) do
        this.car_upgrade_type_config[v.type_id] = v
    end
    --spendp配置
    this.car_upgrade_spend_config = drive_game_car_level_up_server.spend
    for k,v in ipairs(drive_game_car_level_up_server.main) do
        local cfg = this.car_upgrade_config[v.car_id]
        if cfg then
            local init_map_enum = {
                [1] = "star_rule",
                [2] = "level_spend_rule",
                [3] = "base_change_rule",
                [4] = "star_skill_change"
            }
            for _,enum_key in ipairs(init_map_enum) do
                if drive_game_car_level_up_server[enum_key] and v[enum_key] then
                    if enum_key == "star_rule" then
                        local star_rule_id = v[enum_key]
                        cfg[enum_key] = {}
                        for __,star_rule_data in ipairs(drive_game_car_level_up_server[enum_key]) do
                            if star_rule_data.id == star_rule_id then
                                cfg[enum_key][star_rule_data.star] = star_rule_data
                            end
                        end
                    elseif enum_key == "level_spend_rule" then
                        local level_spend_rule = {}
                        for __,level_spend_rule_data in ipairs(drive_game_car_level_up_server[enum_key]) do
                            if level_spend_rule_data.id == v[enum_key] then
                                level_spend_rule[level_spend_rule_data.level] = level_spend_rule_data
                            end
                        end 
                        cfg[enum_key] = level_spend_rule
                    else
                        cfg[enum_key] = drive_game_car_level_up_server[enum_key][v[enum_key]]
                    end
                end
            end
        else
            dump("<color=red>服务器表不存在配置，car_id = " .. v.car_id .. "</color>")
        end
    end
    --技能配置
    this.car_upgrade_skill_config = {}
    for k,v in ipairs(drive_car_upgrade_config.skill_type_config) do
        this.car_upgrade_skill_config[v.type_id] = v
    end
    this.drive_road_award_config = drive_road_award_config
    dump(this,"<color=yellow>SysCarUpgradeManager所有配置</color>")
end

function M.GetCarUpgradeData(car_id)
    --如果只有基础数据需要拉取所有数据
    if this.car_data and this.car_data[car_id] and this.car_data[car_id].is_all_data then
        return this.car_data[car_id]
    else
        Network.SendRequest("query_drive_car_data",{car_id = car_id})
        return
    end
end

function M.GetCarData(car_id)
    if this.car_data and this.car_data[car_id] then
        return this.car_data[car_id]
    else
        Network.SendRequest("query_drive_car_data",{car_id = car_id})
        return false
    end
end

function M.GetCarUpgradeCfg(car_id)
    return this.car_upgrade_config[car_id]
end

function M.GetStarUpSpend(car_data)
    local car_cfg = this.GetCarUpgradeCfg(car_data.base_data.car_id)
    local spend_data = {}
	if car_cfg.star_rule then
		if car_cfg.star_rule[car_data.base_data.star + 1] and car_cfg.star_rule[car_data.base_data.star + 1].spend then
			local spend_cfg = this.car_upgrade_spend_config[car_cfg.star_rule[car_data.base_data.star + 1].spend]
			for k,v in pairs(spend_cfg) do
                if k == "jing_bi" then
                    spend_data.jing_bi = {}
                    spend_data.jing_bi.need_value = v or 0
                    spend_data.jing_bi.cur_value = MainModel.UserInfo[k] or 0
                end
				if string.split(k,"_")[1] == "patch" then
                    spend_data[k] = {}
                    spend_data[k].need_value = v or 0
                    spend_data[k].cur_value = SysAssetModel.GetItemCount(k) or 0
				end
			end
		end
	end
    return spend_data
end

function M.GetLevelUpSpend(car_data)
    local car_cfg = this.GetCarUpgradeCfg(car_data.base_data.car_id)
    local spend_data = {}
    if car_cfg and car_cfg.level_spend_rule then
        local spend_cfg
        for k,v in pairs(car_cfg.level_spend_rule) do
            if car_data.base_data.level < tonumber(k) then
                spend_cfg = this.car_upgrade_spend_config[v.spend]
            end
        end
        if spend_cfg then
            for k,v in pairs(spend_cfg) do
                if k == "jing_bi" then
                    spend_data.jing_bi = {}
                    spend_data.jing_bi.need_value = 2
                    spend_data.jing_bi.cur_value = MainModel.UserInfo[k] or 0
                end
                if string.split(k,"_")[1] == "patch" then
                    spend_data[k] = {}
                    spend_data[k].need_value = v or 0
                    spend_data[k].cur_value = MainModel.UserInfo[k] or 0
                end
            end
        else
            return {jing_bi = 0}
        end
    end
    return spend_data
end

function M.GetUpgradeSkillCfg(type_id)
    for k,v in ipairs(this.drive_road_award_config.main) do
        if v.id == type_id then
            return v
        end
    end
end
----------------------服务器数据--------------------------------

function M.on_query_drive_all_car_data_response(_,data)
    dump(data,"<color=red>所有车辆数据</color>")
    if data.result == 0 then
        this.car_data = {}
        for k,v in ipairs(data.base_data) do
            this.car_data[v.car_id] = this.car_data[v.car_id] or {}
            this.car_data[v.car_id].base_data = v
        end
        if data.equipment_data then
            Event.Brocast("car_equipment_data",{equipment_data = data.equipment_data})
        end
        Event.Brocast("model_on_query_drive_all_car_data_response",data)
    else
        TipsShowUpText.Create(errorCode[data.result])
    end
end

function M.on_drive_car_up_level_response(_,data)
    dump(data,"<color=red>单个车辆升级数据</color>")
    if data.result == 0 then
        Event.Brocast("model_on_drive_car_up_level_response")
    else
        TipsShowUpText.Create(errorCode[data.result])
    end
end

function M.on_query_drive_car_data_response(_,data)
    dump(data,"<color=red>单个车辆升级数据</color>")
    if data.result == 0 then
        if not this.car_data then
            --尚未初始化数据
            -- TipsShowUpText.Create("尚未初始化数据")
            return
        end
        for k,v in pairs(data) do
            if k ~= "result" then
                this.car_data[data.base_data.car_id][k] = v
            end
        end
        this.car_data[data.base_data.car_id].is_all_data = true

        Event.Brocast("model_on_query_drive_car_data_response",{car_id = data.base_data.car_id})
    else
        TipsShowUpText.Create(errorCode[data.result])
    end
end

function M.on_login_complete(data)
    Network.SendRequest("query_drive_all_car_data")
end

function M.on_drive_car_data_change(_,data)
    dump(data,"<color=red>on_drive_car_data_change</color>")
    if data and next(data) then
        for k,v in pairs(data) do
            if k ~= "result" and k ~= "change_type" then
                this.car_data = this.car_data or {}
                this.car_data[data.base_data.car_id] = this.car_data[data.base_data.car_id] or {}
                this.car_data[data.base_data.car_id][k] = v
            end
        end
    end
    Event.Brocast("model_drive_car_data_change",data)
    Event.Brocast("model_on_drive_car_data_change",{car_id = data.base_data.car_id,change_type = data.change_type,car_data = this.car_data[data.base_data.car_id]})
end

function M.on_drive_car_up_star_response(_,data)
    dump(data,"<color=red>on_drive_car_up_star_response</color>")
    if data.result == 0 then
        Event.Brocast("model_on_drive_car_up_star_response")
    elseif data.result == 2253 then
        TipsShowUpText.Create("突破所需材料不足")
    else
        TipsShowUpText.Create(errorCode[data.result])
    end
end

---获取当前升级消耗，level:当前等级，spend_cfgs ：[level = spend_item]
function M.GetCurUpgradeSpend(cur_level,spend_cfgs)
    --[[
        spend_cfgs = {
            [1] = {
                jing_bi = 324,
                patch_falali = 10,
            },
            
            [70] = {
                jing_bi = 2,
            }
        }
    ]]
    local ret = {}
    local _sorted_cfg = {}
    for k,v in pairs(spend_cfgs) do
        v.level = tonumber(k)
        _sorted_cfg[#_sorted_cfg + 1] = v
    end
    table.sort(_sorted_cfg,function(a,b)
        return a.level < b.level
    end)
    for k,spend in pairs(_sorted_cfg) do
        local spend_level = spend.level
        for spend_item_key,spend_item_value in pairs(spend) do
            if spend_item_key ~= "id" and spend_item_key ~= "level" then
                ret[spend_item_key] = ret[spend_item_key] or 0
                if cur_level >= spend_level then
                --当前等级大于档位等级直接把该档位的全部等级的spend_value加起来
                    if _sorted_cfg[k - 1] and _sorted_cfg[k - 1][spend_item_key] then
                        ret[spend_item_key] = ret[spend_item_key] + spend_item_value * (spend_level - _sorted_cfg[k - 1].level)
                    else
                        ret[spend_item_key] = ret[spend_item_key] + spend_item_value * (spend_level)
                    end
                else
                --当前等级小于档位等级时，只计算该档位的上一档位比当前等级小的情况
                    if _sorted_cfg[k - 1] and _sorted_cfg[k - 1].level <= cur_level then
                        ret[spend_item_key] = ret[spend_item_key] + spend_item_value * (cur_level + 1 - _sorted_cfg[k - 1].level) 
                    elseif not _sorted_cfg[k - 1] then
                        ret[spend_item_key] = ret[spend_item_key] + spend_item_value * (cur_level + 1 - 0)
                    end
                end
            end 
        end
    end
    return ret
end