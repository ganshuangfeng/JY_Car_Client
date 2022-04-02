

local basefunc = require "Game/Common/basefunc"

ToolsBase = basefunc.class()
local M = ToolsBase
M.name = "ToolsBase"

function M.Create(tools_data)
	return M.New(tools_data)
end

function M:ctor(tools_data)
	self:MakeListener()
	self:AddListener()
	self:Refresh(tools_data)
	self:SetObjCheckFunc()
	self:InitUI()
end

function M:MyExit()
	self:RemoveListener()
	self:OnActStart()
	destroy(self.gameObject)
	clear_table(self)
end

function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:MakeListener()
	self.listener = {}
	self.listener["click_screen"] = basefunc.handler(self,self.on_click_screen)
	self.listener["logic_drive_game_process_data_msg_player_op"] = basefunc.handler(self,self.on_drive_game_process_data_msg_player_op)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:ScreenToWorldPoint(position)
	if not self.camera then
		self.camera = GameObject.Find("2DNode/2DCamera"):GetComponent("Camera")
	end
	return self.camera:ScreenToWorldPoint(position)
end

function M:ResetDrag()
	dump(debug.traceback(),"<color=yellow>ResetDrag</color>")
	-- self.tips.gameObject:SetActive(false)
	self.icon_img.transform.localPosition = Vector3.zero
	destroy(self.icon_img_canvas)
end

