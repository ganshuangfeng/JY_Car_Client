-- 邮件管理
local basefunc = require "Game.Common.basefunc"
EquipmentModel = {}
local M = EquipmentModel

local drive_equipment_config = GameModuleManager.ExtLoadLua(EquipmentController.key,"drive_equipment_config")
local drive_game_equipment_server = GameModuleManager.ExtLoadLua(EquipmentController.key,"drive_game_equipment_server")
local this
local listener

local function MakeListener()
    listener={}
    listener["query_drive_all_equipment_response"] = M.on_query_drive_all_equipment
    listener["query_drive_equipment_data_response"] = M.on_query_drive_equipment_data
    listener["drive_equipment_up_level_response"] = M.on_drive_equipment_up_level
    listener["drive_equipment_up_star_response"] = M.on_drive_equipment_up_star
    listener["drive_equipment_load_response"] = M.on_drive_equipment_load
    listener["drive_equipment_unload_response"] = M.on_drive_equipment_unload
    listener["on_drive_equipment_data_change"] = M.on_drive_equipment_data_change
    listener["car_equipment_data"] = M.on_car_equipment_data
end

local function AddListener()
    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveListener()
    if listener then
        for msg,cbk in pairs(listener) do
            Event.RemoveListener(msg, cbk)
        end
    end
    listener=nil
end

function M.Init()
    M.Exit()
    MakeListener()
    AddListener()
    this = M
	this.m_data = {}
    M.InitConfig()
end

function M.Exit()
    if this then
		RemoveListener()
		this = nil
	end
end

function M.InitConfig()
    this.config = {}
    for k,v in pairs(drive_equipment_config) do
        this.config[k] = v
    end

    for k,v in pairs(drive_game_equipment_server) do
        this.config[k] = v
    end
end

function M.GetEquipmentBaseCfgByID(id)
    if not id then return end
    for k,v in pairs(this.config.equipment_base) do
        if v.id == id then
            return v
        end
    end
end

function M.GetMainCfgByID(id)
    if not id then return end
    for k,v in pairs(this.config.main) do
        if v.id == id then
            return v
        end
    end
end

function M.GetBaseChangeRuleCfgByID(id)
    if not id then return end
    local t = {}
    for k,v in pairs(this.config.base_change_rule) do
        if v.id == id then
            table.insert(t,v)
        end
    end    
    return t
end

function M.GetSkillSeverCfgByEquipmentID(id)
    if not id then return end   
    local t = {}
    for k,v in pairs(this.config.star_skill_change) do
        if v.id == id then
            table.insert(t,v)
        end
    end    
    for k,v in pairs(this.config.level_skill_change) do
        if v.id == id then
            table.insert(t,v)
        end
    end    
    return t
end

function M.GetSkillClientCfgByEquipmentID(id)
    if not id then return end   
    local t = {}
    for k,v in pairs(this.config.skill_star) do
        if v.id == id then
            table.insert(t,v)
        end
    end    
    for k,v in pairs(this.config.skill_level) do
        if v.id == id then
            table.insert(t,v)
        end
    end    
    return t
end

function M.GetLevelExpRuleCfgByID(id)
    if not id then return end
    local t = {}
    for k,v in pairs(this.config.level_exp_rule) do
        if v.id == id then
            table.insert(t,v)
        end
    end    
    return t
end

function M.GetStarRuleCfgByID(id)
    if not id then return end
    local t = {}
    for k,v in pairs(this.config.star_rule) do
        if v.id == id then
            table.insert(t,v)
        end
    end    
    return t 
end

function M.GetLevelSpendRuleCfgByID(id)
    if not id then return end
    local t = {}
    for k,v in pairs(this.config.level_spend_rule) do
        if v.id == id then
            table.insert(t,v)
        end
    end    
    return t 
end

function M.GetSpendCfgByID(id)
    if not id then return end
    local t = {}
    for k,v in pairs(this.config.spend) do
        if v.id == id then
            table.insert(t,v)
        end
    end    
    return t 
end

