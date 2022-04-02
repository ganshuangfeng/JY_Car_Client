DriveMapManager = {}
local M = DriveMapManager
ext_require("Game.game_Drive.Lua.DriveMapBoardItem")
local drive_map_config = SysCarManager.GetDriveMapConfig()

local path_points --路线点

local this
local listener

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
    listener["logic_drive_game_process_data_msg_player_action"] = this.CloseAllMapBtn
	listener["model_correct_op_timeout"] = this.on_model_correct_op_timeout
end

function M.Init()
    if not this then
        M.Exit()
        this = DriveMapManager
        this.m_data = {}
        this.game_map = {}
        --地图上的技能-升级-三选一等
        this.game_award_map = {}
        MakeListener()
        AddListener()
        M.InitConfig()
    end
end

function M.InitConfig()
    this.config = {}
    this.config.map_config = {}
    for k,v in pairs(drive_map_config.map_config) do
        this.config.map_config[v.id] = v
    end
    this.config.map_asset = drive_map_config.map_asset
    this.config.map_string = drive_map_config.map_string
    this.config.map_color = drive_map_config.map_color
end

function M.Exit()
    RemoveLister()
    if this then
        this.ClearMap()
    end
    this = nil
end

function M.SetMapFirstId()
    local map_data = DriveModel.data.map_data
    if (not map_data or not next(map_data) or not map_data.map_id) then return end
    if not (this.config.map_config[map_data.map_id]) then return end
    this.first_id = this.config.map_config[map_data.map_id].first_id or 1
end

function M.CreateMap()
    local map_data = DriveModel.data.map_data
    if (not map_data or not next(map_data) or not map_data.map_id) then return end
    if not (this.config.map_config[map_data.map_id]) then return end
    this.ClearMap()
    this.m_data.map_id = map_data.map_id
    M.map_cfg = this.config.map_config[map_data.map_id]
    local map_cfg = this.config.map_config[map_data.map_id]
    local parent = GameObject.Find("map_node").transform
    this.map_prefab = {}
    this.map_prefab.gameObject = parent.transform:Find("drive_map" .. DriveLogic.InitPram.map_id) -- newObject(DriveMapManager.GetMapAssets("drive_map"),parent)
    this.map_prefab.transform = this.map_prefab.gameObject.transform
    this.scene_node = this.map_prefab.transform:Find("scene_node")
    this.car_node = this.map_prefab.transform:Find("car_node")
    this.drectional_light = this.map_prefab.transform:Find("DirectionalLight3DMiddle"):GetComponent("Light")
    this.drectional_light.gameObject:SetActive(true)
    this.scene_renderer_array = this.scene_node.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    --初始化draw_mesh
    this.draw_mesh_obj = this.map_prefab.transform:Find("DrawMeshNode/DrawMesh")
    this.draw_mesh = this.draw_mesh_obj:GetComponent("DrawMesh")
    this.draw_mesh:DrawRoad()
    this.draw_mesh_obj.gameObject:SetActive(false)

    basefunc.GeneratingVar(this.map_prefab.transform,this.map_prefab)
    this.map_count = 0
    this.map_count = (map_cfg.map_width + map_cfg.map_height) * 2 - 4

    for i=1,this.map_count do
        this.map_prefab["road_node_" .. i] = this.map_prefab.transform:Find("node_root/road_node" .. i)
        this.map_prefab["skill_node_" .. i] = this.map_prefab.transform:Find("node_root/road_node" .. i .. "/skill_node")
    end

    this.first_id = map_cfg.first_id or 1

    this.game_map = {}
    for i=1,this.map_count do
        local item_data = {
            road_id = i
        }
        this.game_map[i] = DriveMapBoardItem.Create(this.map_prefab["road_node_" .. i],item_data)
    end

    M.GetPathPoints()
    init_drive_car_map_cfg(this.map_prefab,map_cfg,path_points)

    DriveEffectManager.SetLight({weather = "day"})

    --测试代码
    -- M.ShowMapRangNode(15,2)
    
    -- local t = Timer.New(function(  )
    --     DriveEffectManager.SetLight({weather = "night"})
    -- end,4,1)
    -- t:Start()
end

function M.RefreshMap()
    if not this.map_prefab or not next(this.game_map) then
        this.CreateMap()
        return
    end
    local map_data = DriveModel.data.map_data
    dump(map_data,"<color=white>刷新地图</color>")
    if map_data and next(map_data) and map_data.map_id and map_data.map_id == this.m_data.map_id then
        -- init_drive_car_map_cfg(this.map_prefab,M.map_cfg)
        --map_id 一样刷新部分
        if this.select_hint_barrier_hint_fx then
            destroy(this.select_hint_barrier_hint_fx)
            this.CloseAllMapBtn()
            this.select_hint_barrier_hint_fx = nil
        end
        return
    end
    --map_id 不一样直接重新创建地图
    M.ClearMap()
    M.CreateMap()
end

