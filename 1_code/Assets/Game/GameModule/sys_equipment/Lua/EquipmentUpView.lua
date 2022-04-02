-- 创建时间:2018-05-30

local basefunc = require "Game.Common.basefunc"
EquipmentUpView = basefunc.class()
local M = EquipmentUpView
M.name = "EquipmentUpView"
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
    self.listener["equipment_ext_item_select"] = basefunc.handler(self,self.on_equipment_ext_item_select)
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
	self.data = parm.data
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	basefunc.GeneratingVar(self.transform, self)
	self:MakeListener()
	self:AddListener()
	self:Init()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function M:Exit()
	if self.DOTProcesse then
		self.DOTProcesse:Kill()
		self.DOTProcesse = nil
	end
	if self.up_level_seq then self.up_level_seq:Kill() end
	for k,v in pairs(self.all_equipment) do
		v:MyExit()
	end
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
	instance = nil
end

function M:Init()
	self.add_exp = self.add_exp or 0
	self.cur_up_level = self.data.level
	--初始化UI设置
	self.close_btn.onClick:AddListener(function()
		self:Exit()
	end)

	self.up_btn.onClick:AddListener(function()
		if not self.spend_no or not next(self.spend_no) then
			TipsShowUpText.Create("请先选择装备")
			return
		end
		local spend_no = {}
		for k,v in pairs(self.spend_no) do
			table.insert(spend_no,v)
		end

		local data = {
			no = self.data.no,
			spend_no = spend_no
		}

		local callback

		local up = function ()
			EquipmentModel.drive_equipment_up_level(data,callback)
			local fx_pre = newObject("anniu_tisheng_nei",self.up_btn.transform)
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(1)
			seq:AppendCallback(function()
				if IsEquals(fx_pre) then
					destroy(fx_pre)
				end
			end)
		end

		if self.data.owner_car_id then
			local car = SysCarManager.GetCurCar()
			dump({car_level = car.car_data.base_data.level,cur_up_level = self.cur_up_level},"<color=yellow>当前等级比较</color>")
			if car.car_data.base_data.level < self.cur_up_level then
				callback = function(data)
					dump(data,"<color=white>data?????????</color>")
					if data.result ~= 0 then return end
					local unload_data = {
						no = self.data.no
					}
					EquipmentModel.drive_equipment_unload(unload_data)
				end
			end
		end

		if callback then
			HintPanel.Create({msg = "无法安装比车辆等级更高的装备，是否确认继续提升？",
				show_yes_btn = true,
				yes_callback = function()
					up()
				end,
				show_close_btn = true,
				})
			return
		end

		up()
	end)

	self.auto_fill_btn.onClick:AddListener(function()
		dump("auto_fill_btn","<color=white>自动填充</color>")
		self:AutoFill()
	end)

	self.ext_slider = self.ext_slider.transform:GetComponent("Slider")
	self:Refresh()
end