function M.query_drive_all_equipment()
    dump("","<color=yellow>query_drive_all_equipment</color>")
    Network.SendRequest("query_drive_all_equipment")
end

function M.on_query_drive_all_equipment(_,data)
    dump(data,"<color=yellow>on_query_drive_all_equipment</color>")
    if not data or not next(data) then return end
    if data.result ~= 0 then
        TipsShowUpText.Create(errorCode[data.result])
        return
    end
    this.m_data.base_data = {}
    for k,v in pairs(data.base_data) do
        if v.owner_car_id == 0 then
            v.owner_car_id = nil
        end
        this.m_data.base_data[v.no] = v
    end
    Event.Brocast("model_query_drive_all_equipment_response",data)
end

function M.query_drive_equipment_data(data)
    dump(data,"<color=yellow>query_drive_equipment_data</color>")
    if not data or not next(data) or not data.no then 
        dump(data,"<color=red>query_drive_equipment_data data error</color>")
        return 
    end
    Network.SendRequest("query_drive_equipment_data", data)
end

function M.on_query_drive_equipment_data(_,data)
    dump(data,"<color=yellow>on_query_drive_equipment_data</color>")
    if not data or not next(data) then return end
    if data.result ~= 0 then
        TipsShowUpText.Create(errorCode[data.result])
        return
    end

    if data.base_data.owner_car_id == 0 then
        data.base_data.owner_car_id = nil
    end

    this.m_data.base_data = this.m_data.base_data or {}
    this.m_data.base_data[data.base_data.no] = data.base_data
    this.m_data.skill_data = this.m_data.skill_data or {}
    this.m_data.skill_data[data.base_data.no] = data.skill_data
    Event.Brocast("model_query_drive_equipment_data_response",data)
end

function M.drive_equipment_up_level(data,callback)
    dump(data,"<color=yellow>drive_equipment_up_level</color>")
    if not data or not next(data) or not data.no then 
        dump(data,"<color=red>query_drive_equipment_data data error</color>")
        return 
    end
    Network.SendRequest("drive_equipment_up_level", data,callback,true)
end

function M.on_drive_equipment_up_level(_,data)
    dump(data,"<color=yellow>on_drive_equipment_up_level</color>")
    if not data or not next(data) then return end
    if data.result ~= 0 then
        TipsShowUpText.Create(errorCode[data.result])
        return
    end
    TipsShowUpText.Create("升级成功")
    if data.spend_no then
        for k,v in pairs(data.spend_no) do
            this.m_data.base_data[v] = nil
            this.m_data.skill_data[v] = nil
        end
    end
    Event.Brocast("model_drive_equipment_up_level_response",data)
end

function M.drive_equipment_up_star(data)
    dump(data,"<color=yellow>drive_equipment_up_star</color>")
    if not data or not next(data) or not data.no then 
        dump(data,"<color=red>query_drive_equipment_data data error</color>")
        return 
    end
    Network.SendRequest("drive_equipment_up_star", data)
end

function M.on_drive_equipment_up_star(_,data)
    dump(data,"<color=yellow>on_drive_equipment_up_star</color>")
    if not data or not next(data) then return end
    if data.result ~= 0 then
        if data.result == 2253 then
            TipsShowUpText.Create("突破所需材料不足")
        else
            TipsShowUpText.Create(errorCode[data.result])
        end
        return
    end
	TipsShowUpText.Create("突破成功")
    Event.Brocast("model_drive_equipment_up_star_response",data)
end

function M.drive_equipment_load(data)
    dump(data,"<color=yellow>drive_equipment_load</color>")
    if not data or not next(data) or not data.no then return end
    local _data = {
		no = data.no,
		car_id = data.car_id or SysCarManager.GetCurCar().car_id
	}
	Network.SendRequest("drive_equipment_load",_data)
end

function M.on_drive_equipment_load(_,data)
    dump(data,"<color=yellow>on_drive_equipment_load</color>")
    if not data or not next(data) then return end
    if data.result ~= 0 then
        TipsShowUpText.Create(errorCode[data.result])
        return
    end
	TipsShowUpText.Create("装备成功")
    Event.Brocast("model_drive_equipment_load_response",data)
