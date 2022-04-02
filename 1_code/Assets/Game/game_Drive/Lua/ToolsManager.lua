-- 创建时间:2021-01-04
ToolsManager = {}
local M = ToolsManager
local drive_tool_config = ext_require("Game.game_Drive.Lua.drive_tool_config")
local drive_game_tool_server = ext_require("Game.game_Drive.Lua.drive_game_tool_server")
ext_require("Game.game_Drive.Lua.ToolsBase")

M.act_enum = {
	create = 1,
	use = 2,
    dead = 3,
}

local this
local listener

local function MakeListener()
    listener = {}
    listener["play_process_tool_create"] = this.on_play_process_tool_create
    listener["play_process_tool_use"] = this.on_play_process_tool_use
    listener["play_process_tool_dead"] = this.on_play_process_tool_dead
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

function M.Init()
    if not this then
        M.Exit()
        this = ToolsManager
        this.m_data = {}
        MakeListener()
        AddListener()
        M.InitConfig()
        M.Refresh()
    end
end

function M.Exit()
    if this then
        RemoveLister()
        M.Clear()
        this.m_data = nil
    end
    this = nil
end

function M.InitConfig()
    this.config = {}
    this.config.tools_config = drive_tool_config.main
    for i,v in ipairs(this.config.tools_config) do
        for k,_v in pairs(drive_game_tool_server.main[v.id] or {}) do
            if not v[k] then
                v[k] = _v
            end
        end
    end
    dump(this.config.tools_config,"<color=white>道路配置</color>")
end

function M.GetToolsCfgById(tools_id)
    for k,v in ipairs(this.config.tools_config) do
        if v.id == tools_id then
            return v
        end
    end
end

function M.AddTools(tools_data)
    local tools_cfg = M.GetToolsCfgById(tools_data.tools_id)
    local tools_class = _G[tools_cfg.tools_anim_type]
    if not tools_class then 
        tools_class = ToolsBase
    end
    local tools_item = tools_class.Create(tools_data)
    local owner_type = tools_data.owner_type
    local owner_id = tools_data.owner_id
    local tools_id = tools_data.tools_id
    this.m_data.tools_map = this.m_data.tools_map or {}
    this.m_data.tools_map[owner_type] = this.m_data.tools_map[owner_type] or {}
    this.m_data.tools_map[owner_type][owner_id] = this.m_data.tools_map[owner_type][owner_id] or {}
    this.m_data.tools_map[owner_type][owner_id][tools_id] = tools_item
    return tools_item
end

function M.RemoveTools(tools_data)
    local tools_item = M.GetTools(tools_data)
    if not tools_item then return end
    local owner_type = tools_data.owner_type
    local owner_id = tools_data.owner_id
    local tools_id = tools_data.tools_id
    this.m_data.tools_map[owner_type][owner_id][tools_id] = nil
    tools_item:MyExit()
end

function M.RefreshTools(tools_data)
    local tools_item = M.GetTools(tools_data)
    if tools_item then
        tools_item:Refresh(tools_data)
    else
        M.AddTools(tools_data)
    end
end

function M.GetTools(tools_data)
    local owner_type = tools_data.owner_type
    local owner_id = tools_data.owner_id
    local tools_id = tools_data.tools_id
    if this.m_data.tools_map
    and this.m_data.tools_map[owner_type] 
    and this.m_data.tools_map[owner_type][owner_id] then
        return this.m_data.tools_map[owner_type][owner_id][tools_id]
    end
end

function M.GetAllTools()
    return this.m_data.tools_map
end

function M.GetToolsCount()
    local c = 0
    for owner_type,v in pairs(this.m_data.tools_map or {}) do
        for owner_id,v1 in pairs(v) do
            for tools_id,tools in pairs(v1) do
                local owner_data = {
                    owner_type = owner_type,
                    owner_id = owner_id
                }
                if DriveModel.CheckOwnerIsMe(owner_data) then
                    c = c + 1
                end
            end
        end
    end
    return c
end

function M.Refresh()
    if not DriveModel or not DriveModel.data then return end
    M.ClearUseed()
    --刷新车上的道具
    local players_info = DriveModel.data.players_info
    for seat_num,player_info in ipairs(players_info or {}) do
        for i,s_tools_data in ipairs(player_info.tools_data or {}) do
            local tools_data = {}
            tools_data.process_no = s_tools_data.process_no
            tools_data.father_process_no = s_tools_data.father_process_no
            tools_data.tools_id = s_tools_data.id
            tools_data.tools_num = s_tools_data.num
            tools_data.tools_spend_mp = s_tools_data.spend_mp
            tools_data.owner_id = player_info.seat_num
            tools_data.owner_type = DriveModel.OwnerType.player
            M.RefreshTools(tools_data)
        end
    end
    DriveToolsContainer.Refresh()
end

function M.Clear()
    if not this then return end
    for owner_type,v in pairs(this.m_data.tools_map or {}) do
        for owner_id,v1 in pairs(v) do
            for tools_id,tools in pairs(v1) do
                tools:MyExit()
            end
        end
    end
    this.m_data.tools_map = {}
