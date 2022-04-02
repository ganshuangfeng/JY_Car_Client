require "Game.Framework.SceneConfig"
SceneHelper = {}
local M = SceneHelper

local scene_logic
local scene_list = {}
local location_client
local location_server
local game_id_server
--服务器的位置到客户端的场景
local s2c_location_scene = {
	["pvp_game_driver"] = "game_Drive"
}
--服务器的位置可以前往客户端的场景
local s2c_location_scene_map = {
	["pvp_game_driver"] = {
		game_Login = "game_Login",
		game_Hall = "game_Hall",
		game_Drive = "game_Drive",
		game_Drive_map3 = "game_Drive_map3",
		game_Drive_map4 = "game_Drive_map4",
		game_Drive_map5 = "game_Drive_map5",
	}
}

local game_id2map_id = {
	[-1] = 5,
}

--错误码适配
local format_game_state_error
-- 预加载表
local preloadList = {}
-- 卸载表
local unLoadList = {}
-- 资源表
local resDict = {}
--当前进度
local currLoadCount = 0
--总进度
local totallLoadCount = 0
--设置加载和卸载资源
local set_preload_unload_asset
--上一个场景退出
local scene_exit
--下一个场景进入
local scene_enter
--加载场景所需资源
local load_scene_asset
--加载场景
local load_scene
--加载场景完成
local load_scene_finish 
--下一个场景进入
local scene_enter_logic_init
-- 卸载
local unload_asset
-- 加载
local load_asset
--检测更新
local check_download
--下载场景
local download_scene
-- 跳转场景
local goto_scene
--检测是否可以前往场景
local check_goto_scene