end

function M.drive_equipment_unload(data)
    dump(data,"<color=yellow>drive_equipment_unload</color>")
    if not data or not next(data) or not data.no then return end
    local _data = {
		no = data.no,
		car_id = data.car_id or SysCarManager.GetCurCar().car_id
	}
	Network.SendRequest("drive_equipment_unload",_data)
end

function M.on_drive_equipment_unload(_,data)
    dump(data,"<color=yellow>on_drive_equipment_unload</color>")
    if not data or not next(data) then return end
    if data.result ~= 0 then
        TipsShowUpText.Create(errorCode[data.result])
    end
	TipsShowUpText.Create("卸下成功")
    Event.Brocast("model_drive_equipment_unload_response",data)
end

function M.on_drive_equipment_data_change(_,data)
    dump(data,"<color=yellow>on_drive_equipment_data_change</color>")
    if data.base_data.owner_car_id == 0 then
        data.base_data.owner_car_id = nil
    end
    this.m_data.base_data = this.m_data.base_data or {}
    this.m_data.base_data[data.base_data.no] = data.base_data
    this.m_data.skill_data = this.m_data.skill_data or {}
    this.m_data.skill_data[data.base_data.no] = data.skill_data
    Event.Brocast("model_on_drive_equipment_data_change",data)
end

function M.on_car_equipment_data(data)
    dump(data,"<color=yellow>on_car_equipment_data</color>")
    this.m_data.base_data_car = {}
    for k,v in pairs(data) do
        this.m_data.base_data_car[v.no] = v
    end
end

function M.GetAllNotUseBaseData()
    local t = {}
    for k,v in pairs(this.m_data.base_data or {}) do
        if not v.owner_car_id then
            t[k] = v
        end
    end
    return t
end

function M.GetCarEquiment()
    dump(this.m_data.base_data,"<color=yellow>当前所有装备base_data</color>")
    local cur_car = SysCarManager.GetCurCar()
    local t = {}
    for k,v in pairs(this.m_data.base_data or {}) do
        if cur_car.car_id == v.owner_car_id then
            t[k] = v
        end
    end
    return t
end

function M.GetBaseData()
    return this.m_data.base_data
end

function M.GetBaseDataByNo(no)
    if not no then return end
    return this.m_data.base_data[no]  
end

function M.GetSkillDataByNo(no)
    dump(this.m_data.skill_data,"<color=yellow>m_data.skill_data</color>")
    if not this.m_data.skill_data then return end
    for k,v in pairs(this.m_data.skill_data) do
        if k == no then
            return v
        end
    end    
end

function M.GetEquipmentAttribute(data)
    dump(data,"<color=yellow>data????</color>")
    local main_cfg = M.GetMainCfgByID(data.id)
    local base_change_rule_cfg = M.GetBaseChangeRuleCfgByID(main_cfg.base_change_rule)
    dump(base_change_rule_cfg,"<color=yellow>base_change_rule_cfg</color>")
    local attribute = {
        hp = 0,
        at = 0,
        sp = 0
    }
    local level = 0
    for k_,v_ in pairs(base_change_rule_cfg) do
        if level >= data.level then
            break
        end
        for k,v in pairs(v_) do
            if k == "hp" or k == "at" or k == "sp" then
                if v_.level <= data.level then
                    attribute[k] = v * (v_.level - level)
                else
                    attribute[k] = v * (data.level - level)
                end
            end 
        end
        level = v_.level
    end
    return attribute
end

function M.GetEquipmentAttributeNext(data)
    local main_cfg = M.GetMainCfgByID(data.id)
    local base_change_rule_cfg = M.GetBaseChangeRuleCfgByID(main_cfg.base_change_rule)
    local attribute = {
        hp = 0,
        at = 0,
        sp = 0
    }
    local level = 0
    for k_,v_ in pairs(base_change_rule_cfg) do
        if level >= data.level + 1 then
            break
        end
        for k,v in pairs(v_) do
            if k == "hp" or k == "at" or k == "sp" then
                if v_.level <= data.level + 1 then
                    attribute[k] = v * (v_.level - level)
                else
                    attribute[k] = v * (data.level + 1 - level)
                end
            end 
        end
        level = v_.level
    end
    return attribute
