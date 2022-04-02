local basefunc = require "Game/Common/basefunc"

DriveGameInfoPanel = basefunc.class()
local M = DriveGameInfoPanel
M.name = "DriveGameInfoPanel"
local instance
local start_pos = -60
local stop_pos = 0
local end_pos = 60
local life_time = 0.8

function M.Create(parent)
	--屏蔽信息
	if true then return end
	if instance then
		instance:MyExit()
	end
	instance = M.New(parent)
    return instance
end

function M.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M.Refresh()
	if instance then
		instance:MyRefresh()
		return
	end
	M.Create()
end

function M:AddListener()
    for proto_name, func in pairs(self.listener) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeListener()
    self.listener = {}
	self.listener["play_process_tool_create"] = basefunc.handler(self,self.play_process_tool_create)
	self.listener["tools_manager_tool_use"] = basefunc.handler(self,self.play_process_tool_use)
	self.listener["skill_manager_skill_create"] = basefunc.handler(self,self.play_process_skill_create)
	-- self.listener["skill_manager_skill_trigger"] = basefunc.handler(self,self.play_process_skill_trigger)
	self.listener["model_pvp_signup_response"] = basefunc.handler(self,self.pvp_signup_response)
end

function M:RemoveListener()
    for proto_name, func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:MyExit()
	if self.timer_list then
		for k,v in pairs(self.timer_list) do
			if v then
				v:Stop()
			end
		end
	end
    self:RemoveListener()
    destroy(self.gameObject)
	clear_table(self)
end

