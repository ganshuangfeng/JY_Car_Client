local basefunc = require "Game/Common/basefunc"

DriveSelectRoadAwardPanel = basefunc.class()
local C = DriveSelectRoadAwardPanel
C.name = "DriveSelectRoadAwardPanel"

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
	dump(debug.traceback(),"<color=white>选择奖励退出</color>")
    if self.select_seq then
        self.select_seq:Kill()
        self.select_seq = nil
    end
    self:RemoveListener()
    destroy(self.gameObject)
	clear_table(self)
	instance = nil
end

function C:ctor(player_op)
	dump(player_op,"<color=white>player_op?????xxxS</color>")
	AudioManager.PlaySound(audio_config.drive.com_main_3xuanyi1.audio_name)
    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(DriveMapManager.GetMapAssets(C.name), parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.for_select_vec = player_op.for_select_vec
	self.player_op = player_op
    basefunc.GeneratingVar(self.transform, self)

    self:MakeListener()
    self:AddListener()
    self:InitUI()
	if self.close_btn then 
		if player_op.seat_num == DriveModel.data.seat_num then
			self.close_btn.gameObject:SetActive(true)
		else
			self.close_btn.gameObject:SetActive(false)
		end
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
        local cfg = RoadAwardManager.GetRoadAwardCfgByTypeId(v)
        self:SetRoadAwardView(cfg,v,k)
    end
end

function C:SetRoadAwardView(cfg,skill_id,obj_id)
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
	if tbl.obj_bg_img then
		local obj_level_bg_config = {
			[1] = "zd_sxy_bg_3_1",
			[2] = "zd_sxy_bg_3_2",
		}
		local obj_bg_img = obj_level_bg_config[cfg.level or 1]
		tbl.obj_bg_img.sprite = GetTexture(DriveMapManager.GetMapAssets(obj_bg_img))
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
	local road_id_to_type_config = {
		[1] = 4,
		[8] = 1,
		[12] = 2,
		[19] = 3
	}
	local car = DriveCarManager.cars[self.player_op.seat_num][next(DriveCarManager.cars[self.player_op.seat_num])]
	if car and car.car_data.pos then
		local type_img_no = road_id_to_type_config[DriveMapManager.ServerPosConversionRoadId(car.car_data.pos)]
		if type_img_no then
			for i = 1,4 do 
				if i ~= type_img_no then
					self["title_" .. i .. "_img"].gameObject:SetActive(false)
				else
					self["title_" .. i .. "_img"].gameObject:SetActive(true)
				end
			end
		end
	end

	for k,v in pairs(self.for_select_vec) do
		local cfg = RoadAwardManager.GetRoadAwardCfgByTypeId(v)
		if cfg then
			for i = 1, 3 do
				self["title_" .. i .. "_txt"].text = cfg.name or "获得新奖励"
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
	AudioManager.PlaySound(audio_config.drive.com_main_xuanzhong.audio_name)
    if obj_id and self.select_objs[obj_id] then
        local now_select = self.select_objs[obj_id]
        DriveModel.SendRequest("drive_game_player_op_req", {op_type = DriveModel.OPType.select_map_award, op_arg_1 = now_select.cfg.id})
    end
end

function C:PlayAnimClose(data)
	dump(data,"<color=yellow>PlayAnimClose</color>")
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
            self:MyExit()
        end
    )
	seq:OnForceKill(
		function ()
			Event.Brocast("process_play_next")
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