function M.ClearMap()
    if this and this.game_map then
        for k,v in ipairs(this.game_map) do
            v:MyExit()
        end
        this.game_map = {}
    end

    -- if this and this.map_prefab and IsEquals(this.map_prefab.gameObject) then
    --     destroy(this.map_prefab.gameObject)
    --     this.map_prefab = nil
    -- end
end

function M.CreateMapNode()
    for x=1,M.map_cfg.map_width - 1 do
        for y=1,M.map_cfg.map_height - 1 do
            
        end
    end
end

function M.GetGameMapByRoadID(road_id,is_conversion)
    local _road_id = road_id or 1
    if is_conversion then
        _road_id = M.ServerPosConversionMapPos(_road_id)
    end
    return this.game_map[_road_id]
end

function M.GetMapPrefabByRoadID(road_id,is_conversion)
    local _road_id = road_id or 1
    if is_conversion then
        _road_id = M.ServerPosConversionMapPos(_road_id)
    end
    return this.map_prefab["road_node_" .. _road_id]
end

function M.ServerPosConversionRoadId(s_pos)
    local ret = s_pos % this.map_count
    return ret == 0 and this.map_count or ret
end

--返回原节点的值
function M.ServerPosConversionMapPos(s_pos)
    if s_pos then
        local p = (s_pos + this.first_id - 1) % this.map_count
        if p == 0 then return this.map_count end
        return p
    end
end

function M.ServerPosConversionMapVector(s_pos)
    local p = M.ServerPosConversionMapPos(s_pos)
    if not IsEquals(this.map_prefab) or not p then return Vector3.zero end
    return this.map_prefab["road_node_" .. p].transform.position
end

function M.ServerPosConversionSkillVector(s_pos)
    local p = s_pos % this.map_count
    if p == 0 then 
        p = this.map_count 
    end
    if not IsEquals(this.map_prefab) then return Vector3.zero end
    return this.map_prefab["road_node_" .. p].transform:Find("skill_node").position
end

function M.MapVectorConversionRoadId(vec,is_conversion)
    local min_dis = 9999
    local min_road_id = 1
    for i = 1,this.map_count do 
        local cur_vec = this.map_prefab["road_node_" .. i].transform.position
        local cur_dis = Vec2DLength(Vec2DSub(cur_vec, vec))
        if cur_dis < min_dis then
            min_dis = cur_dis
            min_road_id = i
        end
    end
    if is_conversion then
        local ret =  (min_road_id - this.first_id + this.map_count + 1) % this.map_count
        if ret == 0 then ret = this.map_count end
        return ret
    else
        return min_road_id
    end
end

function M.GetPathPoints()
    local distance = DriveMapManager.map_count
    local path_vector = {}
    for i=1,distance do
        path_vector[i] = this.map_prefab["road_node_" .. i].transform.position
    end
    path_vector[distance + 1] = this.map_prefab["road_node_" .. 1].transform.position

    local duration = 1
    local parent = this.map_prefab.road_node_1
    local car_obj = newObject("car",parent.transform)
    car_obj.gameObject:SetActive(false)
    car_obj.transform.position = parent.transform.position
    local DOT = car_obj.transform:DOPath(path_vector,duration,Enum.PathType.CatmullRom,Enum.PathMode.TopDown2D)
    DOT:ForceInit()
    path_points = DOT:PathGetDrawPoints()
    DOT:Kill()
    destroy(car_obj)
end

