-- 创建时间:2021-01-07
-- Panel:DriveSkillCarPanel
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

DriveSkillCarPanel = basefunc.class()
local C = DriveSkillCarPanel
C.name = "DriveSkillCarPanel"
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
	self.listener["notify_car_skill_upgrade"] = basefunc.handler(self,self.on_car_skill_upgrade)
	self.listener["notify_car_skill_start"] = basefunc.handler(self,self.on_car_skill_start)
	self.listener["notify_car_skill_end"] = basefunc.handler(self,self.on_car_skill_end)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
	if self.upgrade_seq then
		self.upgrade_seq:Kill()
		self.upgrade_seq = nil
	end
	if self.use_fx_seq then
		self.use_fx_seq:Kill()
		self.use_fx_seq = nil
	end
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
	--#功能还没实现 先return掉
	if true then return end

	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function C:InitUI()	--#测试代码，车辆技能的配置 现在还没有配置文件
	self:SetCarSkill()
	self.car_skill_item = {}
	--初始化数据
	dump(self.car_skill,"<color=yellow>car_skill???????????????????</color>")
	for skill_type,skill_id in pairs(self.car_skill) do
		self.car_skill_item[skill_type] = {}
		self.car_skill_item[skill_type].obj = self[skill_type .. "_skill"]
		self.car_skill_item[skill_type].tbl = basefunc.GeneratingVar(self.car_skill_item[skill_type].obj)
		self.car_skill_item[skill_type].obj.transform:GetComponent("Button").onClick:AddListener(function()
			self:ShowSkillDesc(skill_type)
		end)
	end
	self.skill_desc_panel.transform:GetComponent("Button").onClick:AddListener(function()
		self.skill_desc_panel.gameObject:SetActive(false)
	end)
	self:MyRefresh()
end

function C:SetCarSkill()
	if not DriveModel.data.car_data or not  DriveModel.data.car_data[DriveModel.data.seat_num] then return end
	local car_data
	for k,v in pairs(DriveModel.data.car_data[DriveModel.data.seat_num]) do
		car_data = v
		break
	end

	local car_skill = car_data.skill_datas
	self.car_skill = {}
	for k,v in ipairs(car_skill) do
		if v.skill_tag then
			dump(v)
			dump(v.skill_tag,"v.skill_tag")
			self.car_skill[v.skill_tag] = v.skill_id
		end
	end
end

function C:SetCarSkillItem()
	for skill_type,skill_id in pairs(self.car_skill) do
		self.car_skill_item[skill_type].skill_id = skill_id
		local level = SkillManager.GetSkillCfgById(skill_id).level
		self.car_skill_item[skill_type].tbl.cur_skill_level_txt.text = "Lv." .. level
	end
end

function C:MyRefresh(car_type_id)
	if true then return end
	self.skill_desc_panel.gameObject:SetActive(false)
	self:SetCarSkill()
	self:SetCarSkillItem()
end

function C:ShowSkillDesc(skill_type)
	local skill_id = self.car_skill[skill_type]
	--设置位置
	local pos_map = {
		head = {x = -148,y = -725},
		body = {x = -50,y = -726},
		tail = {x = 110,y = -725},
		big =  {x = 250,y = -725}
	}
	self.skill_desc_txt.text = SkillManager.GetSkillCfgById(skill_id).desc
	if skill_type and pos_map[skill_type] then
		local position = pos_map[skill_type]
		self.desc_node.transform.localPosition = Vector3.New(position.x,position.y,0)
	end
	self.skill_desc_panel.gameObject:SetActive(true)
end

function C:on_car_skill_upgrade(before_skill_id,now_skill_id,seat_num)
	local upgrade_type
	for k,v in pairs(self.car_skill) do
		if v == before_skill_id then
			upgrade_type = k
			break
		end
	end
	if not upgrade_type then return end
	self.skill_desc_panel.gameObject:SetActive(false)

	self.car_skill_item[upgrade_type].skill_id = now_skill_id
	if self.upgrade_seq then
		self.upgrade_seq:Kill()
		self.upgrade_seq = nil
	end
	self.upgrade_seq = DoTweenSequence.Create()
	local fx_pre = newObject("cheliangdengji_shengji",self.car_skill_item[upgrade_type].obj.transform)
	self.upgrade_seq:AppendInterval(1.6)
	self.upgrade_seq:OnForceKill(function()
		destroy(fx_pre)
		self.upgrade_seq = nil
		self:MyRefresh()
	end)
end

function C:on_car_skill_start(skill_id)
	local cast_type
	for k,v in pairs(self.car_skill) do
		if v == skill_id then
			cast_type = k
			break
		end
	end
	if not cast_type then return end
	if self.use_fx_seq then
		self.use_fx_seq:Kill()
		self.use_fx_seq = nil
	end
	self.car_skill_item[cast_type].tbl.use_fx.gameObject:SetActive(true)
end

function C:on_car_skill_end(skill_id)
	local cast_type
	for k,v in pairs(self.car_skill) do
		if v == skill_id then
			cast_type = k
			break
		end
	end
	if not cast_type then return end
	if self.use_fx_seq then
		self.use_fx_seq:Kill()
		self.use_fx_seq = nil
	end
	self.use_fx_seq = DoTweenSequence.Create()
	self.use_fx_seq:AppendInterval(0.2)
	self.use_fx_seq:OnForceKill(function()
		self.car_skill_item[cast_type].tbl.use_fx.gameObject:SetActive(false)
	end)
end

function C.GetCarSkillPos(skill_tag)
	if instance and instance.car_skill_item then
		return instance.car_skill_item[skill_tag].obj.transform.position
	end
end