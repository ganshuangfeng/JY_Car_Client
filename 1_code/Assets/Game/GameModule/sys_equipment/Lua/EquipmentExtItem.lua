

local basefunc = require "Game/Common/basefunc"

EquipmentExtItem = basefunc.class()
local M = EquipmentExtItem
M.name = "EquipmentExtItem"

function M.Create(data,parent)
	return M.New(data,parent)
end

function M:ctor(data,parent)
	self:MakeListener()
	self:AddListener()
	self.data = data
	self.select = false
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
	self.listener["equipment_ext_item_auto_select"] = basefunc.handler(self,self.on_equipment_ext_item_auto_select)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:ResetDrag()
	dump(debug.traceback(),"<color=yellow>ResetDrag</color>")
	self.icon_img.transform.localPosition = Vector3.zero
	destroy(self.icon_img_canvas)
end

function M:OnClick(go,data)
	self.select = not self.select
	self.select_img.gameObject:SetActive(self.select)
	Event.Brocast("equipment_ext_item_select",{data = self.data,select = self.select})
end

function M:InitUI(parent)
	if not IsEquals(parent) or IsEquals(self.gameObject) then return end
	self.gameObject = newObject("EquipmentExtItem",parent.transform)
	self.gameObject.name = self.data.no
	self.transform = self.gameObject.transform
	basefunc.GeneratingVar(self.transform, self)
	EventTriggerListener.Get(self.icon_img.gameObject).onClick = basefunc.handler(self, self.OnClick)
end

function M:Refresh(data)
	self.data = data or self.data
	if self.data.id then
		self.client_cfg = EquipmentModel.GetEquipmentBaseCfgByID(self.data.id)
		self.main_cfg = EquipmentModel.GetMainCfgByID(self.data.id)
	end
	if not self.client_cfg or not self.main_cfg then
		dump(self.data,"<color=red>道具配置错误</color>")
	end

	self.name_txt.text = self.client_cfg.name
	self.icon_img.sprite = GetTexture(self.client_cfg.icon)
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

	self.select_img.gameObject:SetActive(self.select)
end

function M.RefreshEquipmentByData(obj,data)
	local t = {}
	basefunc.GeneratingVar(obj.transform, t)
	if data.id then
		t.client_cfg = EquipmentModel.GetEquipmentBaseCfgByID(data.id)
		t.main_cfg = EquipmentModel.GetMainCfgByID(data.id)
	end
	if not t.client_cfg or not t.main_cfg then
		dump(data,"<color=red>道具配置错误</color>")
	end

	t.name_txt.text = t.client_cfg.name
	t.icon_img.sprite = GetTexture(t.client_cfg.icon)
	t.level_txt.text = "LV." .. data.level
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

function M:on_equipment_ext_item_auto_select(data)
	if not data or not next(data) then return end
	if not data[self.data.no] then
		self.select = false
	else
		self.select = true
	end
	if IsEquals(self.select_img) then
		self.select_img.gameObject:SetActive(self.select)
	end

	Event.Brocast("equipment_ext_item_select",{data = self.data,select = self.select})
end