end

function M.GetEquipmentSkill(data)
    dump(data,"<color=yellow>data</color>")
    local skill_data = M.GetSkillDataByNo(data.no)
    dump(skill_data,"<color=yellow>skill_data</color>")
    local skill_sever_cfg = M.GetSkillSeverCfgByEquipmentID(data.id)
    local skill_client_cfg = M.GetSkillClientCfgByEquipmentID(data.id)
    dump(skill_client_cfg,"<color=yellow>skill_client_cfg</color>")
    dump(skill_sever_cfg,"<color=yellow>skill_sever_cfg</color>")

    local skill = {
        star_0 = {},
        star_1 = {},
        star_2 = {},
        star_3 = {},
        star_4 = {},
        big = {},
        base = {},
    }

    local get_skill_cfg_by_id = function(cfg,skill_id,skill_type)
        local t = {}
        for k,v in pairs(cfg) do
            if skill_id == v.type_id then
                return v
            end
        end
    end

    local get_skill_cfg_by_no = function(cfg,no)
        local t = {}
        for k,v in pairs(cfg) do
            if no == v.no then
                return v
            end
        end
    end

    for k,v in pairs(skill_data or {}) do
        skill[v.skill_type].data = v
        skill[v.skill_type].sever_cfg = get_skill_cfg_by_id(skill_sever_cfg,v.type_id,v.skill_type)
        skill[v.skill_type].client_cfg = get_skill_cfg_by_no(skill_client_cfg,skill[v.skill_type].sever_cfg.no)
    end

    dump(skill,"<color=yellow>skill</color>")

    for k,v in pairs(skill_sever_cfg) do
        if not skill[v.skill_type] or not next(skill[v.skill_type]) then
            local client_cfg = get_skill_cfg_by_no(skill_client_cfg,v.no)
            if client_cfg and client_cfg.default and client_cfg.default == 1 then
                if v.skill_type then
                    skill[v.skill_type] = {}
                    skill[v.skill_type].client_cfg = client_cfg
                    skill[v.skill_type].sever_cfg = get_skill_cfg_by_id(skill_sever_cfg,v.type_id,v.skill_type)
                else
                    local skill_type = "star_" .. v.star
                    skill[skill_type] = {}
                    skill[skill_type].client_cfg = client_cfg
                    skill[skill_type].sever_cfg = get_skill_cfg_by_id(skill_sever_cfg,v.type_id,skill_type)
                end
            end
        end
    end

    return skill
end

function M.GetEquipmentExt(data)
    local main_cfg = M.GetMainCfgByID(data.id)
    local level_exp_rule_cfg = M.GetLevelExpRuleCfgByID(main_cfg.level_exp_rule)
    local exp = 10
    local level = 0
    local exp_cfgs = {}
    for k,v in ipairs(level_exp_rule_cfg) do
        exp_cfgs[v.level] = v
    end
    exp = SysCarUpgradeManager.GetCurUpgradeSpend(data.level,exp_cfgs).exp
    return exp
end

function M.GetEquipmentExtNext(data)
    local main_cfg = M.GetMainCfgByID(data.id)
    local level_exp_rule_cfg = M.GetLevelExpRuleCfgByID(main_cfg.level_exp_rule)
    local exp = 10
    local level = 0
    local exp_cfgs = {}
    for k,v in ipairs(level_exp_rule_cfg) do
        exp_cfgs[v.level] = v
    end
    exp = SysCarUpgradeManager.GetCurUpgradeSpend(data.level + 1,exp_cfgs).exp
    return exp
end

function M.GetCanUseEquipment(data)
    local t = {}
    for k,v in pairs(this.m_data.base_data) do
        if k ~= data.no and not v.owner_car_id then
            t[k] = v
        end
    end
    return t
