-- 创建时间:2021-05-26
-- Panel:SysCarUpgradePanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- AudioManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- AudioManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

SysCarUpgradePanel = basefunc.class()
local C = SysCarUpgradePanel
C.name = "SysCarUpgradePanel"

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_on_query_drive_car_data_response"] = basefunc.handler(self,self.model_on_query_drive_car_data_response)
	self.lister["model_on_drive_car_data_change"] = basefunc.handler(self,self.model_on_drive_car_data_change)
	self.lister["model_on_drive_car_up_level_response"] = basefunc.handler(self,self.model_on_drive_car_up_level_response)
	self.lister["model_on_drive_car_up_star_response"] = basefunc.handler(self,self.model_on_drive_car_up_star_response)
	self.lister["asset_change"] = basefunc.handler(self,self.RefreshAsset)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.car_up_level_seq then
		self.car_up_level_seq:Kill()
	end
	if self.car_up_star_seq then
		self.car_up_star_seq:Kill()
		self.car_up_star_seq = nil
	end
	if self.type_items then
		for k,v in ipairs(self.type_items) do
			if self.type_items.MyExit then
				self.type_items:MyExit()
			end
		end
	end
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end

function C:ctor(parm)
	local parent = parm.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	if parm and next(parm) then
		self.cur_car_id = parm.cur_car_id
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.upgrade_btn.onClick:AddListener(function()
		if self.cur_car_id then
			Network.SendRequest("drive_car_up_level",{car_id = self.cur_car_id})
			Event.Brocast("guide_step_complete")
			Event.Brocast("guide_step_trigger")
		end
		local fx_pre = newObject("anniu_tisheng_wai",self.upgrade_btn.transform)
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(1)
		seq:AppendCallback(function()
			if IsEquals(fx_pre) then
				destroy(fx_pre)
			end
		end)
	end)
	self.tupo_btn.onClick:AddListener(function()
		if self.cur_car_id then
			Network.SendRequest("drive_car_up_star",{car_id = self.cur_car_id})
		end
		local fx_pre = newObject("anniu_tisheng_wai",self.tupo_btn.transform)
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(1)
		seq:AppendCallback(function()
			if IsEquals(fx_pre) then
				destroy(fx_pre)
			end
		end)
	end)
	self.chuzhan_btn.onClick:AddListener(function()
		SysCarManager.set_cur_car_id(self.cur_car_id)
		local fx_pre = newObject("anniu_chuzhan",GameObject.Find("Canvas/LayerLv5").transform)
		fx_pre.transform.position = self.chuzhan_btn.transform.position
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(1)
		seq:AppendCallback(function()
			if IsEquals(fx_pre) then
				destroy(fx_pre)
			end
		end)
	end)

	self:AddSkillBtnOnClick()
end

function C:InitUI()
	self.CarShowBG = newObject("CarShowBG",self.car_show_node)
	self:MyRefresh()
end

function C:RefreshPatchIcon()
	if not IsEquals(self.transform) then return end
	local cur_id_patch_img_config = {
		[1] = "ty_sp_pc01",
		[2] = "ty_sp_tk01",
		[3] = "ty_sp_czc01",
		[4] = "ty_sp_azc01"
	}
	self.star_patch_icon_img.sprite = GetTexture(cur_id_patch_img_config[self.cur_car_id])
end

function C:AddSkillBtnOnClick()
	local cfg = {
		[1] = "big",
		[2] = "base",
		[3] = "base_2",
		[4] = "base_3",
	}
	for k,v in ipairs(cfg) do
		local btn = self["skill_node_" .. v .. "_btn" ]
		if btn then
			btn.onClick:AddListener(function()
				if self.skill_nodes[v] then
					local skill_cfg = self.skill_nodes[v].skill_cfg
					local parm = {
						parent = self.transform,
						name = skill_cfg.name,
						desc = skill_cfg.desc,
						icon_img = skill_cfg.icon,
						ui_pos = Vector3.New(btn.transform.position.x - 300,btn.transform.position.y,0)
					}
					ComShowTips.Create(parm)
				end
			end)
		end
	end
end

