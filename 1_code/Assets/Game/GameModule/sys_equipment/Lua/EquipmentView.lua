-- 创建时间:2018-05-30

local basefunc = require "Game.Common.basefunc"
EquipmentView = basefunc.class()
local M = EquipmentView
M.name = "EquipmentView"
local instance
function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeListener()
    self.listener = {}
	self.listener["model_query_drive_all_equipment_response"] = basefunc.handler(self,self.on_query_drive_all_equipment)
    self.listener["model_query_drive_equipment_data_response"] = basefunc.handler(self,self.on_query_drive_equipment_data)
    self.listener["model_drive_equipment_up_level_response"] = basefunc.handler(self,self.on_drive_equipment_up_level)
    self.listener["model_drive_equipment_up_star_response"] = basefunc.handler(self,self.on_drive_equipment_up_star)
    self.listener["model_drive_equipment_load_response"] = basefunc.handler(self,self.on_drive_equipment_load)
    self.listener["model_drive_equipment_unload_response"] = basefunc.handler(self,self.on_drive_equipment_unload)
    self.listener["model_on_drive_equipment_data_change"] = basefunc.handler(self,self.on_drive_equipment_data_change)
    self.listener["model_drive_car_data_change"] = basefunc.handler(self,self.on_model_drive_car_data_change)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M.Create(parm)
	if instance then
		instance:Exit()
	end
	instance = nil
	instance = M.New(parm)
	return instance
end

function M.Close()
	if instance then
		instance:Exit()
	end
	instance = nil
end

function M:ctor(parm)
	local parent = GameObject.Find("Canvas/LayerLv1/HallPanel/@view_node").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	basefunc.GeneratingVar(self.transform, self)
	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function M:Exit()
	if self.equipment_load_seq then
		self.equipment_load_seq:Kill()
		self.equipment_load_seq = nil
	end
	if self._equipment_load_seq then
		self._equipment_load_seq:Kill()
		self._equipment_load_seq = nil
	end
	if self.equipment_up_load_seq then
		self.equipment_up_load_seq:Kill()
		self.equipment_up_load_seq = nil
	end
	self.CarShow:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
	instance = nil
end

function M:MyExit()
	self:Exit()
end

function M:InitUI()
	--初始化UI设置
	self.CarShowBG = newObject("CarShowBG",self.car_show_node)
	local c_car = SysCarManager.GetCurCar()
	self.CarShow = CarShow.Create({parent = self.car_show_node,car_id = c_car.car_id,car_star = c_car.car_star})
	self:RefreshUI()
end

function M:RefreshUI()
	self:RefreshCar()
	self:RefreshCarEquipment()
	self:RefreshAllEquipment()
end

function M:RefreshCar()
	local cur_car = SysCarManager.GetCurCar()
	local car_id = cur_car.car_id
	local car_data = cur_car.car_data
	local car_up_data = SysCarUpgradeManager.GetCarData(car_id)
	local car_up_cfg = SysCarUpgradeManager.GetCarUpgradeCfg(car_id)
	local car_cfg = SysCarManager.GetCarCfg({car_type_id = car_id})

	self.at_txt.text = car_data.at

	self.sp_txt.text = car_data.sp

	self.hp_txt.text = car_data.hp
	if car_up_data.base_data.level then
		self.level_txt.text = car_up_data.base_data.level .. "/" .. car_up_cfg.star_rule[car_data.base_data.star].max_level
	end

	self.name_txt.text = car_cfg.name
	self.type_txt.text = car_cfg.tag_name
	local eq_star = self.eq_star or self.transform:Find("EquipmentStar")
	local star
	for i=0,4 do
		star = eq_star.transform:GetChild(i)
		if IsEquals(star) then
			star.gameObject:SetActive(car_up_data.base_data.star >= i + 1)
		end
	end
end