function M:AutoFill()
	if not self.all_equipment_list or not next(self.all_equipment_list) then
		TipsShowUpText.Create("没有装备")
		return
	end

	local auto_fill = {}
	local auto_max_count = 8
	for i=#self.all_equipment_list,#self.all_equipment_list - auto_max_count, -1 do
		if not self.all_equipment_list[i] then
			break
		end
		auto_fill[#auto_fill + 1] = self.all_equipment_list[i]
	end
	self.spend_no = {}
	self.add_exp = 0
	self.cur_up_level = self.data.level
	dump(auto_fill,"<color=white>提升？？？？？</color>")
	for k,v in pairs(auto_fill) do
		self.spend_no[v.no] = v.no
		-- self.add_exp = self.add_exp + v.sold_exp
	end

	Event.Brocast("equipment_ext_item_auto_select",self.spend_no)
	-- self:RefreshExt()
end

function M:Refresh()
	self:RefreshData()
	self:RefreshEquiment()
	self:RefreshAttribute()
	self:RefreshExt()
	self:RefreshJingBi()
	self:RefreshCanUseEquiment()
	self:RefreshLevelUp()
end

function M:RefreshData()
	self.data = EquipmentModel.GetBaseDataByNo(self.data.no)
end

function M:RefreshLevelUp()
	local level_up_cfg,is_max = EquipmentModel.GetLevelUpSpend(self.data)
	if is_max then
		self.is_level_max = true
		self.up_level_lv_txt.color = Color.New(188/255,188/255,188/255,1)
		self.up_level_str_txt.color = Color.New(188/255,188/255,188/255,1)
		return
	end
	
	self.up_level_lv_txt.color = Color.white
	self.up_level_str_txt.color = Color.white
	if not level_up_cfg or not next(level_up_cfg) then
		self.jing_bi_level_up.gameObject:SetActive(false)
		self.diamond_level_up.gameObject:SetActive(false)
		self.gear_level_up.gameObject:SetActive(false)
		return
	end
	dump(level_up_cfg,"<color=yellow>level_up_cfg</color>")
	dump(MainModel.UserInfo,"<color=yellow>MainModel.UserInfo</color>")
	-- local asset_cfg = {
	-- 	jing_bi = "jing_bi",
	-- 	gear = "gear",
	-- 	diamond = "diamond"
	-- }
	-- for k,v in pairs(level_up_cfg) do
	-- 	if asset_cfg[k] then
	-- 		if not MainModel.UserInfo[k] or MainModel.UserInfo[k] < v then
	-- 			self[k .. "_level_up_num_txt"].color = Color.red
	-- 		end
	-- 		self[k .. "_level_up"].gameObject:SetActive(v > 0)
	-- 	end
	-- end
end

function M:RefreshEquiment(data)
	self.data = data or self.data
	if self.data.id then
		self.client_cfg = EquipmentModel.GetEquipmentBaseCfgByID(self.data.id)
		self.main_cfg = EquipmentModel.GetMainCfgByID(self.data.id)
	end
	if not self.client_cfg or not self.main_cfg then
		dump(self.data,"<color=red>道具配置错误</color>")
	end

	local obj = self.transform:Find("Top/@head_node/EquipmentItem")
	EquipmentItem.RefreshEquipmentByData(obj,self.data)
end

function M:RefreshAttribute()
	local attribute = EquipmentModel.GetEquipmentAttribute(self.data)
	dump(attribute,"<color=yellow>attribute</color>")
	for k,v in pairs(attribute) do
		self[k .. "_num_txt"].text = v
	end

	local attribute_next = EquipmentModel.GetEquipmentAttributeNext(self.data)
	for k,v in pairs(attribute_next) do
		self[k .. "_next_num_txt"].text = v
	end
end

function M:RefreshExt()
	self.add_exp = self.add_exp or 0
	self.cur_up_level = self.data.level
	self.now_level_txt.text = "LV." .. self.data.level
	self.up_level_txt.text = "LV." .. (self.data.level + 1)

	local now_ext = EquipmentModel.GetEquipmentExt(self.data)
	local next_ext = EquipmentModel.GetEquipmentExtNext(self.data)

	local need_total = now_ext
	local now_total = self.data.now_exp or 0
	self.ext_txt.text = (now_total + self.add_exp) .. "/" .. need_total
	self.ext_slider.value = (now_total + self.add_exp) / need_total

	local cur_data = basefunc.deepcopy(self.data)
	local all_total = (now_total + self.add_exp)
	local all_now_ext = now_ext
	local all_next_ext = next_ext
	local all_need = need_total
	local check_level
	check_level = function()
		if all_total > need_total then
			cur_data.level = cur_data.level + 1
			if cur_data.level > 70 then return end
			need_total = 0
			for i = self.data.level,cur_data.level do
				local _cur_data = basefunc.deepcopy(cur_data)
				_cur_data.level = i
				need_total = need_total +  EquipmentModel.GetEquipmentExt(_cur_data)
			end
			all_now_ext = EquipmentModel.GetEquipmentExt(cur_data)
			all_next_ext = EquipmentModel.GetEquipmentExtNext(cur_data)
			self.ext_txt.text = (now_total + self.add_exp) .. "/" .. need_total
			self.now_level_txt.text = "LV." .. cur_data.level
			self.up_level_txt.text = "LV." .. (cur_data.level + 1)
			check_level()
		else
			self.now_level_txt.text = "LV." .. cur_data.level
			self.up_level_txt.text = "LV." .. (cur_data.level + 1)
		end
	end
	check_level()
	
	local attribute_next = EquipmentModel.GetEquipmentAttributeNext(cur_data)
	for k,v in pairs(attribute_next) do
		self[k .. "_next_num_txt"].text = v
	end

	self.cur_up_level = cur_data.level
end

function M:RefreshCanUseEquiment()
	local ae = EquipmentModel.GetCanUseEquipment(self.data)
	dump(ae,"<color=yellow>升级可以使用的装备</color>")
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
		self.all_equipment[k] = EquipmentExtItem.Create(ae[k],parent)
	end

	--排序
	self:SortAllEquipment()
end

function M:SortAllEquipment()
	local list = EquipmentModel.SortEquipment(self.all_equipment)
	for i,v in ipairs(list) do
		self.all_equipment[v.no].transform:SetAsLastSibling()
	end
	self.all_equipment_list = list
end

function M:on_query_drive_all_equipment(data)
	self:Refresh()
end

function M:on_query_drive_equipment_data(data)
    self:Refresh()
end

function M:on_drive_equipment_up_level(data)
	self.spend_no = {}
	self.add_exp = 0
	self.cur_up_level = self.data.level
    self:Refresh()
end

function M:on_drive_equipment_up_star(data)
	self:Refresh()
end

function M:on_drive_equipment_load(data)
    self:Refresh()
end

function M:on_drive_equipment_unload(data)
	self:Refresh()
end

function M:on_drive_equipment_data_change(data)
	dump(data,"<color=red>on_drive_equipment_data_change</color>")
	if data.change_type == "up_level" then
		if self.up_level_seq then self.up_level_seq:Kill() end
		self.up_level_seq = DoTweenSequence.Create()
		local del_time = 1
		local seq = self.up_level_seq
		if data.base_data.level > self.data.level then
			seq:AppendCallback(function()
				self:PlayCarExp(self.ext_slider.value,1,(1 - self.ext_slider.value) * del_time)
			end)
		else
			seq:AppendCallback(function()
				self:PlayCarExp(self.ext_slider.value,data.base_data.now_exp / EquipmentModel.GetEquipmentExt(self.data),0.5 * del_time)
			end)
		end
		seq:AppendInterval((1 - self.ext_slider.value) * del_time)
		local jinyantiao = newObject("jinyantiao",self.ext_slider.transform)
		jinyantiao.gameObject:SetActive(false)
		if data.base_data.level > self.data.level then
			seq:AppendCallback(function()
				self.now_level_txt.text = "LV." .. self.data.level
				self.up_level_txt.text = "LV." .. (self.data.level + 1)
				jinyantiao.gameObject:SetActive(true)
				local SG_saoguang = newObject("SG_saoguang",self.head_node.transform)
			end)
			seq:AppendInterval(0.5)
		end
		seq:AppendInterval(0.1)
		seq:AppendCallback(function()
			self:Refresh()
		end)
		seq:OnForceKill(function()
			self.up_level_seq = nil
		end)
	else
		self:Refresh()
	end
end

function M:on_equipment_ext_item_select(data)
	self.spend_no = self.spend_no or {}
	self.add_exp = self.add_exp or 0
	self.cur_up_level = self.data.level
	if not data.select and self.spend_no[data.data.no] then
		self.spend_no[data.data.no] = nil
		self.add_exp = self.add_exp - data.data.sold_exp
	elseif data.select then
		self.spend_no[data.data.no] = data.data.no
		self.add_exp = self.add_exp + data.data.sold_exp
	end

	self:RefreshExt()
	self:RefreshJingBi()
end

function M:RefreshJingBi()
	local jb = 0
	self.jing_bi_level_up.gameObject:SetActive(true)
	self.jing_bi_level_up_num_txt.gameObject:SetActive(true)
	if not self.spend_no or not next(self.spend_no) then
		self.jing_bi_level_up_num_txt.text = jb
		return
	end

	local base_data
	local main_cfg
	for k,no in pairs(self.spend_no) do
		base_data = EquipmentModel.GetBaseDataByNo(no)
		if base_data then
			main_cfg = EquipmentModel.GetMainCfgByID(base_data.id)
			-- dump({jb = jb, base_data = base_data,exp_spend = main_cfg.exp_spend},"<color=yellow>升级金币设置</color>")
			jb = jb + base_data.sold_exp * main_cfg.exp_spend
		end
	end

	jb = math.floor(jb - 0.01 + 1)
	local my_jb = SysAssetModel.GetItemCount("jing_bi")
	if jb > my_jb then
		self.jing_bi_level_up_num_txt.text = "<color=red>" .. jb .."</color>"
	else
		self.jing_bi_level_up_num_txt.text = jb
	end
end

function M:PlayCarExp(start_v,end_v,duration,cbk)
	local cur_v = start_v
	if self.DOTProcesse then
		self.DOTProcesse:Kill()
		self.DOTProcesse = nil
	end
	self.DOTProcesse = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
			function(value)
				cur_v = start_v
				if IsEquals(self.ext_slider) then
					self.ext_slider.value = cur_v
				end
                return cur_v
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				cur_v = value
				if IsEquals(self.ext_slider) then
					self.ext_slider.value = cur_v
				end
            end
        ),
        end_v,
		duration
	)
	self.DOTProcesse:SetEase(Enum.Ease.Linear)
end