set_preload_unload_asset = function()
	resDict = {}
	local m_AssetTable = resMgr:GetAssetTableDict()
	local m_asset_table = {}
	m_AssetTable = m_AssetTable:GetEnumerator()
	while m_AssetTable:MoveNext() do
		m_asset_table[m_AssetTable.Current.Key] = {}
		m_asset_table[m_AssetTable.Current.Key].value = m_AssetTable.Current.Value
		local lifeType = resMgr:GetAssetTableDictLifeType(m_AssetTable.Current.Value)
		m_asset_table[m_AssetTable.Current.Key].lifeType = lifeType
    end

	local m_PreloadAssetList = resMgr:GetAssetTableList()
	local m_preload_asset_map = {}
	for i = 0, m_PreloadAssetList.Length - 1, 1 do
    	m_preload_asset_map["" .. m_PreloadAssetList[i]] = m_PreloadAssetList[i]
    end

	preloadList = {}
	for k,v in pairs(m_preload_asset_map) do
		if not m_asset_table[k] then
			preloadList[#preloadList + 1] = k
		end
	end

	unLoadList = {}
	for k,v in pairs(m_asset_table) do
		-- 不在预加载列表，并且不是永驻就加入到卸载列表
        if not m_preload_asset_map[k] and v.lifeType ~= 1 then
        	unLoadList[#unLoadList + 1] = k
        end
	end
	resDict = {}
	currLoadCount = 0
	totallLoadCount = #unLoadList + #preloadList

	dump(os.time(),"<color=white>scenehelper set_preload_unload_asset</color>")
	dump(preloadList,"<color=white>scenehelper preloadList</color>")
	dump(unLoadList,"<color=white>scenehelper unLoadList</color>")
	dump(totallLoadCount,"<color=white>scenehelper totallLoadCount</color>")
end
 
scene_exit = function(parm)
	dump(os.time(),"<color=white>scenehelper scene_exit</color>")
	dump(scene_logic,"<color=yellow>scene_logic</color>")
	if scene_logic then
		if scene_logic.Exit and type(scene_logic.Exit) == "function" then
			scene_logic.Exit()
		end
        scene_logic = nil
	end
	if location_client then
		table.insert(scene_list,location_client)
	end

	Event.Brocast("scene_exit")
end

scene_enter = function(parm)
	dump(os.time(),"<color=white>scenehelper scene_enter</color>")
	location_client = parm.scene_name
	scene_enter_logic_init(parm)
end

load_scene_finish = function(parm)
	dump(os.time(),"<color=white>scenehelper load_scene_finish</color>")
	Event.Brocast("load_scene_finish")
	resMgr:LoadSceneFinish(parm.scene_name)
	gameMgr:LoadSceneFinish()
	scene_enter(parm)
end

local scene_loaded
load_scene = function(parm)
	if currLoadCount < totallLoadCount then return end
	dump(os.time(),"<color=white>scenehelper load_scene</color>")
	SceneMgr.LoadScene(resMgr:FormatSceneName(parm.scene_name))
	dump(SceneMgr.sceneLoaded,"<color=red>场景加载完成</color>")

	if scene_loaded then
		SceneMgr.sceneLoaded = SceneMgr.sceneLoaded - scene_loaded
	end

	scene_loaded = function ()
		load_scene_finish(parm)
	end

	if SceneMgr.sceneLoaded then
		SceneMgr.sceneLoaded = SceneMgr.sceneLoaded + scene_loaded
	else
		SceneMgr.sceneLoaded =  function ()
			load_scene_finish(parm)
		end
	end
end

load_scene_asset = function(parm)
	dump(os.time(),"<color=white>scenehelper load_scene_asset</color>")
	Event.Brocast("load_scene_start",{totall_load_count = totallLoadCount})
	local callback = function()
		dump(os.time(),"<color=white>scenehelper load_scene_asset callback</color>")
		set_preload_unload_asset(parm)
		if totallLoadCount > 0 then
			unload_asset(parm)
			load_asset(parm)
		else
			load_scene(parm)
		end
	end
	resMgr:LoadSceneAsync(parm.scene_name,callback)
end

scene_enter_logic_init = function(parm)
	dump(os.time(),"<color=white>scenehelper scene_enter_logic_init</color>")
	local scene_cfg = SceneConfig[parm.scene_name]
	if not scene_cfg or not scene_cfg.LuaBundle or not scene_cfg.SceneLogic then
		dump({scene_cfg = scene_cfg},"<color=red> Error GotoScene ".. parm.scene_name .. " </color>")
		return
	end
	resMgr:LoadSceneLuaBundle(scene_cfg.LuaBundle)
	local needR = "Game." .. scene_cfg.LuaBundle .. ".Lua.".. scene_cfg.SceneLogic
	package.loaded[needR] = nil
	scene_logic = require (needR)
	dump(parm,"<color=white>parm</color>")
	dump(scene_cfg,"<color=white>scene_cfg</color>")
	dump(scene_logic,"<color=white>scene_logic</color>")

	if parm.init_frontcall then
		parm.init_frontcall()
	end

	if scene_logic.Init and type(scene_logic.Init) == "function" then
		scene_logic.Init(parm)
	end

	if parm.backcall then
		parm.backcall()
	end

	Event.Brocast("scene_enter")
end

unload_asset = function(parm)
	dump(os.time(),"<color=white>scenehelper unload_asset</color>")
	if not unLoadList or not next(unLoadList) then return end
    for k, v in pairs(unLoadList) do
        resMgr:DestroyAssetObject(v)
        currLoadCount = currLoadCount + 1
    end
	load_scene(parm)
end

load_asset = function(parm)
	dump(os.time(),"<color=white>scenehelper load_asset</color>")
	if not preloadList or not next(preloadList) then return end
    for k, v in pairs(preloadList) do
        local str = StringHelper.Split(v, ".")
        if str[#str] == "png" then
            GetTexture(v)
        elseif str[#str] == "mp3" then
            GetAudio(v)
        else
            GetPrefab(v)
        end
        Yield(0)
        currLoadCount = currLoadCount + 1
		Event.Brocast("load_asset_progress",{curr_load_count = currLoadCount})
		load_scene(parm)
    end
end

format_game_state_error = function(errorInfo)
	local ns = StringHelper.Split(errorInfo, ":")
	if #ns ~= 2 or ns[1] ~= "Error" then
		print("<color=red> format_game_state_error exception: ".. errorInfo .. " </color>")
		return ""
	end
	return ns[2] or "未知错误"
end

check_goto_scene = function(parm)
	if not parm.scene_name or not SceneConfig[parm.scene_name] then
		print("<color=red>场景名错误</color>")
		return
	end

	if location_client == parm.scene_name then
		print("<color=red>正在当前场景</color>")
		return
	end

	if location_server and s2c_location_scene_map[location_server] and not s2c_location_scene_map[location_server][parm.scene_name] then
		dump({location_server = location_server,scene_name = parm.scene_name},"<color=red>服务器位置限制，不能前往该场景</color>")
		return
	end
	return true
end

goto_scene = function(parm)
	dump(parm,"<color=white>goto_scene</color>")
	if not check_goto_scene(parm) then return end
	
	if parm.frontcall then
		parm.frontcall()
	end
	--退出上一个场景
	scene_exit(parm)
	--加载资源
	load_scene_asset(parm)
	return true
end

download_scene = function(parm)
	--场景需要下载
	gameMgr:DownloadUpdate(parm.scene_name,
		function (state)
			--状态改变时回调
			if (state == string.lower(parm.scene_name)) then
				--下载场景完成
				goto_scene(parm)
				Event.Brocast("download_update_succeed",{parm = parm})
			else
				--下载场景失败
				HintPanel.ErrorMsg(format_game_state_error(state))
				Event.Brocast("download_update_fail",{parm = parm})
			end
		end,
		function (val)
			--下载进度改变时回调
			Event.Brocast("download_update_process",{parm = parm,val = val})
		end
	)
end

check_download = function(parm)
	local state = gameMgr:CheckUpdate(parm.scene_name)
	dump({state = state,scene_name = parm.scene_name},"<color=green>M down scene name</color>")
	if state == "Install" or state == "Update" then
		download_scene(parm)
		return true
	elseif state == "Normal" then
	else
		HintPanel.ErrorMsg(format_game_state_error(state))
		return true
	end
end
 
--跳转到场景 检测跳转 -> 检测更新 -> 下载资源 -> 检测跳转 -> 加载资源 -> 跳转到目标场景
--parm = {scene_name,frontcall,backcall,frontdata,backdata}
function M.GotoScene(parm)
	dump(parm,"<color=red>跳转场景参数</color>")
	if not check_goto_scene(parm) then return end

	-- if M.downing_scene then
	-- 	TipsShowUpText.Create("下载中，不能切换场景")
	-- 	return
	-- end

	if check_download(parm) then
		--需要更新或者状态错误
		return
	end

	return goto_scene(parm)
end

--恢复到服务器上的场景
function M.GotoSceneServer(_parm)
	--服务器上没有当前场景
	dump(location_server,"<color=white>服务器位置</color>")
	if not location_server then 
		return
	end
	local parm = {
		scene_name = s2c_location_scene[location_server]
	}
	if not check_goto_scene(parm) then
		return
	end

	local scene_name = s2c_location_scene[location_server]
	local scene_cfg = SceneConfig[scene_name]
	if not scene_cfg then
		location_server = nil
		HintPanel.Create({show_yes_btn = true,msg = "服务器当前位置错误"})
		return
	end

	local map_id = game_id2map_id[game_id_server] or game_id_server
	if map_id and scene_name == "game_Drive" then
		scene_name = scene_name .. "_map" .. map_id
	end

	local msg = string.format("您正在%s游戏中，是否继续游戏？", scene_cfg.GameName)
	
	local parm = {
		scene_name = scene_name,
		game_id = game_id_server,
		map_id = map_id,
	}

	if _parm and _parm.backcall then
		parm.backcall = _parm.backcall
	end

	HintPanel.Create({show_yes_btn = true,show_close_btn = true,msg =  msg,yes_callback = function()
		goto_scene(parm)
	end})

	Event.Brocast("goto_scene_server",parm)
end

function M.SetLocationServer(location)
	location_server = location
end

function M.SetGameIDServer(game_id)
	game_id_server = game_id
end

function M.CheckGotoIsScene(_goto)
	dump(SceneConfig,"<color=white>SceneConfig</color>")
	return SceneConfig[_goto]
end

function M.GetCurScene()
	return location_client
end