function M:RefreshCarEquipment()
	local ce = EquipmentModel.GetCarEquiment()
	self.car_equipment = self.car_equipment or {}

	local destroy_no = {}
	for k,v in pairs(self.car_equipment) do
		if not ce[k] then
			--没有创建
			destroy_no[k] = k
		end
	end

	for k,v in pairs(destroy_no) do
		destroy(self.car_equipment[k].gameObject)
		self.car_equipment[k] = nil
	end

	local create_no = {}
	for k,v in pairs(ce) do
		if not self.car_equipment[k] then
			create_no[k] = k
		end
	end

	local parent
	for k,v in pairs(create_no) do
		local main_cfg = EquipmentModel.GetMainCfgByID(ce[k].id)
		if main_cfg.slot == "A" then
			parent = self.arms
		elseif main_cfg.slot == "B" then
			parent = self.chassis
		elseif main_cfg.slot == "C" then
			parent = self.engine
		elseif main_cfg.slot == "D" then
			parent = self.steering
		end
		--创建道具
		self.car_equipment[k] = EquipmentItem.Create(ce[k],parent)
	end
end

function M:RefreshAllEquipment()
	local ae = EquipmentModel.GetAllNotUseBaseData()
	self.all_equipment = self.all_equipment or {}

	local destroy_no = {}
	for k,v in pairs(self.all_equipment) do
		if not ae[k] then
			--没有创建
			destroy_no[k] = k
		end
	end

	for k,v in pairs(destroy_no) do
		destroy(self.all_equipment[k].gameObject)
		self.all_equipment[k] = nil
	end

	local create_no = {}
	for k,v in pairs(ae) do
		if not self.all_equipment[k] then
			create_no[k] = k
		end
	end

	local parent = self.ae_content
	for k,v in pairs(create_no) do
		--创建道具
		self.all_equipment[k] = EquipmentItem.Create(ae[k],parent)
	end
	
	--排序
	self:SortAllEquipment()
end

function M:SortAllEquipment()
	local list = EquipmentModel.SortEquipment(self.all_equipment)
	for i,v in ipairs(list) do
		self.all_equipment[v.no].transform:SetAsLastSibling()
	end
end

function M:on_query_drive_all_equipment(data)
	self:RefreshUI()
end

function M:on_query_drive_equipment_data(data)
    self:RefreshUI()
end

function M:on_drive_equipment_up_level(data)
    self:RefreshUI()
end

function M:on_drive_equipment_up_star(data)
	self:RefreshUI()
end

function M:on_drive_equipment_load(data)
	if data and data.base_data then
		local item = self.all_equipment[data.base_data.no]
		local main_cfg = EquipmentModel.GetMainCfgByID(data.base_data.id)
		local target_item
		if self.car_equipment then
			for k,v in pairs(self.car_equipment) do
				local v_cfg = EquipmentModel.GetMainCfgByID(v.data.id)
				if v_cfg.slot == main_cfg.slot then
					target_item = v
					break
				end
			end
		end
		local target
		if main_cfg.slot == "A" then
			target = self.arms
		elseif main_cfg.slot == "B" then
			target = self.chassis
		elseif main_cfg.slot == "C" then
			target = self.engine
		elseif main_cfg.slot == "D" then
			target = self.steering
		end
		self:PlayCarEquipmentLoad(item,target,target_item,function()
			self:RefreshUI()
		end)
	else
		self:RefreshUI()
	end
end

function M:on_drive_equipment_unload(data)
	if data and data.base_data then
		local item
		local main_cfg = EquipmentModel.GetMainCfgByID(data.base_data.id)
		if self.car_equipment then
			for k,v in pairs(self.car_equipment) do
				local v_cfg = EquipmentModel.GetMainCfgByID(v.data.id)
				if v_cfg.slot == main_cfg.slot then
					item = v
					break
				end
			end
		end
		self:PlayCarEquipmentUpload(item,function()
			self:RefreshUI()
		end)
	else
		self:RefreshUI()
	end
end

function M:on_drive_equipment_data_change(data)
	if self.equipment_load_seq or self.equipment_up_load_seq then return end
	self:RefreshUI()
end