function C:RefreshCarShow(car_id)
	if not IsEquals(self.transform) then return end
	local car_data = SysCarUpgradeManager.GetCarUpgradeData(car_id or SysCarManager.GetCurCar().car_id)
	if car_data.base_data.star == self.cur_car_star then
		return
	end
	if self.CarShow then
		self.CarShow:MyExit()
	end
	self.CarShow = CarShow.Create({parent = self.car_show_node,car_id = self.cur_car_id,car_star = car_data.base_data.star})
	-- self.CarShow:PlayCarShowFx()
end

function C:MyRefresh(car_id)
	if not IsEquals(self.transform) then return end
	local change_car_flag = false
	if self.cur_car_id then
		local now_car_id = car_id or SysCarManager.GetCurCar().car_id
		if self.cur_car_id ~= now_car_id then
			change_car_flag = true
		end
	end
	self.cur_car_id = car_id or SysCarManager.GetCurCar().car_id
	if SysCarUpgradeManager.car_data and next(SysCarUpgradeManager.car_data) then
		--刷新所有车辆UI
		self:RefreshAllCarUI()
	end
	local car_data = SysCarUpgradeManager.GetCarUpgradeData(car_id or SysCarManager.GetCurCar().car_id)
	if car_data and next(car_data) then
		--刷新当前车辆UI
		self:RefreshCurrentCarUI(car_data,change_car_flag)
		self:RefreshTupo(car_data)
		self:RefreshUpLevelBtn(car_data)
	elseif change_car_flag then
		if self.CarShow then
			self.CarShow:MyExit()
		end
		self.CarShow = CarShow.Create({parent = self.car_show_node,car_id = self.cur_car_id,car_star = 1})
		self.CarShow:PlayCarShowFx()
	end
end

function C:RefreshAllCarUI()
	local all_car_data = SysCarUpgradeManager.car_data
	self.type_items = self.type_items or {}
	if not next(self.type_items) then
		for default_type_id = 1,4 do
			self.type_items[default_type_id] = SysCarUpgradeTypeObj.Create(default_type_id,self.car_type_parent,self)
		end
	end
	for k,car_data in pairs(SysCarUpgradeManager.car_data) do
		local car_cfg = SysCarUpgradeManager.GetCarUpgradeCfg(car_data.base_data.car_id)
		if self.type_items[car_cfg.car_type_id] then
			self.type_items[car_cfg.car_type_id]:RefreshItem(car_data)
		else
			self.type_items[car_cfg.car_type_id] = SysCarUpgradeTypeObj.Create(car_cfg.car_type_id,self.car_type_parent,self)
			self.type_items[car_cfg.car_type_id]:RefreshItem(car_data)
		end
	end

end

