-- 创建时间:2021-01-07
-- Panel:DrivePlayerInfoPanel
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

DrivePlayerInfoPanel = basefunc.class()
local C = DrivePlayerInfoPanel
C.name = "DrivePlayerInfoPanel"

function C.Create(parent)
	return C.New(parent)
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
	self.listener = {}
	self.listener["notify_show_attribute_change"] = basefunc.handler(self,self.OnAttributeChange)
	self.listener["car_move_to_start_pos"] = basefunc.handler(self,self.OnCarMoveToStartPoint)
	-- self.listener["play_process_obj_car_modify_property"] = basefunc.handler(self,self.on_play_process_obj_car_modify_property)
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

--显示属性
local attribute_enum = {
	hp = "hp",
	hp_max = "hp_max",
	at = "at",
	df = "df",
	sp = "sp",
	circle = "circle",
	seat_num = "seat_num",
	id = "id",
	car_no = "car_no",
	money = "money",
	hd = "hd",
	pos = "pos"
}

local box_award_cfg = {
	[1] = {percent = 25,type_img = "bs_bx_1",open_img = "bs_bx_1_1"},
	[2] = {percent = 50,type_img = "bs_bx_2",open_img = "bs_bx_2_1"},
	[3] = {percent = 75,type_img = "bs_bx_3",open_img = "bs_bx_3_1"},
}

function C:ctor(parent)
	local parent = parent
	local obj
	parent = GameObject.Find("3DNode/map_node/drive_map" .. DriveLogic.InitPram.map_id).transform
	obj = newObject(C.name .. "_3d",parent)

	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	
	self.show_item = {}

	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function C:SetStyle()
	self.hp_node_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_img_iconbg"))
	self.circle_node_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_img_qs_01"))
	self.transform.localScale = Vector3.one * 0.9
end

function C:InitUI()
	self:SetStyle()
	if DriveModel.data and DriveModel.data.car_data then
		local show_attribute = self:ModelDataToShowAttribute()

		--创建Item
		for seat_num,player_cars in ipairs(show_attribute) do
			self.show_item[seat_num] = self.show_item[seat_num] or {}
			for car_id,attribute_data in pairs(player_cars) do
				self.show_item[seat_num][car_id] = DrivePlayerInfoItem.Create(self["content_" .. seat_num],attribute_data,seat_num)
			end
		end
	end
	--创建宝箱
	local box_total_progress = 8.74
	for k,v in ipairs(box_award_cfg) do
		self.box_award_items = self.box_award_items or {}
		local obj = GameObject.Instantiate(self.award_box_item.gameObject,self.award_node_parent)
		self.box_award_items[#self.box_award_items + 1] = {
			obj = obj,
			cfg = v
		}
		obj.transform:GetComponent("SpriteRenderer").sprite = GetTexture(v.type_img)
		local obj_x = -(box_total_progress / 2) + (v.percent / 100) * box_total_progress
		obj.transform.localPosition = Vector3.New(obj_x,obj.transform.localPosition.y,obj.transform.localPosition.z)
		obj.gameObject:SetActive(true)
	end
	self:RefreshCircle()
end

function C:MyRefresh()
	local show_attribute = self:ModelDataToShowAttribute()
	for seat_num,cars in ipairs(self.show_item) do
		for car_id,item in pairs(cars) do
			item:MyRefresh(show_attribute[seat_num][car_id])
		end
	end
	self:RefreshCircle()
end

function C:ModelDataToShowAttribute()
	--处理数据
	local show_attribute = {}
	for seat_num,cars in ipairs(DriveModel.data.car_data or {}) do
		for car_id,car_data in pairs(cars) do
			show_attribute[seat_num] = show_attribute[seat_num] or {}
			show_attribute[seat_num][car_id] = show_attribute[seat_num][car_id] or {}
			local attribute_data = show_attribute[seat_num][car_id]
			for attr,attr_name in pairs(attribute_enum) do
				attribute_data[attr] = car_data[attr] or 0
				if attr_name == "circle" and car_data.pos then
					attribute_data.circle = math.floor(car_data.pos / DriveMapManager.map_count) + 1
				end
				if attr_name == "money" then
					local car_money = DriveModel.data.players_info[seat_num].money
					attribute_data.money = car_money
				end
			end
		end
	end
	return show_attribute
end

function C:GetShowAttribute(seat_num,car_id,modify_key_name)
	if self.show_item[seat_num] then
		local _car_id = car_id
		--默认不需要传car_id
		if not _car_id or not self.show_item[seat_num][_car_id] then
			for k,v in pairs(self.show_item) do
				_car_id = k
				break
			end
		end
		return self.show_item[seat_num][_car_id].attribute_data[modify_key_name] or 0
	else
		return 0
	end
