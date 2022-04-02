-- 创建时间:2018-05-30

local basefunc = require "Game.Common.basefunc"
EquipmentDetailView = basefunc.class()
local M = EquipmentDetailView
M.name = "EquipmentDetailView"
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
	self:RemoveListener()
	if self.up_star_seq then self.up_star_seq:Kill() end
	destroy(self.gameObject)
	clear_table(self)
	instance = nil
end

function M:Init()
	--初始化UI设置
	self.back_btn.onClick:AddListener(function(  )
		GameManager.Goto({_goto = EquipmentController.key,goto_parm = "view"})
		self:Exit()
	end)
	self.break_through_btn.onClick:AddListener(function(  )
		--突破
		dump(self.data,"<color=white>装备突破</color>")
		EquipmentModel.drive_equipment_up_star(self.data)
		local fx_pre = newObject("anniu_tupo",self.break_through_btn.transform)
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(1)
		seq:AppendCallback(function()
			if IsEquals(fx_pre) then
				destroy(fx_pre)
			end
		end)
	end)
	self.up_btn.onClick:AddListener(function(  )
		--提升
		dump(self.data,"<color=white>装备提升</color>")
		GameManager.Goto({_goto = EquipmentController.key,goto_parm = "up",data = self.data})
		-- EquipmentModel.drive_equipment_up_level(self.data)
	end)
	self.install_btn.onClick:AddListener(function(  )
		--挂载
		dump(self.data,"<color=white>装备挂载</color>")
		EquipmentModel.drive_equipment_load(self.data)
		GameManager.Goto({_goto = EquipmentController.key,goto_parm = "view"})
		self:Exit()
	end)
	self.uninstall_btn.onClick:AddListener(function(  )
		--卸载
		dump(self.data,"<color=white>装备卸载</color>")
		EquipmentModel.drive_equipment_unload(self.data)
		GameManager.Goto({_goto = EquipmentController.key,goto_parm = "view"})
		self:Exit()
	end)
	EquipmentModel.query_drive_equipment_data(self.data)
end

function M:Refresh()
	self:RefreshData()
	dump(self.data,"<color=white>装备详细数据</color>")
	self:RefreshEquiment()
	self:RefreshAttribute()
	self:RefreshSkill()
	self:RefreshBtns()
	self:RefreshStarUp()
end

function M:RefreshData()
	self.data = EquipmentModel.GetBaseDataByNo(self.data.no)
end

function M:RefreshBtns()
	if not self.data or not next(self.data) then return end
	if self.data.owner_car_id and self.data.owner_car_id ~= 0 then
		self.uninstall_btn.gameObject:SetActive(true)
		self.install_btn.gameObject:SetActive(false)
	else
		self.install_btn.gameObject:SetActive(true)
		self.uninstall_btn.gameObject:SetActive(false)
	end
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

	local obj = self.transform:Find("Top/EquipmentItem")
	EquipmentItem.RefreshEquipmentByData(obj,self.data)
end

function M:CheckSkillIsChange(skill)
	if not self.skill then return true end
	if #self.skill ~= #skill then return true end
	for k,v in pairs(self.skill) do
		if not skill[k] or skill[k] ~= v then
			return true
		end
	end

	for k,v in pairs(skill) do
		if not self.skill[k] or self.skill[k] ~= v then
			return true
		end
	end
end

function M:RefreshAttribute()
	local attribute = EquipmentModel.GetEquipmentAttribute(self.data)
	dump(attribute,"<color=yellow>详情界面基础属性</color>")
	for k,v in pairs(attribute) do
		self["attribute_" .. k].gameObject:SetActive(v > 0)
		self[k .. "_num_txt"].text = v
	end
end

function M:RefreshSkill()
	local skill = EquipmentModel.GetEquipmentSkill(self.data)
	dump(skill,"<color=yellow>skill ??????? </color>")
	self["skill_star_1"].gameObject:SetActive(false)
	self["skill_star_2"].gameObject:SetActive(false)
	self["skill_star_3"].gameObject:SetActive(false)
	self["skill_big"].gameObject:SetActive(false)
	self["skill_base"].gameObject:SetActive(false)
	for k,v in pairs(skill) do
		if next(v) then
			local skill_type = v.sever_cfg.skill_type
			if skill_type then
				self["skill_" .. skill_type].gameObject:SetActive(true)
				self["skill_" .. skill_type .. "_img"].sprite = GetTexture(v.client_cfg.icon)
				self["skill_" .. skill_type .. "_name_txt"].text = v.client_cfg.name
				if not v.data or not next(v.data) then
					self["skill_" .. skill_type .. "_name_txt"].color = Color.New(188/255,188/255,188/255,1)
				end

				
				local es = self["skill_" .. skill_type]:Find("EquipmentStar")
				local star
				if string.sub(skill_type,1,4) == "star" then
					local ss = string.split(skill_type,"_")
					local n = tonumber(ss[2])
					local sp
					local mat
					if not v.data or not next(v.data) then
						mat = GetMaterial("ImageGrey")
					end
					for i=0,4 do
						star = es:GetChild(i)		
						sp = star:GetComponent("Image")
						sp.material = mat
						if i <= n - 1 then
							star.gameObject:SetActive(true)
						else
							star.gameObject:SetActive(false)
						end
					end
					
					es.gameObject:SetActive(true)
				else
					es.gameObject:SetActive(false)
					for i=0,4 do
						star = es:GetChild(i)
						star.gameObject:SetActive(false)
					end
				end
			end
		end
	end

	local b = false
	for k,v in pairs(skill) do
		if next(v) then
			b = true
			break
		end		
	end
	self.skill_title.gameObject:SetActive(b)
	self.skill = skill