end

function M.GetLevelUpSpend(data)
    if not data then return end
    local main_cfg = M.GetMainCfgByID(data.id)
    local level_rule_cfg = M.GetLevelSpendRuleCfgByID(main_cfg.level_spend_rule)
    if not level_rule_cfg or not next(level_rule_cfg) then return end
    dump(level_rule_cfg,"<color=yellow>level_rule_cfg</color>")
    local spend_cfgs = {}
    local max_level = 0
    for k,v in pairs(level_rule_cfg) do
        spend_cfgs[v.level] = {}
        if M.GetSpendCfgByID(v.spend) then
            spend_cfgs[v.level] =  M.GetSpendCfgByID(v.spend)[1]
        end
        if v.level > max_level then
            max_level = v.level
        end
    end
    local t = {
        jing_bi = 0,
        diamond = 0,
        gear = 0,
    }
    t = SysCarUpgradeManager.GetCurUpgradeSpend(data.level,spend_cfgs)
    return t,data.level >= max_level
end

function M.GetStarUpSpend(data)
    if not data then return end
    local main_cfg = M.GetMainCfgByID(data.id)
    local star_rule_cfg = M.GetStarRuleCfgByID(main_cfg.star_rule)
    if not star_rule_cfg or not next(star_rule_cfg) then return end
    local spend_cfgs = {}
    local max_star = 0
    for k,v in ipairs(star_rule_cfg) do
        spend_cfgs[v.star] ={}
        if  M.GetSpendCfgByID(v.spend) then
            spend_cfgs[v.star] =  M.GetSpendCfgByID(v.spend)[1]
        end
        if v.star > max_star then
            max_star = v.star
        end
    end
    local t = {
        jing_bi = 0,
        diamond = 0,
        gear = 0,
    }
    t = SysCarUpgradeManager.GetCurUpgradeSpend(data.star,spend_cfgs)
    return t,data.star >= max_star
end

local equipment_quality = {
    S = 1,
    A = 2,
    B = 3
}
--own_type|所属类型，common 公共，car_type_xx 类型为xx的车，car_id_nn id为nn的车
local equipment_own_type = {
    car_type_paoche = 1,
    car_id_1 = 2,
    car_type_tanke = 11,
    car_id_2 = 12,
    common = 100,
}

local sort_equipment = function(v1,v2)
    local sun = false
    --品质
    if equipment_quality[v1.quality] > equipment_quality[v2.quality] then
        return sun
    elseif equipment_quality[v1.quality] < equipment_quality[v2.quality] then
        return not sun            
    end
    --星级
    if v1.star > v2.star then
        return sun
    elseif v1.star < v2.star then
        return not sun            
    end
    --所属类型
    if equipment_own_type[v1.own_type] > equipment_own_type[v2.own_type] then
        return sun
    elseif equipment_own_type[v1.own_type] < equipment_own_type[v2.own_type] then
        return not sun            
    end
    --id
    if v1.id > v2.id then
        return sun
    elseif v1.id < v2.id then
        return not sun            
    end
    --level
    if v1.level > v2.level then
        return sun
    elseif v1.level < v2.level then
        return not sun            
    end
    --now_exp
    if v1.now_exp > v2.now_exp then
        return sun
    elseif v1.now_exp < v2.now_exp then
        return not sun            
    end
    --no
    if v1.no > v2.no then
        return sun
    elseif v1.no < v2.no then
        return not sun            
    end
end

function M.SortEquipment(equipments)
    dump(equipments,"<color=white>equipments</color>")
    local list = {}
    local main_cfg
    for k,v in pairs(equipments) do
        local data = {}
        data.id = v.data.id
        data.star = v.data.star
        data.level = v.data.level
        data.now_exp = v.data.now_exp
        data.no = v.data.no
        data.quality = v.main_cfg.quality
        data.own_type = v.main_cfg.own_type
        table.insert(list,data)
    end
    MathExtend.SortListCom(list,sort_equipment)
    dump(list,"<color=yellow>排序list</color>")
    return list
end