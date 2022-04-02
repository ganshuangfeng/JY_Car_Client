-- 创建时间:2019-09-20
-- Panel:GameModuleManager

local basefunc = require "Game/Common/basefunc"
local game_module_config
local game_enter_config

GameModuleManager = {}

local C = GameModuleManager
local listener
local this

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
end

function C.Init()
	GameModuleManager.Exit()
	print("<color=red>初始化全新的活动系统</color>")
    this = GameModuleManager
    MakeListener()
    AddListener()
end
function C.Exit()
	if this then
        RemoveLister()
		this = nil
	end
end

-- 活动相关的加载Lua
function C.ExtLoadLua(key, lua_name)
    return ext_require("Game.GameModule." .. key .. ".Lua." .. lua_name)
end
-- 加载Lua
function C.LoadLua()
    if this.Config.module_map then
        local module_list = {}
        for k,v in pairs(this.Config.module_map) do
            table.insert(module_list,v)
        end
        table.sort( module_list, function(a, b) return tonumber(a.id) < tonumber(b.id) end )
        for k,v in ipairs(module_list) do
            if v.lua and not _G[v.lua] then
                require("Game.GameModule." .. v.key .. ".Lua." .. v.lua)
            end
            if _G[v.lua] and _G[v.lua].Init then
                _G[v.lua].Init()
            end
        end
    end
    print("<color=green>load lua finsh</color>")
end
function C.CheckHFX()
    -- GameModuleConfig
    if AppDefine.IsEDITOR() then
        local is_er = false
        local path = Application.dataPath
        path = path .. "/VersionConfig/GameModuleConfig.json"
        if File.Exists(path) then
            local ss = File.ReadAllText(path)
            ss = json2lua(ss)
            local map = {}
            for k,v in pairs(ss.modules) do
                if v.enable then
                    local key = StringHelper.Split(v.name, "/")
                    if #key >= 2 then
                        map[key[2]] = 1
                    end
                end
            end
            for k,v in pairs(this.Config.module_map) do
                if not map[k] then
                    -- 资源没有打包出去(没有打钩),但是模块里有配置(game_module_config)
                    -- 出现这种情况要么去掉模块配置的引用,要么重新打包
                    print("<color=red><size=28>Error=" .. k .. "</size></color>")
                    is_er = true
                end
            end
        end
        if is_er then
            HintPanel.Create({show_yes_btn = true,msg =  "问题：模块配置与打包配置不一致，打包需要注意!"})
        end
    end
end

function C.InitConfig()
    game_module_config = HotUpdateConfig("Game.GameCommon.Lua.game_module_config")
    game_enter_config = HotUpdateConfig("Game.GameCommon.Lua.game_enter_config")

    this.Config = {}
    this.Config.enter_map = {}

    this.Config.module_map = {}
    -- 特殊管理器
    this.Config.module_map["sys_permission"] = {lua="PermissionManager",key="sys_permission"}
    for k,v in ipairs(game_module_config.config) do
        if v.is_on_off == 1 then
            local aa,bb = GameModuleManager.RunFun({_goto="sys_permission", _permission_key=v.condi_key, is_on_hint = false}, "CheckCondition")
            if not aa or bb then
                this.Config.module_map[v.key] = v
            end
        end
    end

    this.Config.all_enter_btn_list = game_enter_config.all_enter

    for k,v in pairs(game_enter_config) do
        if k ~= "all_enter" then
            this.Config.enter_map[k] = {}
            local hem = this.Config.enter_map[k]
            for _, v1 in ipairs(v) do
                local cfg1 = {}
                hem[v1.area] = cfg1
                if v1.group_list and v1.group_list ~= "" then
                    if type(v1.group_list) == "string" then
                        local s1 = StringHelper.Split(v1.group_list, "#")
                        for _, v2 in ipairs(s1) do
                            local s2 = StringHelper.Split(v2, ";")
                            local cfg2 = {}
                            for _, v3 in ipairs(s2) do
                                cfg2[#cfg2 + 1] = tonumber(v3)
                            end
                            cfg1[#cfg1 + 1] = cfg2
                        end
                    else
                        dump(v1, "<color=red>EEE group_list 不是字符串</color>")
                    end
                end
            end
        end
    end
    C.CheckHFX()

    C.LoadLua()
end

-- 根据ID获取活动入口配置
function C.GetEnterConfig( id )
    local cfg = this.Config.all_enter_btn_list[id]
    if cfg and cfg.is_on_off == 1 then
        return cfg
    end
    return nil
end

-- 根据类型获取活动的入口的Map
function C.GetGameEnterMap(type)
    if this.Config.enter_map[type] then
		return this.Config.enter_map[type]
	else
		return {}
	end
end
-- 模块配置
function C.GetModuleByKey(key)
    return this.Config.module_map[key]
end

-- 活动对应的跳转
function C.Goto(parm)
    if not this.Config then return end
    local v = this.Config.module_map[parm._goto]
    if v then
        if _G[v.lua] and _G[v.lua].Goto then
            return _G[v.lua].Goto(parm)
        end
    end
end
-- 活动对应的数据获取
function C.GetData(parm)
    local v = this.Config.module_map[parm._goto]
    if v then
        if _G[v.lua] and _G[v.lua].GetData then
            return _G[v.lua].GetData(parm)
        end
    end
end
-- 活动对应的红点类 提示状态
function C.GetHintState(parm)
    local v = this.Config.module_map[parm._goto]
    if v then
        if _G[v.lua] and _G[v.lua].GetHintState then
            return _G[v.lua].GetHintState(parm)
        end
    end
end
-- 
function C.RunFun(parm, fun_name)
    if not this.Config then
        print(debug.traceback())
        dump(parm, "<color=red>EEE RunFun</color>")
        if AppDefine.IsEDITOR() then
            HintPanel.Create({show_yes_btn = true,msg = "编辑器下弹出：检查"})
        end
        return
    end
    local v = this.Config.module_map[parm._goto]
    if v then
        if _G[v.lua] and _G[v.lua][fun_name] then
            if type (_G[v.lua][fun_name]) == "function" then
                return true, _G[v.lua][fun_name](parm)
            end
            return true, _G[v.lua][fun_name]
        end
    end
    return false
end

function C.CheckOnOff(key)
    if not this or table_is_null(this.Config) or table_is_null(this.Config.module_map) or table_is_null(this.Config.module_map[key]) then return end
    return this.Config.module_map[key].is_on_off == 1
end

-- 扩展
function C.RunFunExt(_goto, fun_name, call, ...)
    local v = this.Config.module_map[_goto]
    if v then
        if _G[v.lua] and _G[v.lua][fun_name] then
            if type (_G[v.lua][fun_name]) == "function" then
                return true, _G[v.lua][fun_name](...)
            end
            return true, _G[v.lua][fun_name]
        end
    end
    
    if call then
        call()
    end
    return false
end