function M:OnDown(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnDown</color>")
	self.down_pos = self:ScreenToWorldPoint(data.position)
	-- self.tips.gameObject:SetActive(true)
end

function M:OnUp(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnUp</color>")
	-- self.tips.gameObject:SetActive(false)
	local word_pos = self:ScreenToWorldPoint(data.position)
	self:UseToolOnUp(word_pos)
	self:SelectRoad()
end

function M:OnBeginDrag(go,data)
	dump({go = go,data = data},"<color=yellow>OnBeginDrag</color>")
	self.icon_img_canvas = AddCanvasAndSetSort(self.icon_img,5)
	self.tips.gameObject:SetActive(false)
end

function M:OnDrag(go,data)
	dump({go = go,data = data},"<color=yellow>OnDrag</color>")
	if DriveModel.CheckIsMyOp() and not self.tool_useed then
		local word_pos = self:ScreenToWorldPoint(data.position)
		self.icon_img.transform.position = word_pos
		if self.tools_cfg.is_select ~= 1 then return end
		self:RefreshSelectRoadID(word_pos)
		self:UseToolOnDrag(word_pos)
	end
end

function M:OnEndDrag(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnEndDrag</color>")
end

function M:OnClick(go,data)
	dump({go = go,data = data},"<color=yellow>OnClick</color>")
	if not DriveModel.CheckIsMyOp() then
		if IsEquals(self.tips) then
			self.tips.gameObject:SetActive(not self.tips.gameObject.activeSelf)
		end
		return
	end
	if not self.select then
		self.select = true
		--选中状态
		self:RefreshSelect()
		return
	end
	--使用道具
	self:UseTool()
end

function M:on_click_screen(data)
	dump(data,"<color=yellow>on_click_screen</color>")
	dump(self.select,"<color=yellow>self.select</color>")
	if not DriveModel.CheckIsMyOp() then
		if IsEquals(self.tips) and self.tips.gameObject.activeSelf then
			self.tips.gameObject:SetActive(false)
		end
		return
	end
	if not IsEquals(self.icon_img) then
		if IsEquals(self.tips) and self.tips.gameObject.activeSelf then
			self.tips.gameObject:SetActive(false)
		end
		return 
	end
	--点击到道具不处理
	if data.is_pointer_over then
		local click_pos = DriveModel.ScreenToWorldPoint(data.click_position)
		click_pos = Vector3.New(click_pos.x,click_pos.y,0)
		local m_pos = Vector3.New(self.icon_img.transform.position.x,self.icon_img.transform.position.y,0)
		local dis = Vector3.Distance(m_pos,click_pos)
		if dis <= 80 then
			--点击到道具
			if IsEquals(self.tips) and self.tips.gameObject.activeSelf then
				self.tips.gameObject:SetActive(not self.tips.gameObject.activeSelf)
			end
			return
		end
	end

	if self.select then
		self.select = false
		--取消选中
		self:RefreshSelect()
	end
end

function M:RefreshSelect()
	self.tips.gameObject:SetActive(self.select)
	self.select_img.gameObject:SetActive(self.select)
end

function M:RefreshSelectRoadID(pos)
	if not self.drag_use then return end
	local vec_2d = Vector3.New(pos.x,pos.y,pos.z)
	self.select_road_id = DriveMapManager.GetInRoadID(vec_2d)
end

function M:UseToolOnDrag(pos)
	if self.tool_useed then return end
	local o_y = self.down_pos.y
	local t_y = pos.y
	local use_dis_y = 100 --向上移动释放技能像素
	-- dump({o_y = o_y,t_y = t_y},"<color=white>位置检验</color>")
	if t_y > o_y and t_y - o_y > use_dis_y then
		--使用道具
		if DriveModel.CheckIsMyOp()then
			self:UseTool()
			self.drag_use = true
		end
	end
end

function M:UseToolOnUp(pos)
	if self.tool_useed then return end
	local o_y = self.down_pos.y
	local t_y = pos.y
	local use_dis_y = 100 --向上移动释放技能像素
	-- dump({o_y = o_y,t_y = t_y},"<color=white>位置检验</color>")
	if t_y > o_y and t_y - o_y > use_dis_y then
		--使用道具
		if DriveModel.CheckIsMyOp()then
			self:UseTool()
		end
		self:ResetDrag()
	else
		DriveAnimManager.FlyingToTarget(self.icon_img.gameObject,self.transform.position,nil,0.4,1,function(  )
			if IsEquals(self.icon_img) then
				self:ResetDrag()
			end
		end,function()
			if IsEquals(self.icon_img) then
				self:ResetDrag()
			end
		end,0.1,20)
	end
end

function M:UseTool()
	dump(self.tools_cfg,"<color=white>使用道具</color>")
	self.select = false
	self.tool_useed = true
	--取消选中
	self:RefreshSelect()
	DriveModel.SendRequest("drive_game_player_op_req",{op_type = DriveModel.OPType.use_tool,op_arg_1 = self.tools_data.tools_id})
end

function M:SelectRoad()
	local cb = function(  )
		self.select_road_id = nil
		self.tool_useed = false
		self.drag_use = nil
		DriveAnimManager.FlyingToTarget(self.icon_img.gameObject,self.transform.position,nil,0.4,1,function(  )
			if IsEquals(self.icon_img) then
				self:ResetDrag()
			end
		end,function()
			if IsEquals(self.icon_img) then
				self:ResetDrag()
			end
			if self.tools_data and self.tools_data.tools_num < 1 then
				Event.Brocast("play_process_tools_dead",self.tools_data)
			end
		end,0.1,20)
	end

	if self.tools_cfg.is_select ~= 1 or not self.drag_use or not self.tool_useed or not self.select_road_id then 
		cb()	
		return
	end

	local player_op = DriveModel.data.players_info[DriveModel.data.seat_num].player_op
	local seat_num = DriveModel.data.seat_num
	for k,v in ipairs(DriveModel.data.players_info) do
		if v.player_op then
			player_op = v.player_op
			seat_num = v.seat_num
		end
	end
	if not player_op then
		return
	end

	if player_op.op_type == DriveModel.OPType.select_road or player_op.op_type == DriveModel.OPType.select_clear_barrier then
		--选择道路
		local s_road_id = DriveMapBoardItem.GetServerRoadId(self.select_road_id)
		if DriveModel.data.players_info[DriveModel.data.seat_num].player_op then
			local optype = DriveModel.data.players_info[DriveModel.data.seat_num].player_op.op_type
			DriveModel.SendRequest("drive_game_player_op_req",{op_type = optype,op_arg_1 = s_road_id})
		end
	end
	cb()
end

function M:SetStyle()
	self.icon_img.sprite = GetTexture(DriveMapManager.GetMapAssets(self.tools_cfg.icon))
	self.tips_icon_img.sprite = GetTexture(DriveMapManager.GetMapAssets(self.tools_cfg.icon))
end

function M:InitUI(parent)
	if self.init_ui then return end
	if not DriveModel.CheckOwnerIsMe(self.tools_data) then return end
	--自己的道具
	local parent = parent or GameObject.Find("Canvas/GUIRoot/DrivePanel/@down_node/DriveToolsContainer/@layout/@tools_layout")
	if not IsEquals(parent) or IsEquals(self.gameObject) then return end

	self.init_ui = true
	self.gameObject = newObject("ToolsBase",parent.transform)
	self.gameObject.name = self.tools_data.tools_id
	self.transform = self.gameObject.transform
	basefunc.GeneratingVar(self.transform, self)
	self:SetStyle()
	self.name_txt.text = self.tools_cfg.name
	self.tips_name_txt.text = self.tools_cfg.name
	self.tips_desc_txt.text = self.tools_cfg.desc
	EventTriggerListener.Get(self.icon_img.gameObject).onDown = basefunc.handler(self, self.OnDown)
	EventTriggerListener.Get(self.icon_img.gameObject).onUp = basefunc.handler(self, self.OnUp)
	EventTriggerListener.Get(self.icon_img.gameObject).onBeginDrag = basefunc.handler(self, self.OnBeginDrag)
	EventTriggerListener.Get(self.icon_img.gameObject).onDrag = basefunc.handler(self, self.OnDrag)
	EventTriggerListener.Get(self.icon_img.gameObject).onEndDrag = basefunc.handler(self, self.OnEndDrag)
	EventTriggerListener.Get(self.icon_img.gameObject).onClick = basefunc.handler(self, self.OnClick)
end

function M:RefreshView(parent)
	if not DriveModel.CheckOwnerIsMe(self.tools_data) then return end
	--自己的道具
	if not self.init_ui then
		self:InitUI(parent)
	end
	self.num_txt.text = self.tools_data.tools_num
	self.spend_mp_txt.text = self.tools_data.tools_spend_mp
	if tonumber(self.tools_data.tools_num) <= 0 then
		self.gameObject:SetActive(false)
	end
	self:RefreshSelect()
end

function M:Refresh(tools_data)
	self.tools_data = tools_data or self.tools_data
	if self.tools_data.tools_id then
		self.tools_cfg = ToolsManager.GetToolsCfgById(self.tools_data.tools_id)
	end
	if not self.tools_cfg then
		dump(self.tools_data,"<color=red>技能配置错误tools_data</color>")
	end
end

function M:OnActStart(act)
	local act = act or self.tools_data.act
	if act == ToolsManager.act_enum.create then
		self:SetCreateData()
		self:OnCreateBefore()
	elseif act == ToolsManager.act_enum.dead then
		self:SetDeadData()
		self:OnDead()
	elseif act == ToolsManager.act_enum.use then
		self:SetUseData()
		self:OnUse()
	else
		dump(act,"<color=red>不存在的tools_act</color>")
		self:OnActEnd()
	end
end

function M:OnCreateBefore()
	-- if not DriveModel.CheckOwnerIsMe(self.tools_data) then return end
	local all_tools = ToolsManager.GetAllTools()
	local m_t_c = 0
	if all_tools[self.tools_data.owner_type] and all_tools[self.tools_data.owner_type][self.tools_data.owner_id] then
		for k,v in pairs(all_tools[self.tools_data.owner_type][self.tools_data.owner_id] or {}) do
			m_t_c = m_t_c + 1
		end
	end

	local get_props_ani = function(pos,callback)
		if IsEquals(self.gameObject) and tonumber(self.tools_data.tools_num) <= 1 then
			self.gameObject:SetActive(false)
		end
		local fx_pre = newObject("get_props",GameObject.Find("Canvas/GUIRoot/DrivePanel/@center_node/@skill_parent").transform)
		fx_pre.transform.position =  DriveModel.Get3DTo2DPoint({x = pos.x,y = pos.y + 0.8,z = pos.z})
		local fx_icon_img = fx_pre.transform:Find("fx/@icon_img"):GetComponent("Image")
		fx_icon_img.sprite = GetTexture(DriveMapManager.GetMapAssets(self.tools_cfg.icon))
		local fx_name_txt = fx_pre.transform:Find("fx/@name_txt"):GetComponent("Text")
		fx_name_txt.text = self.tools_cfg.name
		-- if m_t_c > 4 then
		-- 	local _img = fx_pre.transform:Find("fx/@bg_img"):GetComponent("Image")
		-- 	_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zs_img_zzsy_bg"))
		-- 	_img = fx_pre.transform:Find("fx/@title_img"):GetComponent("Image")
		-- 	_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zs_img_zzsy"))
		-- 	_img:SetNativeSize()
		-- 	_img = nil
		-- end
		local move_y = 100
		local speed = 1
		local seq = DoTweenSequence.Create()
		fx_pre.transform:GetComponent("CanvasGroup").alpha = 0
		fx_pre.transform.localScale = Vector3.New(3,3,1)
		if self.tools_data and self.tools_data.father_process_no then
			local father_process = DriveLogicProcess.get_process_data_by_process_no(self.tools_data.father_process_no)
			if father_process.road_award_change and father_process.road_award_change.data_type == 3 then
				--是从道具箱里获得的奖励，播放摇奖动画
				seq:AppendCallback(function()
					AudioManager.PlaySound(audio_config.drive.com_main_map_gongjuxiangyaojiang.audio_name)
					local pos_3d = DriveMapManager.ServerPosConversionSkillVector(DriveMapManager.ServerPosConversionMapPos(father_process.road_award_change.pos))
					local fx_pos = DriveModel.Get3DTo2DPoint(Vector3.New(pos_3d.x,pos_3d.y + 2,pos_3d.z))
					DriveAnimManager.PlayGetToolsAwardFx(self.tools_data.tools_id,fx_pos)
				end)
				seq:AppendInterval(5)
			end
		end
		seq:AppendCallback(function()
            AudioManager.PlaySound(audio_config.drive.com_main_map_huodedaoju.audio_name)
		end)
		seq:Append(fx_pre.transform:DOScale(Vector3.New(0.4,0.4,1),0.2/speed))
		seq:Join(fx_pre:GetComponent("CanvasGroup"):DOFade(1,0.2/speed))
		seq:Append(fx_pre.transform:DOScale(Vector3.New(0.8,0.8,1),0.1/speed))
		seq:Append(fx_pre.transform:DOLocalMoveY(fx_pre.transform.localPosition.y + move_y,2.5/speed))
		seq:Insert(1.7,fx_pre:GetComponent("CanvasGroup"):DOFade(0,1))
		seq:OnForceKill(function()
			self:OnCreate()
			if callback then
				callback()
			end
			if IsEquals(self.gameObject) then
				self.gameObject:SetActive(true)
			end
			destroy(fx_pre)
		end)
	end

	local cars = DriveCarManager.GetCarBySeat(self.tools_data.owner_id)
	--道具槽已满
	if cars and next(cars) then
		for seat_num,car in ipairs(cars) do
			get_props_ani(car.transform.position)
		end
	end
end

---创建时回调，默认在地图上创建一个
function M:OnCreate()
	self:OnActEnd()
end

---移除时回调，默认在地图上移除
function M:OnDead()
	self:OnActEnd()
end

---触发时回调
function M:OnUse()
	self:OnUseBefore()
end

---技能前摇，在子类中重写
function M:OnUseBefore()
	--在这里将未实现的技能的数据set_use
    local tools_data = self.tools_data
	local data = DriveLogicProcess.get_process_data_by_father_process_no(tools_data.process_no)
	if data and next(data) then
		for k,v in ipairs(data) do
			if not (v.player_op or v.status_change or v.buff_create or v.skill_create) then
				DriveLogicProcess.set_process_data_use(v.process_no)
			end
		end
	end
	local use_props_anim = function(pos,callback)
		if IsEquals(self.gameObject) and tonumber(self.tools_data.tools_num) <= 0 then
			self.gameObject:SetActive(false)
		end
		AudioManager.PlaySound(audio_config.drive.com_main_map_shiyongdaoju.audio_name)
		local fx_pre = newObject("use_props",GameObject.Find("Canvas/LayerLv3").transform)
		fx_pre.transform.position = DriveModel.Get3DTo2DPoint({x = pos.x,y = pos.y + 0.8,z = pos.z})
		local fx_icon_img = fx_pre.transform:Find("fx/@icon_img"):GetComponent("Image")
		fx_icon_img.sprite = GetTexture(DriveMapManager.GetMapAssets(self.tools_cfg.icon))
		local fx_name_txt = fx_pre.transform:Find("fx/@name_txt"):GetComponent("Text")
		fx_name_txt.text = self.tools_cfg.name
		local move_y = 100
		local speed = 1
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(2.2)
		seq:InsertCallback(1.8,function()
			if callback then
				callback()
			end
		end)
		seq:OnForceKill(function()
			destroy(fx_pre)
		end)
	end

	local cars = DriveCarManager.GetCarBySeat(self.tools_data.owner_id)
	--道具槽已满
	if cars and next(cars) then
		for seat_num,car in ipairs(cars) do
			use_props_anim(car.transform.position,function()
				self:OnUseMain()
			end)
		end
	end
end

---技能主效果，在子类中重写
function M:OnUseMain()
	dump("main_anim_playing")
	self:OnUseEnd()
end

---技能后摇，在子类中重写
function M:OnUseEnd()
	dump("end_anim_playing")
	self:OnActEnd()
end

function M:OnActEnd()
	self.tools_data.act = nil
	Event.Brocast("process_play_next")
	--道具使完
	if not self.drag_use and self.tools_data and self.tools_data.tools_num < 1 then
		Event.Brocast("play_process_tools_dead",self.tools_data)
	end
end

function M:SetCreateData()
	self.tools_data.act = ToolsManager.act_enum.create
end

function M:SetUseData()
	self.tools_data.act = ToolsManager.act_enum.use
end

function M:SetDeadData()
	self.tools_data.act = ToolsManager.act_enum.dead
end

function M:SetObjCheckFunc()
	
end

function M:GetObj(check_use)
	local obj_datas = DriveLogicProcess.get_process_data_by_father_process_no(self.tools_data.process_no)
    if obj_datas and next(obj_datas) then
		for i,obj_data in ipairs(obj_datas) do
			if obj_data and (not check_use or (check_use and not obj_data.use)) then
				if self.obj_check_func and self.obj_check_func(obj_data) then
					return obj_data
				elseif not self.obj_check_func then
					return obj_data
				end
			end
		end
    end
end

function M:GetObjs()
	local obj_datas = DriveLogicProcess.get_process_data_by_father_process_no(self.tools_data.process_no)
	local _obj_datas = {}
    if obj_datas and next(obj_datas) then
		for i,obj_data in ipairs(obj_datas) do
			if self.obj_check_func and self.obj_check_func(obj_data) then
				_obj_datas[#_obj_datas + 1] = obj_data
			elseif not self.obj_check_func then
				_obj_datas[#_obj_datas + 1] = obj_data
			end
		end
    end
	return _obj_datas
end

function M:PlayObjData(obj_data,callback,funcs,other_data)
	if obj_data then
		dump(obj_data,"<color=yellow>tools obj: </color>")
		DriveLogicProcess.on_process_play_by_no(obj_data,funcs,other_data)
	end
	if callback and type(callback) == "function" then
		callback()
	end
end

function M:PlayObj(callback,funcs)
	local obj_data = self:GetObj()
	if obj_data then
		dump(obj_data,"<color=yellow>tools obj: </color>")
		DriveLogicProcess.on_process_play_by_no(obj_data,funcs)
	end
	if callback and type(callback) == "function" then
		callback()
	end
end

function M:PlayObjs(callback,funcs)
	local obj_datas = self:GetObjs()
    if obj_datas and next(obj_datas) then
		for i,obj_data in ipairs(obj_datas) do
			if obj_data then
				dump(obj_data,"<color=yellow>tools obj: </color>")
				DriveLogicProcess.on_process_play_by_no(obj_data,funcs)
			end
		end        
    end
	if callback and type(callback) == "function" then
		callback()
	end
end

function M:on_drive_game_process_data_msg_player_op(data)
	if not self.drag_use then return end

	local player_op = DriveModel.data.players_info[DriveModel.data.seat_num].player_op
	local seat_num = DriveModel.data.seat_num
	for k,v in ipairs(DriveModel.data.players_info) do
		if v.player_op then
			player_op = v.player_op
			seat_num = v.seat_num
		end
	end
	if not player_op then
		return
	end

	if player_op.op_type == DriveModel.OPType.select_road or player_op.op_type == DriveModel.OPType.select_clear_barrier then

	else
		self.select_road_id = nil
		self.tool_useed = false
		if self.tools_data and self.tools_data.tools_num < 1 then
			Event.Brocast("play_process_tools_dead",self.tools_data)
		end
	end
end