end

function M:RefreshStarUp()
	local star_up_cfg,is_max = EquipmentModel.GetStarUpSpend(self.data)
	if is_max then
		self.is_star_max = true
		self.break_through_txt.color = Color.New(188/255,188/255,188/255,1)
		self.break_through_img.material = GetMaterial("ImageGrey")
		self.break_through_btn.interactable = false
		return
	end
	
	self.break_through_txt.color = Color.white
	self.break_through_img.material = nil
	if not star_up_cfg or not next(star_up_cfg) then
		self.jing_bi_star_up.gameObject:SetActive(false)
		self.diamond_star_up.gameObject:SetActive(false)
		self.gear_star_up.gameObject:SetActive(false)
		return
	end
	dump(star_up_cfg,"<color=yellow>star_up_cfg</color>")
	local asset_cfg = {
		jing_bi = "jing_bi",
		gear = "gear",
		diamond = "diamond"
	}
	for k,v in pairs(star_up_cfg) do
		if asset_cfg[k] then
			self[k .. "_star_up_num_txt"].text = SysAssetModel.GetItemCount(k) .. "/" .. v
			self[k .. "_star_up_img"].sprite = GetTexture(SysAssetModel.GetItemImage(k))
			if not SysAssetModel.GetItemCount(k) or SysAssetModel.GetItemCount(k) < v then
				self[k .. "_star_up_num_txt"].color = Color.red
			end
			self[k .. "_star_up"].gameObject:SetActive(v > 0)
		end
	end
end

function M:on_query_drive_all_equipment(data)
	self:Refresh()
end

function M:on_query_drive_equipment_data(data)
	dump(data,"<color=yellow>on_query_drive_equipment_data</color>")
    self:Refresh()
end

function M:on_drive_equipment_up_level(data)
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
	if data.change_type == "up_star" then
		if self.up_star_seq then self.up_star_seq:Kill() end
		self.up_star_seq = DoTweenSequence.Create()
		local camera_1 = GameObject.Find("Canvas/Camera").transform
		self.up_star_seq:AppendCallback(function()
			local obj = self.transform:Find("Top/EquipmentItem")
			local star = obj.transform:Find("Star/@star_" .. data.base_data.star)
			star.gameObject:SetActive(true)
			star.transform:GetComponent("Animator").enabled = true
			local SG_saoguang = newObject("SG_saoguang",obj.transform)
		end)
		self.up_star_seq:AppendInterval(0.1)
		self.up_star_seq:Append(camera_1:DOShakePosition(0.2,Vector3.New(20,20,0)))
		if self.attribute_at.gameObject.activeSelf then
			self.up_star_seq:Append(self.attribute_at.transform:DOScale(Vector3.New(1.3,1.3,1),0.3))
			self.up_star_seq:Append(self.attribute_at.transform:DOScale(Vector3.New(1,1,1),0.1))
			self.up_star_seq:Append(camera_1:DOShakePosition(0.2,Vector3.New(20,20,0)))
		end

		if self.attribute_hp.gameObject.activeSelf then
			self.up_star_seq:Append(self.attribute_hp.transform:DOScale(Vector3.New(1.3,1.3,1),0.3))
			self.up_star_seq:Append(self.attribute_hp.transform:DOScale(Vector3.New(1,1,1),0.1))
			self.up_star_seq:Append(camera_1:DOShakePosition(0.2,Vector3.New(20,20,0)))
		end
		if self.attribute_sp.gameObject.activeSelf then
			self.up_star_seq:Append(self.attribute_sp.transform:DOScale(Vector3.New(1.3,1.3,1),0.3))
			self.up_star_seq:Append(self.attribute_sp.transform:DOScale(Vector3.New(1,1,1),0.1))
			self.up_star_seq:Append(camera_1:DOShakePosition(0.2,Vector3.New(20,20,0)))
		end
		self.up_star_seq:AppendCallback(function()
			self:Refresh()
		end)
		self.up_star_seq:OnForceKill(function()
			self.up_star_seq = nil
		end)
	else
		self:Refresh()
	end
end