function C:RefreshCurrentCarUI(car_data,change_car_flag)
	if not IsEquals(self.transform) then return end
	self.at_txt.text = car_data.at

	self.sp_txt.text = car_data.sp

	self.hp_txt.text = car_data.hp

	self.car_cfg = SysCarUpgradeManager.GetCarUpgradeCfg(self.cur_car_id)
	if car_data.base_data.level then
		self.cur_car_level_txt.text = car_data.base_data.level .. "/" .. self.car_cfg.star_rule[car_data.base_data.star].max_level
	end
	if car_data.base_data.star and car_data.base_data.star > 0 then
		local create_star = function()
			self.star_icons = {}
			
			for i = 1,car_data.base_data.star do
				local star_obj = GameObject.Instantiate(self.star_icon.gameObject,self.star_node)
				star_obj.gameObject:SetActive(true)
				self.star_icons[#self.star_icons + 1] = star_obj
			end
		end
		if self.star_icons and next(self.star_icons) then
			if car_data.base_data.star ~= #self.star_icons then
				if car_data.base_data.star <= #self.star_icons or change_car_flag then
					for k,v in ipairs(self.star_icons) do
						destroy(v.gameObject)
					end
					create_star()
				else
					for i = #self.star_icons + 1,car_data.base_data.star do
						local star_obj = GameObject.Instantiate(self.star_icon.gameObject,self.star_node)
						star_obj.gameObject:SetActive(true)
						self.star_icons[#self.star_icons + 1] = star_obj
						if star_obj.transform:GetComponent("Animator") then
							star_obj.transform:GetComponent("Animator").enabled = true
						end
					end
				end
			end
		else
			create_star()
		end
	else
		if self.star_icons and next(self.star_icons) then
			for k,v in ipairs(self.star_icons) do
				destroy(v.gameObject)
			end
			self.star_icons = {}
		end
	end
	self.car_name_txt.text = SysCarManager.GetCarCfg({car_type_id = self.cur_car_id}).name
	self.car_type_name_txt.text = SysCarManager.GetCarCfg({car_type_id = self.cur_car_id}).tag_name
	if SysCarManager.GetCurCar().car_id == self.cur_car_id then
		self.chuzhan_btn.gameObject:SetActive(false)
		self.chuzhan_img.gameObject:SetActive(true)
	else
		self.chuzhan_btn.gameObject:SetActive(true)
		self.chuzhan_img.gameObject:SetActive(false)
	end
	-- self.car_img.sprite = GetTexture(self.car_cfg.hall_img)
	if not self.CarShow then
		self.CarShow = CarShow.Create({parent = self.car_show_node,car_id = self.cur_car_id,car_star = car_data.base_data.star})
	else
		if change_car_flag then
			if self.CarShow then
				self.CarShow:MyExit()
			end
			self.CarShow = CarShow.Create({parent = self.car_show_node,car_id = self.cur_car_id,car_star = car_data.base_data.star})
			self.CarShow:PlayCarShowFx()
		else
	
		end
	end

	self:RefreshAsset()

	--刷新技能
	if self.skill_nodes and next(self.skill_nodes) then
		for k,v in pairs(self.skill_nodes) do
			v.obj.gameObject:SetActive(false)
		end
	end
	self.skill_nodes = {}
	if car_data.car_skill_data and next(car_data.car_skill_data) then
		for k,skill_data in ipairs(car_data.car_skill_data) do
			local cfg = SysCarUpgradeManager.GetUpgradeSkillCfg(skill_data.type_id)
			if cfg then
				local skill_node
				if skill_data.skill_type == "big" then
					skill_node = {
						skill_data = skill_data,
						skill_cfg = cfg,
						skill_type = "big",
						obj = self.big_node,
					}
				elseif skill_data.skill_type == "base" then
					skill_node = {
						skill_data = skill_data,
						skill_cfg = cfg,
						skill_type = skill_data.skill_type,
						obj = self["skill_node_" .. skill_data.skill_type],
					}
					self["skill_node_" .. skill_node.skill_type .. "_btn" ].transform:GetComponent("Image").sprite = GetTexture(cfg.icon)
				end
				if skill_node then
					skill_node.obj.gameObject:SetActive(true)
					self.skill_nodes[skill_node.skill_type] = skill_node
				end
			end
		end
	end
	--刷新碎片图标
	self:RefreshPatchIcon()
end

function C:model_on_query_drive_car_data_response(data)
	self:MyRefresh(self.cur_car_id)
	local car_data = SysCarUpgradeManager.GetCarUpgradeData(self.cur_car_id or SysCarManager.GetCurCar().car_id)
	self:RefreshTupo(car_data)
end

function C:model_on_drive_car_data_change(data)
	dump(data,"<color=white>data?????????</color>")
	if data.change_type == "up_level" then
		self:PlayCarUpLevel(data.car_data)
	elseif data.change_type == "up_star" then
		self:PlayCarUpStar(data.car_data)
		self:RefreshCarShow(data.car_data.car_id)
		self.cur_car_star = data.car_data.base_data.star
	else
		self:MyRefresh(self.cur_car_id)
	end
	self:RefreshBaseNum(data.car_data)
	self:RefreshTupo(data.car_data)
	self:RefreshUpLevelBtn(data.car_data)
	self:RefreshAsset()
end

function C:RefreshAsset()
	if not IsEquals(self.transform) then return end
	local car_data = SysCarUpgradeManager.GetCarUpgradeData(self.cur_car_id)
	if not car_data then return end
	--刷新spend
	if self.car_cfg.level_spend_rule then
		local spend_cfgs = {}
		for k,v in pairs(self.car_cfg.level_spend_rule) do
			spend_cfgs[k] = SysCarUpgradeManager.car_upgrade_spend_config[v.spend]
		end
		local spend_data = SysCarUpgradeManager.GetCurUpgradeSpend(car_data.base_data.level,spend_cfgs)
		if spend_data then
			if spend_data.jing_bi then
				self.lv_spend_txt.text = spend_data.jing_bi
				if SysAssetModel.GetItemCount("jing_bi") >= spend_data.jing_bi then
					self.lv_spend_txt.color = Color.white
				else
					self.lv_spend_txt.color = Color.red
				end
			else
				self.lv_spend_txt.text = 0
				self.lv_spend_txt.color = Color.white
			end
		end
	end
	if self.car_cfg.star_rule then
		local spend_cfgs = {}
		for k,v in pairs(self.car_cfg.star_rule) do
			spend_cfgs[k] = SysCarUpgradeManager.car_upgrade_spend_config[v.spend] or {}
		end
		local spend_data = SysCarUpgradeManager.GetCurUpgradeSpend(car_data.base_data.star,spend_cfgs)
		if spend_data.jing_bi then
			self.star_money_spend_txt.text = spend_data.jing_bi
			if SysAssetModel.GetItemCount("jing_bi") >= spend_data.jing_bi then
				self.star_money_spend_txt.color = Color.white
			else
				self.star_money_spend_txt.color = Color.red
			end
		else
			self.star_money_spend_txt.text = 0
			self.star_money_spend_txt.color = Color.white
		end
		for k,v in pairs(spend_data) do
			if string.split(k,"_")[1] == "patch" then
				self.star_patch_spend_txt.text = SysAssetModel.GetItemCount(k) .. "/" .. v
				if SysAssetModel.GetItemCount(k) >= v then
					self.star_patch_spend_txt.color = Color.white
				else
					self.star_patch_spend_txt.color = Color.red
				end
			end
		end
	end
end

function C:RefreshTupo(car_data)
	if not IsEquals(self.transform) then return end
	-- if self.cur_car_id ~= car_data.base_data.car_id then return end
	if car_data.base_data.star == 4 then
		--最大星级
		self.tupo_txt.text = "MAX"
		self.star_spend.gameObject:SetActive(false)
		self.tupo_btn.interactable = false
	else
		self.tupo_txt.text = "突破"
		self.star_spend.gameObject:SetActive(true)
		self.tupo_btn.interactable = true
	end
end


function C:RefreshUpLevelBtn(car_data)
	if not IsEquals(self.transform) then return end
	-- if self.cur_car_id ~= car_data.base_data.car_id then return end
	if tonumber(car_data.base_data.level) >= tonumber(self.car_cfg.star_rule[car_data.base_data.star].max_level) then
		--最大等级
		self.upgrade_btn.interactable = false
	else
		self.upgrade_btn.interactable = true
	end
end


function C:RefreshBaseNum(car_data)
	if not IsEquals(self.transform) then return end
	if not car_data or not next(car_data) then return end
	self.sp_txt.text = car_data.sp
	self.hp_txt.text = car_data.hp
	self.at_txt.text = car_data.at
end

function C:PlayCarUpLevel(car_data)
	if not IsEquals(self.transform) then return end
	if self.car_up_level_seq then
		self.car_up_level_seq:Kill()
	end
	local camera_1 = GameObject.Find("Canvas/Camera").transform
	local camera_2
	if self.CarShow then
		camera_2 = self.CarShow.transform:Find("Camera").transform
	end
	self.car_up_level_seq = DoTweenSequence.Create()
	self.car_up_level_seq:AppendCallback(function()
		self.at_txt.text = car_data.at
	end)
	self.car_up_level_seq:Append(self.at_node.transform:DOScale(Vector3.New(1.3,1.3,1),0.3))
	self.car_up_level_seq:Append(self.at_node.transform:DOScale(Vector3.New(1,1,1),0.1))
	self.car_up_level_seq:Append(camera_1:DOShakePosition(0.2,Vector3.New(20,20,0)))
	self.car_up_level_seq:AppendCallback(function()
		self.sp_txt.text = car_data.sp
	end)
	self.car_up_level_seq:Append(self.sp_node.transform:DOScale(Vector3.New(1.3,1.3,1),0.3))
	self.car_up_level_seq:Append(self.sp_node.transform:DOScale(Vector3.New(1,1,1),0.1))
	self.car_up_level_seq:Append(camera_1:DOShakePosition(0.2,Vector3.New(20,20,0)))
	self.car_up_level_seq:AppendCallback(function()
		self.hp_txt.text = car_data.hp
	end)
	self.car_up_level_seq:Append(self.hp_node.transform:DOScale(Vector3.New(1.3,1.3,1),0.3))
	self.car_up_level_seq:Append(self.hp_node.transform:DOScale(Vector3.New(1,1,1),0.1))
	self.car_up_level_seq:Append(camera_1:DOShakePosition(0.2,Vector3.New(20,20,0)))
	self.car_up_level_seq:AppendCallback(function()
		self.cur_car_level_txt.text = car_data.base_data.level .. "/" .. self.car_cfg.star_rule[car_data.base_data.star].max_level
	end)
	self.car_up_level_seq:Append(self.car_exp_txt.transform:DOScale(Vector3.New(1.3,1.3,1),0.3))
	self.car_up_level_seq:Append(self.car_exp_txt.transform:DOScale(Vector3.New(0.8,0.8,1),0.2))
	self.car_up_level_seq:Append(self.car_exp_txt.transform:DOScale(Vector3.New(1,1,1),0.1))
	self.car_up_level_seq:Append(camera_1:DOShakePosition(0.2,Vector3.New(20,20,0)))
	self.car_up_level_seq:AppendCallback(function()
		if self.CarShow then
			self.CarShow:PlayCarShowFx()
		end
	end)
	self.car_up_level_seq:OnForceKill(function()
		self.at_txt.transform.localScale = Vector3.New(1,1,1)
		self.sp_txt.transform.localScale = Vector3.New(1,1,1)
		self.hp_txt.transform.localScale = Vector3.New(1,1,1)
		self.cur_car_level_txt.transform.localScale = Vector3.New(1,1,1)
		camera_1.transform.localPosition = Vector3.New(0,0,0)
		self.at_txt.text = car_data.at
		self.sp_txt.text = car_data.sp
		self.hp_txt.text = car_data.hp
		self.cur_car_level_txt.text = car_data.base_data.level .. "/" .. self.car_cfg.star_rule[car_data.base_data.star].max_level
		self.car_up_level_seq = nil
	end)

end

function C:PlayCarUpStar(car_data)
	if self.car_up_star_seq then
		self.car_up_star_seq:Kill()
		self.car_up_star_seq = nil
	end
	self.car_up_star_seq = DoTweenSequence.Create()
	self.car_up_star_seq:AppendCallback(function()
		local star_obj = GameObject.Instantiate(self.star_icon.gameObject,self.star_node)
		star_obj.gameObject:SetActive(true)
		self.star_icons = self.star_icons or {}
		self.star_icons[#self.star_icons + 1] = star_obj
		if star_obj.transform:GetComponent("Animator") then
			star_obj.transform:GetComponent("Animator").enabled = true
		end
		
		self.cur_car_level_txt.text = car_data.base_data.level .. "/" .. self.car_cfg.star_rule[car_data.base_data.star].max_level
	end)
	self.car_up_star_seq:Append(self.car_exp_txt.transform:DOScale(Vector3.New(1.3,1.3,1),0.3))
	self.car_up_star_seq:Append(self.car_exp_txt.transform:DOScale(Vector3.New(0.8,0.8,1),0.2))
	self.car_up_star_seq:Append(self.car_exp_txt.transform:DOScale(Vector3.New(1,1,1),0.1))
	self.car_up_star_seq:AppendCallback(function()
		self.CarShow:PlayCarShowFx()
		self:MyRefresh()
	end)
	self.car_up_star_seq:OnForceKill(function()
		self.cur_car_level_txt.transform.localScale = Vector3.New(1,1,1)
		self.car_up_star_seq = nil
	end)
end

function C:model_on_drive_car_up_level_response()
end

function C:model_on_drive_car_up_star_response()
end