function M.GetEvenlyDistributedVector(vec,dis)
    local min_dis = 9999
    local now_dis = 0
    local start_index
    local path_point
    for i=0,path_points.Length - 1 do
        path_point = path_points[i]
        now_dis = Vec2DLength(Vec2DSub(path_point, vec))
        if now_dis < min_dis then
            start_index = i
            min_dis = now_dis
        end
    end
    local map_all_length = get_map_length()

    local front_vec_list = {}
    local now_all_length = 0
    local i = start_index
    table.insert(front_vec_list,path_points[i])
    while map_all_length > now_all_length do
        i = i + 1
        if i > path_points.Length - 1 then
            i = 0
        end
        now_dis = Vec2DLength(Vec2DSub(path_points[i], front_vec_list[#front_vec_list]))
        if now_dis >= dis then
            table.insert(front_vec_list,path_points[i])
            now_all_length = now_all_length + now_dis
        end
    end

    local back_vec_list = {}
    local now_all_length = 0
    local i = start_index
    table.insert(back_vec_list,path_points[i])
    while map_all_length > now_all_length do
        i = i - 1
        if i < 0 then
            i = path_points.Length - 1
        end
        now_dis = Vec2DLength(Vec2DSub(path_points[i], back_vec_list[#back_vec_list]))
        if now_dis >= dis then
            table.insert(back_vec_list,path_points[i])
            now_all_length = now_all_length + now_dis
        end
    end

    return {front_vec_list = front_vec_list, back_vec_list = back_vec_list}
end

function M.CarMapEulerZ(car_vec)
    -- dump(car_vec,"<color=yellow>car_vec</color>")
    local euler_z = get_map_point_angle(car_vec)
    euler_z = euler_z or 0
    return euler_z
end

function M.GetInRoadID(vec_2d)
    local road_id
    for i=1,this.map_count do
        local road_pos_2d = DriveModel.Get3DTo2DPoint(this.game_map[i].transform.position)
        road_pos_2d = Vector3.New(road_pos_2d.x,road_pos_2d.y,0)
        local dis = Vector3.Distance(vec_2d,road_pos_2d)
		if dis <= 60 then
			road_id = i
            break
		end
    end
    return road_id
end

function M.SelectGrid(grid_ids)
    if grid_ids then
        dump(this.game_map,"<color=red>this.game_map</color>")
        for k,v in ipairs(grid_ids) do
            local item = this.GetGameMapByRoadID(v,true)
            if item then
                item:ActiveSelectBtn(true)
            end
        end
    else
        for k,v in ipairs(this.game_map) do
            v:ActiveSelectBtn(true)
        end
    end
    -- if this.select_hint_barrier_hint_fx then
    --     destroy(this.select_hint_barrier_hint_fx)
    -- end
    -- this.select_hint_barrier_hint_fx = newObject("select_barrier_hint_fx",GameObject.Find("Canvas/LayerLv3").transform)
end

function M.CloseAllMapBtn(parm)
    for k,v in ipairs(this.game_map) do
        v:ActiveSelectBtn(false)
    end
    if this.select_hint_barrier_hint_fx then
        destroy(this.select_hint_barrier_hint_fx)
    end
end

function M.ActiveSmallAcc(grid_id,active,num)
    if not grid_id then return end
    if not active then active = false end
    local item = this.GetGameMapByRoadID(grid_id,true)
    if not item then return end
    item:ActiveSmallAcc(active,num)
end

function M.ActiveAllSmallAcc(b)
    if this then
        for k,v in ipairs(this.game_map) do
            v:ActiveSmallAcc(b)
        end
    end
end

function M.on_model_correct_op_timeout(data)
    if this.select_hint_barrier_hint_fx then
        if IsEquals(this.select_hint_barrier_hint_fx) then
            this.select_hint_barrier_hint_fx.transform:Find("time_out_txt"):GetComponent("Text").text = math.floor(data.op_timeout) .. "s"
        end
        if data.op_timeout <= 0 then
            destroy(this.select_hint_barrier_hint_fx)
            this.select_hint_barrier_hint_fx = nil
            this.CloseAllMapBtn()
        end
    end
end

function M.GetMapAssets(key)
    if not this.config.map_asset[key] then return key end
    if not DriveModel or not DriveModel.data or not DriveModel.data.map_data or not DriveModel.data.map_data.map_id then return key end
    local id = DriveModel.data.map_data.map_id
    local s = this.config.map_asset[key]["id_" .. id]
    if not s then s = key end
    return s
end

function M.GetMapString(key)
    if not this.config.map_string[key] then return "%s" end
    if not DriveModel or not DriveModel.data or not DriveModel.data.map_data or not DriveModel.data.map_data.map_id then return key end
    local id = DriveModel.data.map_data.map_id
    local s = this.config.map_string[key]["id_" .. id]
    if not s then s = "%s" end
    return s
end

function M.SetMapString(key,str)
    local mp_str = M.GetMapString(key)
    if not str then str = "" end
    return string.format(mp_str,str)
end

function M.GetMapColor(key)
    local color = Color.New(255, 255, 255, 255)
    if not this.config.map_color[key] then
        UnityEngine.ColorUtility.TryParseHtmlString("#000000FF",color)
        return color
    end
    if not DriveModel or not DriveModel.data or not DriveModel.data.map_data or not DriveModel.data.map_data.map_id then return key end
    local id = DriveModel.data.map_data.map_id
    local s = this.config.map_color[key]["id_" .. id]
    if not s then s =  "#000000FF" end
    local b,c = UnityEngine.ColorUtility.TryParseHtmlString(s,color)
    return c
end

function M.ShowMapRangNode(start_road_id,end_road_id,style)
    dump({start_road_id = start_road_id,end_road_id = end_road_id},"<color=yellow>ShowMapRangNode</color>")
    style = style or 1
    local road_points = {}
    local loop_count = end_road_id - start_road_id
    if loop_count < 0 then loop_count = loop_count + DriveMapManager.map_count end
    if loop_count == 0 then
        road_points[1] = start_road_id
    else
        for i = 0,loop_count do
            local road_id =  (start_road_id + i) % DriveMapManager.map_count
            if road_id == 0 then road_id = DriveMapManager.map_count end
            road_points[#road_points + 1] = road_id
        end
    end
    local style_map = {
        [1] = "RoadRangeRed",
        [2] = "RoadRangeGreen",
        [3] = "RoadRangeRed_1",
    }

    local style_head = {
        [1] = "RoadRangeRedHead",
        [2] = "RoadRangeGreenHead",
        [3] = "RoadRangeRedHead_1",
    }
    style = style or 1
    local mat = GetMaterial(style_map[style])
    local mat1 = GetMaterial(style_head[style])
    local draw_mesh_obj = DriveMapManager.draw_mesh:CreateRoadRange(road_points,mat,mat1)
    local ret = {}
    ret[start_road_id] = draw_mesh_obj
    return ret
end