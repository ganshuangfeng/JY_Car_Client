

local basefunc = require "Game/Common/basefunc"

EquipmentItem = basefunc.class()
local M = EquipmentItem
M.name = "EquipmentItem"

function M.Create(data,parent)
	return M.New(data,parent)
end

function M:ctor(data,parent)
	self:MakeListener()
	self:AddListener()
	self.data = data
	self:InitUI(parent)
	self:Refresh(data)
end

function M:MyExit()
	self:RemoveListener()
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
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:ScreenToWorldPoint(position)
	if not self.camera then
		self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
	end
	return self.camera:ScreenToWorldPoint(position)
end

function M:ResetDrag()
	dump(debug.traceback(),"<color=yellow>ResetDrag</color>")
	self.icon_img.transform.localPosition = Vector3.zero
	destroy(self.icon_img_canvas)
end

function M:OnBeginDrag(go,data)
	dump({go = go,data = data},"<color=yellow>OnBeginDrag</color>")
	self.icon_img_canvas = AddCanvasAndSetSort(self.icon_img,5)
end

function M:OnDrag(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnDrag</color>")
	if self.loaded then return end
	local word_pos = self:ScreenToWorldPoint(data.position)
	self.icon_img.transform.position = word_pos
end

function M:OnUp(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnUp</color>")
	self:LoadOnUp()
end

function M:OnClick(go,data)
	dump({go = go,data = data},"<color=yellow>OnClick</color>")
	GameManager.Goto({_goto = EquipmentController.key,goto_parm = "detial",data = self.data})
	-- if true then
	-- 	--加载
	-- 	self:Load()
	-- else
	-- 	--卸载
	-- 	self:Unload()
	-- end
end

function M:SetTriggerLuaTable()
	local cb = self.icon_img.gameObject:GetComponent("ColliderBehaviour")
	if not IsEquals(cb) then return end
	cb:SetLuaTable(self)
end

function M:OnTriggerEnter2D(collision)
	dump(collision,"<color=white>OnTriggerEnter2D collision</color>")
	if not collision then return end
	self.collision_name = tonumber(collision.transform.name)
end

function M:OnTriggerExit2D(collision)
	dump(collision,"<color=white>OnTriggerExit2D collision</color>")
	if not collision then return end
	self.collision_name = nil
end

function M:LoadOnUp(pos)
	if self.loaded then return end
	local b = self:CheckDragLoad()
	if not b then
		ComFlyAnim.FlyingToTarget(self.icon_img.gameObject,self.transform.position,nil,0.4,1,function(  )
			if IsEquals(self.icon_img) then
				self:ResetDrag()
			end
		end,function()
			if IsEquals(self.icon_img) then
				self:ResetDrag()
			end
		end,0.1,20)
		return 
	end

	self:Load()
	self:ResetDrag()
end

function M:CheckDragLoad()
	if self.collision_name then
		--拖动挂载
		if self.main_cfg.slot == "A" and self.collision_name == "@arms" then
			return true
		elseif self.main_cfg.slot == "B" and self.collision_name == "@chassis" then
			return true
		elseif self.main_cfg.slot == "C" and self.collision_name == "@engine" then
			return true
		elseif self.main_cfg.slot == "D" and self.collision_name == "@steering" then
			return true
		end
	end
end

--佩戴
function M:Load()
	self.loaded = true
	EquipmentModel.drive_equipment_load(self.data)
end

--卸下
function M:Unload()
	self.loaded = false
	EquipmentModel.drive_equipment_unload(self.data)
end

function M:InitUI(parent)
	if not IsEquals(parent) or IsEquals(self.gameObject) then return end
	self.gameObject = newObject("EquipmentItem",parent.transform)
	self.gameObject.name = self.data.no
	self.transform = self.gameObject.transform
	basefunc.GeneratingVar(self.transform, self)
	-- EventTriggerListener.Get(self.icon_img.gameObject).onBeginDrag = basefunc.handler(self, self.OnBeginDrag)
	-- EventTriggerListener.Get(self.icon_img.gameObject).onDrag = basefunc.handler(self, self.OnDrag)
	-- EventTriggerListener.Get(self.icon_img.gameObject).onUp = basefunc.handler(self, self.OnUp)
	-- EventTriggerListener.Get(self.icon_img.gameObject).onClick = basefunc.handler(self, self.OnClick)
	local btn = self.icon_img.transform:GetComponent("Button")
	btn.onClick:AddListener(
		function()
			self:OnClick()
		end
	)
	self:SetTriggerLuaTable()
end

function M:Refresh(data)
	self.data = data or self.data
	if self.data.id then
		self.client_cfg = EquipmentModel.GetEquipmentBaseCfgByID(self.data.id)
		self.main_cfg = EquipmentModel.GetMainCfgByID(self.data.id)
	end
	dump(self.client_cfg,"<color=white>self.client_cfg</color>")
	if not self.client_cfg or not self.main_cfg then
		dump(self.data,"<color=red>道具配置错误</color>")
	end

	self.name_txt.text = self.client_cfg.name
	self.icon_img.sprite = GetTexture(self.client_cfg.icon)
	local star_rules = EquipmentModel.GetStarRuleCfgByID(self.main_cfg.star_rule)
	local max_level = 70
	for k,v in ipairs(star_rules) do
		if v.star == self.data.star then 
			max_level = v.max_level
		end
	end
	self.level_txt.text = "LV." .. self.data.level
	for i=1,5 do
		self["star_" .. i].gameObject:SetActive(i <= self.data.star)
	end

	if self.main_cfg.slot == "A" then
		self.tag_img.sprite  = GetTexture("zb_zblx_wq")
	elseif self.main_cfg.slot == "B" then
		self.tag_img.sprite  = GetTexture("zb_zblx_dp")
	elseif self.main_cfg.slot == "C" then
		self.tag_img.sprite  = GetTexture("zb_zblx_yq")
	elseif self.main_cfg.slot == "D" then
		self.tag_img.sprite  = GetTexture("zb_zblx_fxp")
	end

	if self.main_cfg.quality == "S" then
		self.bg_img.sprite = GetTexture("zb_zbd_03")
	elseif self.main_cfg.quality == "A" then
		self.bg_img.sprite = GetTexture("zb_zbd_02")
	elseif self.main_cfg.quality == "B" then
		self.bg_img.sprite = GetTexture("zb_zbd_01")
	end
end

function M.RefreshEquipmentByData(obj,data)
	local t = {}
	basefunc.GeneratingVar(obj.transform, t)
	if data.id then
		t.client_cfg = EquipmentModel.GetEquipmentBaseCfgByID(data.id)
		t.main_cfg = EquipmentModel.GetMainCfgByID(data.id)
	end
	dump(data,"<color=yellow>车辆数据？？？？</color>")
	if not t.client_cfg or not t.main_cfg then
		dump(data,"<color=red>道具配置错误</color>")
	end

	t.name_txt.text = t.client_cfg.name
	t.icon_img.sprite = GetTexture(t.client_cfg.icon)
	local star_rules = EquipmentModel.GetStarRuleCfgByID(t.main_cfg.star_rule)
	local max_level = 70
	for k,v in ipairs(star_rules) do
		if v.star == data.star then 
			max_level = v.max_level
		end
	end
	t.level_txt.text = "LV." .. data.level .. "/" .. max_level 
	for i=1,5 do
		t["star_" .. i].gameObject:SetActive(i <= data.star)
	end

	if t.main_cfg.slot == "A" then
		t.tag_img.sprite  = GetTexture("zb_zblx_wq")
	elseif t.main_cfg.slot == "B" then
		t.tag_img.sprite  = GetTexture("zb_zblx_dp")
	elseif t.main_cfg.slot == "C" then
		t.tag_img.sprite  = GetTexture("zb_zblx_yq")
	elseif t.main_cfg.slot == "D" then
		t.tag_img.sprite  = GetTexture("zb_zblx_fxp")
	end

	if t.main_cfg.quality == "S" then
		t.bg_img.sprite = GetTexture("zb_zbd_03")
	elseif t.main_cfg.quality == "A" then
		t.bg_img.sprite = GetTexture("zb_zbd_02")
	elseif t.main_cfg.quality == "B" then
		t.bg_img.sprite = GetTexture("zb_zbd_01")
	end
end