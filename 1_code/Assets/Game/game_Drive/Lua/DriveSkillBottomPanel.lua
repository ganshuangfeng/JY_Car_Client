-- 创建时间:2021-03-05
-- Panel:DriveSkillBottomPanel
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

local show_key = "slot_show_skill"
DriveSkillBottomPanel = basefunc.class()
local C = DriveSkillBottomPanel
C.name = "DriveSkillBottomPanel"
local instance
function C.Create(parent)
	if instance then
		instance:MyExit()
	end
	instance = C.New(parent)
	return instance
end
 
function C.Clear()
	if instance then
		instance:MyExit()
	end
	instance = nil
end
 
function C.Refresh()
	if instance then
		instance:MyRefresh()
		return
	end
	C.Create()
end
 
function C:AddListener()
	for proto_name,func in pairs(self.listener) do
		Event.AddListener(proto_name, func, true)
	end
end
 
function C:MakeListener()
	 self.listener = {}
	 self.listener["play_process_skill_create"] = basefunc.handler(self,self.on_play_process_skill_create)
	 self.listener["play_process_skill_dead"] = basefunc.handler(self,self.on_play_process_skill_dead)
	 self.listener["slot_skill_trigger"] = basefunc.handler(self,self.on_slot_skill_trigger)
	 self.listener["slot_skill_create"] = basefunc.handler(self,self.on_slot_skill_create)
end
 
function C:RemoveListener()
	for proto_name,func in pairs(self.listener) do
	 	Event.RemoveListener(proto_name, func)
	end
	self.listener = {}
 end
 
function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end
 
function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot/DrivePanel/@down_node")
	if not parent then return end
	parent = parent.transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
 
	self:MakeListener()
	self:AddListener()

	self.slot_show_skills = {}
	self:InitUI()
end

function C:SetStyle()
	for i=1,3 do
		self["skill_item_" .. i .. "_bg_img"].sprite = GetTexture(DriveMapManager.GetMapAssets("zd_bg_jnd"))
	end
end

function C:InitUI()
	self:SetStyle()
	for i = 1,3 do
		self["skill_" .. i .. "_btn"].onClick:AddListener(function()
			if self.slot_show_skills[i] and self.slot_show_skills[i].skill_id then
				local skill_cfg = SkillManager.GetSkillCfgById(self.slot_show_skills[i].skill_id)
				dump(skill_cfg,"<color=red>skill_cfg</color>")
			end
		end)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	self:ClearAllSkillItem()
	local skill_datas = {}
	for k,v in ipairs(DriveModel.data.players_info) do
		if v.seat_num == DriveModel.data.seat_num and v.skill_datas then
			for _k,skill_data in ipairs(v.skill_datas) do
				if skill_data.skill_tag then
					for __k,skill_tag in ipairs(skill_data.skill_tag) do
						if skill_tag == show_key then
							skill_datas[#skill_datas+1] = skill_data
						end
					end
				end
			end
		end
	end

	for k,v in ipairs(DriveModel.data.car_data) do
		for car_id,car_data in ipairs(v) do
			if car_data.seat_num == DriveModel.data.seat_num and car_data.skill_datas then
				for _k,skill_data in ipairs(car_data.skill_datas) do
					dump(skill_data,"<color=yellow>DriveSkillBottomPanelRefresh</color>")
					if skill_data.skill_tag then
						for __k,skill_tag in ipairs(skill_data.skill_tag) do
							if skill_tag == show_key then
								skill_datas[#skill_datas+1] = skill_data
							end
						end
					end
				end
			end
		end
	end
	if skill_datas and next(skill_datas) then
		for k,v in ipairs(skill_datas) do
			self:AddSlotSkill(v)
		end
	end
end

function C:check_skill_owner()
end

function C:AddSlotSkill(skill_data)
	if skill_data.skill_tag then
		for k,v in ipairs(skill_data.skill_tag) do
			if v == "big_skill" then
				self.big_skill = v
				return
			end
		end
	end
	if #self.slot_show_skills >= 3 then
		-- TipsShowUpText.Create("技能已达到上限")
		return
	end
	local skill_cfg = SkillManager.GetSkillCfgById(skill_data.skill_id)
	self.slot_show_skills[#self.slot_show_skills+1] = skill_data
	if skill_cfg.skill_buff_icon then
		local skill_img = self["skill_item_" .. #self.slot_show_skills].transform:Find("skill_img")
		skill_img.gameObject:SetActive(true)
		skill_img:GetComponent("Image").sprite = GetTexture(DriveMapManager.GetMapAssets(skill_cfg.skill_buff_icon))
		skill_img:GetComponent("Image"):SetNativeSize()
	else
		local skill_name = self["skill_item_" .. #self.slot_show_skills].transform:Find("skill_name")
		skill_name.gameObject:SetActive(true)
		skill_name:GetComponent("Text").text = skill_cfg.name
	end
end

function C:ClearSkillItem(i)
	if not i then return end
	self.slot_show_skills[i] = nil
	local skill_name = self["skill_item_" .. i].transform:Find("skill_name")
	skill_name.gameObject:SetActive(false)
	local skill_img = self["skill_item_" .. #self.slot_show_skills].transform:Find("skill_img")
	skill_img.gameObject:SetActive(false)
end

function C:ClearAllSkillItem()
	if self.slot_show_skills and next(self.slot_show_skills) then
		for i = 1,#self.slot_show_skills do
			self.slot_show_skills[i] = nil
			local skill_name = self["skill_item_" .. i].transform:Find("skill_name")
			skill_name.gameObject:SetActive(false)
		end
	end
end

function C:on_play_process_skill_create(data)
	if self:check_skill_owner() and data.skill_tag then
		for k,v in ipairs(data.skill_tag) do
			if v == show_key then
				--需要在下方显示的技能
				-- self:PlayShowFx()
			end
		end
	end
end

function C:on_slot_skill_trigger(skill_data)
	if self.slot_show_skills and next(self.slot_show_skills) then
		for k,v in ipairs(self.slot_show_skills) do
			if v.owner_data and skill_data.owner_data and v.owner_data.owner_type == skill_data.owner_data.owner_type and v.owner_data.owner_id == skill_data.owner_data.owner_id then
				dump(skill_data,"<color=red>该技能已在其他地方创建</color>")
				return
			end
		end
	end
	
end

function C:on_slot_skill_create(skill_data)
	if skill_data.launcher == DriveModel.data.seat_num and self.slot_show_skills and #self.slot_show_skills < 3 then
		self:PlayNewSlotSkill()
	end
end

function C:on_play_process_skill_dead(data)
	if self:check_skill_owner() and data.skill_tag then
		for k,v in ipairs(data.skill_tag) do
			if v == show_key then
				for _k,_v in pairs(self.slot_show_skills) do
					if _v.skill_id == data.skill_id then
						self:ClearSkillItem(_k)
					end
				end
			end
		end
	end
end

function C:PlayNewSlotSkill()
	local current_item = self["skill_item_" .. (#self.slot_show_skills + 1)]
	if current_item then
		local fx_pre = GameObject.Instantiate(self.jinenglan.gameObject,current_item.transform)
		fx_pre.gameObject:SetActive(true)
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(1)
		seq:AppendCallback(function()
			destroy(fx_pre)
		end)
	end
end