function M:PlayCarEquipmentLoad(item,target,target_item,cbk)
	local new_item = GameObject.Instantiate(item.gameObject,GameObject.Find("Canvas/LayerLv5").transform)
	new_item.gameObject:SetActive(false)
	self.equipment_load_seq = DoTweenSequence.Create()
	self.equipment_load_seq:AppendInterval(0.1)
	self.equipment_load_seq:AppendCallback(function()
		new_item.transform.position = item.transform.position
		new_item.gameObject:SetActive(true)
		item.gameObject:SetActive(false)
	end)
	self.equipment_load_seq:Append(new_item.transform:DOScale(Vector3.New(1.2,1.2,1.2),0.1))
	self.equipment_load_seq:Append(new_item.transform:DOMove(target.transform.position,0.4))
	self.equipment_load_seq:Append(new_item.transform:DOScale(Vector3.New(1,1,1),0.2))
	local new_item_fx
	self.equipment_load_seq:AppendCallback(function()
		new_item_fx = newObject("LG_zhunagbei",target.transform)
	end)
	if target_item then
		local target_item_target_pos = new_item.transform.position
		self._equipment_load_seq = DoTweenSequence.Create()
		local new_target_item = GameObject.Instantiate(target_item.gameObject,GameObject.Find("Canvas/LayerLv5").transform)
		new_target_item.gameObject:SetActive(false)
		self._equipment_load_seq:AppendInterval(0.1)
		self._equipment_load_seq:AppendCallback(function()
			new_target_item.transform.position = target_item.transform.position
			new_target_item.gameObject:SetActive(true)
			target_item.gameObject:SetActive(false)
		end)
		self._equipment_load_seq:Append(new_target_item.gameObject.transform:DOMove(Vector3.New(0,-300,0),0.4))
		self._equipment_load_seq:Insert(0.2,new_target_item.transform:GetComponent("CanvasGroup"):DOFade(0,0.5))
		self._equipment_load_seq:AppendCallback(function()
			if IsEquals(target_item.gameObject) then
				target_item.gameObject:SetActive(true)
			end
		end)
		self._equipment_load_seq:AppendInterval(1)
		self._equipment_load_seq:OnForceKill(function()
			if IsEquals(new_target_item) then destroy(new_target_item) end
			self._equipment_load_seq = nil
		end)

	end
	self.equipment_load_seq:AppendCallback(function()
		item.gameObject:SetActive(true)
		if cbk then cbk() end
	end)
	self.equipment_load_seq:AppendInterval(1)
	self.equipment_load_seq:OnForceKill(function()
		if IsEquals(new_item_fx) then destroy(new_item_fx) end
		if IsEquals(new_item) then destroy(new_item) end
		self.equipment_load_seq = nil
	end)
end
function M:PlayCarEquipmentUpload(item,cbk)
	if item then
		self.equipment_up_load_seq = DoTweenSequence.Create()
		local new_target_item = GameObject.Instantiate(item.gameObject,GameObject.Find("Canvas/LayerLv5").transform)
		new_target_item.gameObject:SetActive(false)
		self.equipment_up_load_seq:AppendInterval(0.1)
		self.equipment_up_load_seq:AppendCallback(function()
			new_target_item.transform.position = item.transform.position
			new_target_item.gameObject:SetActive(true)
			item.gameObject:SetActive(false)
		end)
		self.equipment_up_load_seq:Append(new_target_item.gameObject.transform:DOMove(Vector3.New(0,-300,0),0.4))
		self.equipment_up_load_seq:Insert(0.2,new_target_item.transform:GetComponent("CanvasGroup"):DOFade(0,0.5))
		self.equipment_up_load_seq:InsertCallback(0.6,function()
			if IsEquals(item.gameObject) then
				item.gameObject:SetActive(true)
			end
			if cbk then cbk() end
		end)
		self.equipment_up_load_seq:AppendInterval(1)
		self.equipment_up_load_seq:OnForceKill(function()
			if IsEquals(new_target_item) then destroy(new_target_item) end
			self.equipment_up_load_seq = nil
		end)

	end

end

function M:on_model_drive_car_data_change(data)
	self:RefreshBaseNum(data)
end

function M:RefreshBaseNum(car_data)
	if not car_data or not next(car_data) then return end
	self.sp_txt.text = car_data.sp
	self.hp_txt.text = car_data.hp
	self.at_txt.text = car_data.at
end