end
--[[
	parm = {
		car_no = 1,
		modify_key_name = "hp",
		modify_value = 20,
		seat_num = 1,
	}
]]
function C:OnAttributeChange(parm)
	if parm and parm.car_no then
		for _seat_num,cars in ipairs(self.show_item) do
			for _car_id,show_item in ipairs(cars) do
				if show_item.attribute_data.car_no == parm.car_no then
					show_item:ChangeAttribute(parm.modify_key_name,parm.modify_value)
				end
			end
		end
	elseif parm and parm.seat_num then
		for _seat_num,cars in ipairs(self.show_item) do
			for _car_id,show_item in ipairs(cars) do
				if _seat_num == parm.seat_num then
					show_item:ChangeAttribute(parm.modify_key_name,parm.modify_value)
				end
			end
		end
	else
		dump(parm,"<color=red>不合法的数据</color>")
	end
end

function C:on_play_process_obj_car_modify_property(data)
	local obj_car_modify_property = data[data.key]
	local parm = {
		modify_key_name = obj_car_modify_property.modify_key_name,
		modify_value = obj_car_modify_property.modify_value,
		car_no = obj_car_modify_property.car_no,
	}
	self:OnAttributeChange(parm)
end

function C:OnCarMoveToStartPoint(data)
	local modify_value = 1
	if not data.shun_or_ni then
		modify_value = -1
	end
	local parm = {
		modify_key_name = "circle",
		modify_value = modify_value,
		car_no = data.car_no,
	}
	self:OnAttributeChange(parm)
	self:RefreshCircle()
end

local progress_width = 8.74
local progress_height = 0.34
--刷新下方进度条界面
function C:RefreshCircle()
	local other_data = {
		circle = 0,
		pos = 0,
	}
	local self_data = {
		circle = 0,
		pos = 0,
	}
	for _seat_num,cars in ipairs(self.show_item) do
		for _car_id,show_item in ipairs(cars) do
			if _seat_num == DriveModel.data.seat_num then
				self_data.circle = show_item.attribute_data.circle > 0 and show_item.attribute_data.circle or 0
				self_data.pos = show_item.attribute_data.pos
			else
				other_data.circle = show_item.attribute_data.circle > 0 and show_item.attribute_data.circle or 0
				other_data.pos = show_item.attribute_data.pos
			end
		end
	end
	local total_circle = DriveModel.data.total_round or 60
	local icon_start_pos = -424
	local progress_total_length = 848
	local correct_length = 10

	local self_progress = self_data.circle / total_circle
	local other_progress = other_data.circle / total_circle
	
	local self_icon_x = icon_start_pos + progress_total_length * self_progress
	local other_icon_x = icon_start_pos + progress_total_length * other_progress
	if self_icon_x == other_icon_x then
		if self_data.pos >= other_data.pos then
			self_icon_x = self_icon_x + correct_length
		else
			other_icon_x = other_icon_x + correct_length
		end
	end
	local progress = (math.max(self_icon_x,other_icon_x) - icon_start_pos) / progress_total_length
	if self.circle_progress:GetComponent("Image") then
		self.circle_progress:GetComponent("Image").fillAmount = progress
		self.circle_progress_other.transform.localPosition = Vector3.New(other_icon_x,0,0)
		self.circle_progress_me.transform.localPosition = Vector3.New(self_icon_x,0,0)
	elseif self.circle_progress:GetComponent("SpriteRenderer") then
		self.circle_progress:GetComponent("SpriteRenderer").size = {x = progress_width * progress , y = progress_height}
		self.circle_progress_other.transform.localPosition = Vector3.New(other_icon_x/100,0,0)
		self.circle_progress_me.transform.localPosition = Vector3.New(self_icon_x/100,0,0)
	end
end

function C:PlayAwardBox(tool_create_datas,cbk)
	local seq = DoTweenSequence.Create()
	local next_box_award_item
	for k,v in ipairs(self.box_award_items) do
		if v and not v.opened then
			next_box_award_item = v
			break
		end
	end
	if next_box_award_item then
		local time = 0.1
		seq:Insert(0,next_box_award_item.obj.transform:DOScale(Vector3.New(0.8,0.8,0.8),0.5))
		for i = 1,3 do
			seq:Append(next_box_award_item.obj.transform:DOLocalRotate(Vector3.New(0,0,-35),time,Enum.RotateMode.Fast):SetEase(Enum.Ease.Linear))
			seq:Append(next_box_award_item.obj.transform:DOLocalRotate(Vector3.New(0,0,35),time,Enum.RotateMode.Fast):SetEase(Enum.Ease.Linear))
		end
		seq:Append(next_box_award_item.obj.transform:DOLocalRotate(Vector3.New(0,0,0),time/2,Enum.RotateMode.Fast):SetEase(Enum.Ease.Linear))
		seq:AppendCallback(function()
			next_box_award_item.obj.transform:GetComponent("SpriteRenderer").sprite = GetTexture(next_box_award_item.cfg.open_img)
			if cbk then cbk(next_box_award_item.obj.transform.position) end
		end)
		seq:AppendInterval(0.5)
		seq:AppendCallback(function()
			next_box_award_item.obj.transform.localScale = Vector3.New(0.3,0.3,0.3)
			next_box_award_item.opened = true
		end)
	else
		if cbk then cbk() end
	end
end