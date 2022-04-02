local basefunc = require "Game/Common/basefunc"

DriveSelectSkillPanel = basefunc.class()
local C = DriveSelectSkillPanel
C.name = "DriveSelectSkillPanel"

local instance
function C:AddListener()
    for proto_name, func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C.Init()
    return C.Create()
end

function C.Exit()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function C.Create(player_op)
    if not instance then
        instance = C.New(player_op)
    end
    instance:MyRefresh(player_op)
    return instance
end

function C.Instance()
    return instance
end

function C.PlayCloseAni(data)
    if not instance then
        C.Create(data.op_data)
    end
	instance:PlayAnimClose(data)
end

function C:MakeListener()
    self.listener = {}
    self.listener["model_correct_op_timeout"] = basefunc.handler(self, self.on_model_correct_op_timeout)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
    if self.select_seq then
        self.select_seq:Kill()
        self.select_seq = nil
    end
    self:RemoveListener()
    destroy(self.gameObject)
	clear_table(self)
    if instance then
        instance = nil
    end
end

local title_config = {
    [3] = {
        name = "发射井",
        img = "img_dfdd_1"
    },
    [4] = {
        name = "改造场",
        img = "img_gzzx_1"
    },
    [5] = {
        name = "雷达",
        img = "img_ld_1"
    },
    [6] = {
        name = "改造场",
        img = "img_gzzx_1"
    },
    [7] = {
        name = "工具箱",
        img = "zd_icon_bj"
    }
}