function M:ctor(parent)
    local parent = parent or GameObject.Find("Canvas/GUIRoot/DrivePanel/@center_node/@game_status_parent").transform
    local obj = newObject(M.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeListener()
    self:AddListener()
    self:InitUI()
end

function M:InitUI()
	self.show_info_btn.onClick:AddListener(function()
		self.sv.gameObject:SetActive(not self.sv.gameObject.activeSelf)
	end)
    self:MyRefresh()
end

function M:MyRefresh()
	
end

function M:AddInfoData(data)
	self.info_list = self.info_list or {}
	table.insert(self.info_list,data)	
end

function M:RemoveInfoData()
	table.remove(self.info_list,1)
end

function M:GetInfoData()
	return self.info_list[1]
end

function M:CreateItem()
	local info_data = self:GetInfoData()
    if info_data then
        local b = GameObject.Instantiate(self.item, self.Mask)
        local txt = b.transform:Find("@info_txt"):GetComponent("Text")
        txt.text = info_data.content
        b.gameObject:SetActive(true)
		info_data.is_ani = true
		self.ani_obj = b
		self.ani_data = info_data
        self:Anim(b,info_data)
    end
end

function M:ShowInfo()
	local info = self:GetInfoData()
	if not info then return end
	if info.is_ani then return end
	if IsEquals(self.ani_obj) then
		self:AnimBack(self.ani_obj,self.ani_data)
	end
	self.ani_obj = nil
	self.ani_data = nil
	self:CreateItem()
end

function M:Anim(obj,info_data)
    local cha = stop_pos - start_pos
    local t
    t =
        Timer.New(
        function()
            local speed = cha * 0.02 / info_data.life_time
			if #self.info_list > 1 then
				speed = speed * #self.info_list
			end
            if IsEquals(obj) then
				local pos = obj.transform.localPosition
                obj.transform.localPosition = Vector3.New(pos.x, pos.y + speed, pos.z)
                if obj.transform.localPosition.y > stop_pos then
					t:Stop()
                	t = nil
					info_data.is_ani = false
					self:RemoveInfoData()
					self:ShowInfo()
                end
            else
                t:Stop()
                t = nil
            end
        end,
        0.02,
        -1
    )
    t:Start()
	self.timer_list = self.timer_list or {}
	table.insert(self.timer_list,t)
end

function M:AnimBack(obj,info_data)
    local cha = end_pos - stop_pos
    local t
    t =
        Timer.New(
        function()
            local speed = cha * 0.02 / info_data.life_time
			if #self.info_list > 1 then
				speed = speed * #self.info_list
			end
            if IsEquals(obj) then
				local pos = obj.transform.localPosition
                obj.transform.localPosition = Vector3.New(pos.x, pos.y + speed, pos.z)
                if obj.transform.localPosition.y > end_pos then
					obj.transform.parent = self.sv_content.transform
					obj.transform:SetAsLastSibling()
					t:Stop()
                	t = nil
					info_data.is_ani = false
                end
            else
                t:Stop()
                t = nil
            end
        end,
        0.02,
        -1
    )
    t:Start()
	self.timer_list = self.timer_list or {}
	table.insert(self.timer_list,t)
end

function M:play_process_skill_create(data)
	if data[data.key].skill_id <= 2000 or data[data.key].skill_id >= 6000 then
		--非路面技能
		return
	end

	if data[data.key].skill_id == 2016 then
		--工具箱
		return
	end

    if data and data.skill_create and data.father_process_no then
        local tool_pd = DriveLogicProcess.get_no_process({process_no = data.father_process_no})
        if tool_pd and tool_pd.tool_use then
			--使用道具生成技能
            return
        end
    end

	local str = DriveModel.CheckOwnerIsMe(data[data.key].owner_data) and "我" or "<color=red>对方</color>"
	str = str .. "获得"
	local cfg = SkillManager.GetSkillCfgById(data[data.key].skill_id)
	if cfg.tool_id then return end
	if cfg then
		str = str .. "<color=#2dff55>" .. cfg.name .. "</color>"
	end
	local data = {
		content = str,
		life_time = life_time
	}
	self:AddInfoData(data)
	self:ShowInfo()
end

function M:play_process_skill_trigger(data)
	if data[data.key].skill_id <= 2000 or data[data.key].skill_id >= 6000 then
		--非路面技能
		return
	end

	if data[data.key].skill_id == 2016 then
		--工具箱
		return
	end
	dump(debug.traceback(),"<color=white>堆栈</color>")
	dump(data,"<color=white>使用技能道具？？xxxx??????</color>")

	local skill_create_pd = DriveLogicProcess.get_no_process({process_no = data.father_process_no})
    if skill_create_pd and skill_create_pd.skill_create and skill_create_pd.father_process_no then
        local tool_pd = DriveLogicProcess.get_no_process({process_no = skill_create_pd.father_process_no})
        if tool_pd and tool_pd.tool_use then
            tool_cfg = ToolsManager.GetToolsCfgById(tool_pd[tool_pd.key].id)
			--使用道具触发的技能
			return
        end
    end

	local str = DriveModel.CheckOwnerIsMe(data[data.key].owner_data) and "我" or "<color=red>对方</color>"
	str = str .. "使用"
	local cfg = SkillManager.GetSkillCfgById(data[data.key].skill_id)
	if cfg.tool_id then return end

	dump(cfg,"<color=white>cfgJI嫩通过了解了克斯大道路口</color>")
	if cfg then
		str = str .. "<color=#2dff55>" .. cfg.name .. "</color>"
	end
	local data = {
		content = str,
		life_time = life_time
	}
	self:AddInfoData(data)
	self:ShowInfo()
end

function M:play_process_tool_create(data)
	dump(data,"<color=white>获得道具？？xxxx??????</color>")
	local str = DriveModel.CheckOwnerIsMe(data[data.key].owner_data) and "我" or "<color=red>对方</color>"
	str = str .. "获得道具"
	local cfg = ToolsManager.GetToolsCfgById(data[data.key].id)
	if cfg then
		str = str .. "<color=#FFD52D>" .. cfg.name .. "</color>"
	end
	local data = {
		content = str,
		life_time = life_time
	}
	self:AddInfoData(data)
	self:ShowInfo()
end

function M:play_process_tool_use(data)
	local str = DriveModel.CheckOwnerIsMe(data[data.key].owner_data) and "我" or "<color=red>对方</color>"
	str = str .. "使用道具"
	local cfg = ToolsManager.GetToolsCfgById(data[data.key].id)
	if cfg then
		str = str .. "<color=#FFD52D>" .. cfg.name .. "</color>"
	end
	local data = {
		content = str,
		life_time = life_time
	}
	self:AddInfoData(data)
	self:ShowInfo()
end

function M:pvp_signup_response(data)
	destroyChildren(self.sv_content)	
end