end

function M.ClearUseed()
    local useed_tools = {}
    for owner_type,v in pairs(this.m_data.tools_map or {}) do
        for owner_id,v1 in pairs(v) do
            for tools_id,tools in pairs(v1) do
                if tools.tools_data.tools_num < 1 and not tools.drag_use then
                    tools:MyExit()
                    useed_tools[owner_type] = useed_tools[owner_type] or {}
                    useed_tools[owner_type][owner_id] = useed_tools[owner_type][owner_id] or {}
                    useed_tools[owner_type][owner_id][tools_id] = tools_id
                end
            end
        end
    end

    for owner_type,v in pairs(useed_tools) do
        for owner_id,v1 in pairs(v) do
            for tools_id,tools in pairs(v1) do
                this.m_data.tools_map[owner_type][owner_id][tools_id] = nil
            end
        end
    end
end

local convert_tools_data = function (data)
    local tools_data = {}
    local sd = data[data.key]
    tools_data.process_no = data.process_no
    tools_data.father_process_no = data.father_process_no
    tools_data.tools_id = sd.id
    tools_data.tools_num = sd.num
    tools_data.tools_spend_mp = sd.spend_mp
    tools_data.owner_id = sd.owner_data.owner_id
    tools_data.owner_type = sd.owner_data.owner_type
    tools_data.pos = sd.pos
    return tools_data
end

function M.on_play_process_tool_create(data)
    dump(data,"<color=white>道具创建</color>")
    if data.father_process_no then
        Event.Brocast("tools_manager_tool_create",data)
        local tools_data = convert_tools_data(data)
        local tools_item = M.GetTools(tools_data)
        if not tools_item then
            tools_data.act = M.act_enum.create
            M.RefreshTools(tools_data)
            local tools_item = M.GetTools(tools_data)
            if tools_item then
                tools_item:OnActStart()
            end
        else
            tools_data.act = M.act_enum.create
            tools_item:Refresh(tools_data)
            tools_item:OnActStart()
        end
    else
        this.award_box_tool_create_datas = this.award_box_tool_create_datas or {}
        this.award_box_tool_create_datas[#this.award_box_tool_create_datas + 1] = data
        Event.Brocast("process_play_next")
    end
end

function M.check_play_award_box_tool_create(cbk)
    if this.award_box_tool_create_datas and next(this.award_box_tool_create_datas) then
        if DrivePlayerManager and DrivePlayerManager.cur_panel then
            local parent = GameObject.Find("3DNode").transform
            DrivePlayerManager.cur_panel:PlayAwardBox(this.award_box_tool_create_datas,function(start_pos)
                for k,data in ipairs(this.award_box_tool_create_datas) do
                    local award_box_tool = newObject("award_box_tool_3d",parent)
                    award_box_tool.transform.position = start_pos
                    local image = this.GetToolsCfgById(data.tool_create.id).icon
                    award_box_tool.transform:Find("Image"):GetComponent("SpriteRenderer").sprite = GetTexture(image)
                    local seat_cars = DriveCarManager.GetCarBySeat(data.tool_create.owner_data.owner_id)

                    local target_pos = seat_cars[next(seat_cars)].transform.position
                    local _seq = DoTweenSequence.Create()
                    _seq:Append(award_box_tool.transform:DOMove(Vector3.New(target_pos.x,target_pos.y,-0.8),0.5))
                    _seq:AppendCallback(function()
                            destroy(award_box_tool.gameObject)
                            Event.Brocast("tools_manager_tool_create",data)
                            local tools_data = convert_tools_data(data)
                            local tools_item = M.GetTools(tools_data)
                            if not tools_item then
                                tools_data.act = M.act_enum.create
                                M.RefreshTools(tools_data)
                                local tools_item = M.GetTools(tools_data)
                                if tools_item then
                                    tools_item:OnActStart()
                                end
                            else
                                tools_data.act = M.act_enum.create
                                tools_item:Refresh(tools_data)
                                tools_item:OnActStart()
                            end
                        
                    end)
                end
                local seq = DoTweenSequence.Create()
                seq:AppendInterval(1.5)
                seq:AppendCallback(function()
                    this.award_box_tool_create_datas = nil
                end)
            end)
        end
    else
        if cbk then cbk() end
    end
end

function M.on_play_process_tool_use(data)
    dump(data,"<color=white>道具使用</color>")
    Event.Brocast("tools_manager_tool_use",data)
    local tools_data = convert_tools_data(data)
    tools_data.act = M.act_enum.use
    M.RefreshTools(tools_data)
    local tools_item = M.GetTools(tools_data)
    if tools_item then
        tools_item:OnActStart()
    end
end

function M.on_play_process_tool_dead(data)
    dump(data,"<color=white>道具消除</color>")
    local tools_data = convert_tools_data(data)
    tools_data.act = M.act_enum.dead
    M.RefreshSkill(tools_data)
    M.RemoveSkill(tools_data)
end