function C:ctor(player_op)
	dump(player_op,"<color=white>player_op?????xxxS</color>")
    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(DriveMapManager.GetMapAssets(C.name), parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.for_select_vec = player_op.for_select_vec
    -- add by ryx
    --现在改为用Lua实现的GeneratingVar
    basefunc.GeneratingVar(self.transform, self)

    self:MakeListener()
    self:AddListener()
    self:InitUI()
	if self.close_btn then 
		self.close_btn.onClick:AddListener(function()
			--关闭
			DriveModel.SendRequest("drive_game_player_op_req", {op_type = -1})
		end)
	end
end

function C:InitUI()
    local player_op = DriveModel.data.players_info[DriveModel.data.seat_num].player_op
    if not player_op then
        self.status_txt.text = "等待对手选择..."
    else
        self.status_txt.text = "请选择..."
    end
    self:MyRefresh()
end

function C:MyRefresh(player_op)
    if player_op and player_op.for_select_vec then
        self.for_select_vec = player_op.for_select_vec
    end

	self:RefreshTitle()
	self:RefreshSelectObjs()
end

function C:RefreshSelectObjs()
	if self.select_objs and next(self.select_objs) then
        for k, v in pairs(self.select_objs) do
            destroy(v.obj)
            v = nil
        end
        self.select_objs = nil
    end
    for k, v in ipairs(self.for_select_vec) do
        local cfg = SkillManager.GetSkillCfgById(v)
        if cfg and cfg.tool_id then
			self:SetToolView(cfg,v)
		else
			--选择技能
			self:SetSkillView(cfg,v,k)
        end
    end
end

function C:SetToolView(cfg,v)
	--技能创建道具
	local tool_cfg = ToolsManager.GetToolsCfgById(cfg.tool_id)
	local pre = GameObject.Instantiate(self.select_obj.gameObject, self.select_layout)
	local tbl = basefunc.GeneratingVar(pre.transform)
	for i = 1, 3 do
		tbl["skill_name_" .. i .. "_txt"].text = tool_cfg.name
		-- local pos = tbl["skill_name_" .. i .. "_txt"].transform.localPosition
		-- tbl["skill_name_" .. i .. "_txt"].transform.localPosition = Vector3.New(pos.x,pos.y - 90,pos.z)
	end
	tbl.icon_img.sprite = GetTexture(DriveMapManager.GetMapAssets(tool_cfg.icon))
	tbl.icon_img:SetNativeSize()
	tbl.icon_img.gameObject:SetActive(true)
	if tool_cfg.desc then
		tbl.skill_desc_txt.text = tool_cfg.desc
		tbl.skill_desc_txt.gameObject:SetActive(true)
	else
		tbl.skill_desc_txt.gameObject:SetActive(false)
	end
	tbl.skill_type_txt.text = "道具类型"
	tbl.select_skill_btn.onClick:AddListener(
		function()
			self:OnSelect(v)
		end
	)
	pre.gameObject:SetActive(true)
	self.select_objs = self.select_objs or {}
	self.select_objs[v] = {
		obj = pre.gameObject,
		tbl = tbl,
		cfg = cfg,
		tool_cfg = tool_cfg,
	}
end

function C:SetSkillView(cfg,skill_id,obj_id)
	--选择技能
	local pre = GameObject.Instantiate(self.select_obj.gameObject, self.select_layout)
	local tbl = basefunc.GeneratingVar(pre.transform)
	for i = 1, 3 do
		tbl["skill_name_" .. i .. "_txt"].text = cfg.name
	end
	if cfg.desc then
		tbl.skill_desc_txt.text = cfg.desc
		tbl.skill_desc_txt.gameObject:SetActive(true)
	else
		tbl.skill_desc_txt.gameObject:SetActive(false)
	end
	tbl.icon_img.sprite = GetTexture(DriveMapManager.GetMapAssets(cfg.icon))
	pre.gameObject:SetActive(true)
	self.select_objs = self.select_objs or {}
	self.select_objs[obj_id] = {
		obj = pre.gameObject,
		tbl = tbl,
		cfg = cfg,
		skill_id = skill_id,
		obj_id = obj_id
	}
	tbl.select_skill_btn.onClick:AddListener(
		function()
			self:OnSelect(obj_id)
		end
	)
end

function C:on_model_correct_op_timeout(data)
    self.timer_txt.text = math.floor(data.op_timeout) .. "S"
    if data.op_timeout == 0 then
        self:MyExit()
    end
end

function C:RefreshTitle()
    local only_skill = true
	for k, v in ipairs(self.for_select_vec) do
		local cfg = SkillManager.GetSkillCfgById(v)
		if cfg.tool_id then
			only_skill = false
			break
		end
	end
	local only_tools = true
	for k, v in ipairs(self.for_select_vec) do
		local cfg = SkillManager.GetSkillCfgById(v)
		if not cfg.tool_id then
			only_tools = false
			break
		end
	end

	local skill_center_id
	for k, v in ipairs(self.for_select_vec) do
		local id = math.floor(v / 1000)
		if id > 0 and title_config[id] then
			skill_center_id = id
			break
		end
	end

	dump(skill_center_id,"<color=yellow>技能中心？？？？？</color>")

	if skill_center_id then
		for i = 1, 3 do
            self["title_" .. i .. "_txt"].text = title_config[skill_center_id].name
			self["title_" .. i .. "_img"].gameObject:SetActive(false)
            if skill_center_id <= 3 then
                if i == skill_center_id then
                    self["title_" .. i .. "_img"].gameObject:SetActive(true)
                else
                    self["title_" .. i .. "_img"].gameObject:SetActive(false)
                end
            end
        end

		if title_config[skill_center_id].img == "img_dfdd_1" then
			self["title_" .. 1 .. "_img"].gameObject:SetActive(true)
		elseif title_config[skill_center_id].img == "img_gzzx_1" then
			self["title_" .. 2 .. "_img"].gameObject:SetActive(true)
		elseif title_config[skill_center_id].img == "img_ld_1" then
			self["title_" .. 3 .. "_img"].gameObject:SetActive(true)
		end
		
		self.title_img.gameObject:SetActive(false)
	else
		if #self.for_select_vec == 1 then
			local cfg = SkillManager.GetSkillCfgById(self.for_select_vec[1])
			local icon_name
			if cfg.tool_id then
				cfg = ToolsManager.GetToolsCfgById(cfg.tool_id)
				if cfg.icon then
					icon_name = cfg.icon
				end
			else
				if cfg.icon then
					icon_name = cfg.icon
				elseif cfg.skill_buff_icon then
					icon_name = cfg.skill_buff_icon
				end
			end
			if icon_name then
				self.title_img.sprite = GetTexture(DriveMapManager.GetMapAssets(icon_name))
				self.title_img.gameObject:SetActive(true)
			else
				self.title_img.gameObject:SetActive(false)
			end
		else
			if only_skill then
				--只有技能
				for i = 1, 3 do
					self["title_" .. i .. "_txt"].text = "获得新技能"
					self["title_" .. i .. "_img"].gameObject:SetActive(false)
				end
				self.title_img.gameObject:SetActive(false)
			elseif only_tools then
				--只有道具
				for i = 1, 3 do
					self["title_" .. i .. "_txt"].text = "获得新道具"
					self["title_" .. i .. "_img"].gameObject:SetActive(false)
				end
				self.title_img.gameObject:SetActive(false)
			else
				--有技能和道具
				for i = 1, 3 do
					self["title_" .. i .. "_txt"].text = "获技能道具"
					self["title_" .. i .. "_img"].gameObject:SetActive(false)
				end
				self.title_img.gameObject:SetActive(false)
			end
		end
	end
end

function C:OnSelect(obj_id)
    local player_op = DriveModel.data.players_info[DriveModel.data.seat_num].player_op
    if not player_op then
        TipsShowUpText.Create("当前不该你操作")
        return
    end
    if obj_id and self.select_objs[obj_id] then
        local now_select = self.select_objs[obj_id]
        DriveModel.SendRequest("drive_game_player_op_req", {op_type = DriveModel.OPType.select_skill, op_arg_1 = now_select.cfg.id})
    end
end

function C:PlayAnimClose(data)
	local select_id = data.op_arg_1
    local fx_time = 0.6
    local seq = DoTweenSequence.Create()
    self.select_seq = seq
    local now_select = self.select_objs[select_id]
    for k, v in pairs(self.select_objs) do
        if select_id == v.cfg.id then
            now_select = v
        end
    end
	if now_select then
		now_select.obj.transform:Find("dianji").gameObject:SetActive(true)
		now_select.obj.transform:Find("guangbi").gameObject:SetActive(true)
		seq:AppendInterval(fx_time)
		for k, v in pairs(self.select_objs) do
			if v.cfg.id ~= select_id then
				seq:Join(v.obj.transform:GetComponent("CanvasGroup"):DOFade(0, fx_time))
			end
		end
		seq:AppendCallback(
			function()
				self:PlayToolsFlay(now_select,data)
				now_select.obj.transform:Find("guangbi").gameObject:SetActive(false)
				now_select.obj.transform:Find("guangbi").gameObject:SetActive(true)
				now_select.obj.transform:Find("dianji").gameObject:SetActive(false)
			end
		)
	end
    seq:Join(self.transform:GetComponent("CanvasGroup"):DOFade(0, 0.5))
	if now_select then
		seq:Append(now_select.obj.transform:GetComponent("CanvasGroup"):DOFade(0, 0.7))
	end
    seq:AppendCallback(
        function()
            self.select_seq = nil
            Event.Brocast("process_play_next")
            self:MyExit()
        end
    )
end

function C:PlayToolsFlay(now_select,data)
	if data.seat_num ~= DriveModel.data.seat_num then return end
	if not now_select.tool_cfg then return end
	local tools_c = ToolsManager.GetToolsCount()
	if tools_c >= 4 then return end
	local parent = GameObject.Find("Canvas/GUIRoot/DrivePanel/@down_node/DriveToolsContainer/@bg_" .. tools_c + 1 .. "_img")
	local go = newObject("ToolsBase",parent.transform)
	local tf = go.transform
	tf.position = now_select.tbl.icon_img.transform.position
	local tbl = basefunc.GeneratingVar(tf)
	tbl.icon_img.sprite = GetTexture(DriveMapManager.GetMapAssets(now_select.tool_cfg.icon))
	AddCanvasAndSetSort(tbl.icon_img, 5)
	DriveAnimManager.FlyingToTarget(go,parent.transform.position,nil,1,1,function(  )
		destroy(go)
	end,function()
		destroy(go)
	end,0.5)
end