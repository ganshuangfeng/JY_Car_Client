-- 创建时间:2021-01-07
-- Panel:DrivePlayerInfoItem
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

DrivePlayerInfoItem = basefunc.class()
local C = DrivePlayerInfoItem
C.name = "DrivePlayerInfoItem"

function C.Create(parent,attribute_data,seat_num)
	return C.New(parent,attribute_data,seat_num)
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
    self.listener = {}
	self.listener["drive_game_process_data_msg_begin"] = basefunc.handler(self,self.on_drive_game_process_data_msg_begin)
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

function C:ctor(parent,attribute_data,seat_num)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj
	if seat_num == 1 then
		obj = newObject(C.name .. "_1_3d", parent)
	elseif seat_num == 2 then
		obj = newObject(C.name .. "_2_3d", parent)
	else
		obj = newObject(C.name, parent)
	end
	self.seat_num = seat_num
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	--维护一个当前正在显示的数据
	self.attribute_data = attribute_data
	self.attribute_data.hd_max = self.attribute_data.hd
	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function C:SetStyle()
	self.hp_progress_bg_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_img_xt_bg"))
	self.circle_progress_bg_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_img_xt_bg"))
end

function C:InitUI()
	self:SetStyle()
	self.player_name_txt.text = DriveModel.data.players_info[self.seat_num].name
	self:MyRefresh(nil,{is_start = true})
end

function C:MyRefresh(attribute_data,_data)
	self.virtual_circle_start = DriveCarManager.GetVirtualCircle({is_start = true,seat_num = self.seat_num})
	self.virtual_circle_end = DriveCarManager.GetVirtualCircle({seat_num = self.seat_num})
	self.virtual_circle_offset = 0
	local hd_max = self.attribute_data.hd_max
	if attribute_data then self.attribute_data = attribute_data end

	self.attribute_data.hd_max = hd_max
	if self.attribute_data.hd and self.attribute_data.hd_max < self.attribute_data.hd then
		self.attribute_data.hd_max = self.attribute_data.hd
	end
	self.player_car_img.sprite = GetTexture(SysCarManager.config.car_config[self.attribute_data.id].image_config.game_top_img)
	-- self.player_car_img:SetNativeSize()
	self.player_attack_txt.text = self.attribute_data.at or 0
	self.player_speed_txt.text = self.attribute_data.sp / 10 or 0
	self.player_gold_txt.text = self.attribute_data.money or 0

	local virtual_circle = self.virtual_circle_end
	local cur_circle = self.attribute_data.circle or 0
	if _data and _data.is_start then
		cur_circle = (cur_circle - self.virtual_circle_start)
	else
		cur_circle = (cur_circle - self.virtual_circle_end)
	end

	self.player_circle_txt.text = cur_circle .. "/" .. (DriveModel.data.total_round or 60)

	if self.attribute_data.hp <= 0 then 
		self.attribute_data.hp = 0
		Event.Brocast("player_info_item_hp_zero",{car_no = self.attribute_data.car_no})
	end
	self:RefreshHpProgress()
	self:RefreshCircleProgress(cur_circle)
	self:RefreshHdProgress()
end

function C:ChangeAttribute(change_type,modify_value)
	local change_method_map = {
		hp = self.OnHpChange,
		hp_max = self.OnHpMaxChange,
		at = self.OnAttackChange,
		sp = self.OnSpeedChange,
		money = self.OnMoneyChange,
		circle = self.OnCircleChange,	
		hd = self.OnHdChange,
	}
	if change_method_map[change_type] then
		change_method_map[change_type](self,modify_value)
	else
		dump(change_type,"<color=red>PlayerInfoItem改变属性：没有该属性对应的改变方法</color>")
	end
end

function C:OnHpChange(modify_value)
	--数据
	self.attribute_data.hp = self.attribute_data.hp + modify_value
	if self.attribute_data.hp <= 0 then 
		self.attribute_data.hp = 0
		Event.Brocast("player_info_item_hp_zero",{car_no = self.attribute_data.car_no})
	end
	if self.attribute_data.hp > self.attribute_data.hp_max then 
		self.attribute_data.hp = self.attribute_data.hp_max
	end
	--UI
	self:RefreshHpProgress()
end

local hp_max_width = 3.84
local hp_max_height = 0.34

function C:RefreshHpProgress()
	--现在用fill_amount控制
	local fill_amount = self.attribute_data.hp / self.attribute_data.hp_max
	if fill_amount > 1 then fill_amount = 1 end
	if self.hp_progress_bar:GetComponent("Image") then
		local hp_progress = self.hp_progress_bar:GetComponent("Image")
		hp_progress.fillAmount = fill_amount
	elseif self.hp_progress_bar:GetComponent("SpriteRenderer") then
		local hp_progress = self.hp_progress_bar:GetComponent("SpriteRenderer")
		hp_progress.size = {x = hp_max_width * fill_amount,y = hp_max_height}
	end
	self.player_hp_txt.text = self.attribute_data.hp
end

function C:OnHdChange(modify_value)
	--数据
	if self.attribute_data.hd == 0 and modify_value > 0 then
		self.attribute_data.hd_max = modify_value
		Event.Brocast("player_info_item_hd_create",{car_no = self.attribute_data.car_no})
	end

	if self.attribute_data.hd > 0 and self.attribute_data.hd + modify_value <= 0 then
		Event.Brocast("player_info_item_hd_dead",{car_no = self.attribute_data.car_no})
	end

	self.attribute_data.hd = self.attribute_data.hd + modify_value
	if self.attribute_data.hd <= 0 then 
		self.attribute_data.hd = 0
		Event.Brocast("player_info_item_hd_zero",{car_no = self.attribute_data.car_no})
	end
	if self.attribute_data.hd > self.attribute_data.hd_max then 
		self.attribute_data.hd = self.attribute_data.hd_max
	end
	--UI
	self:RefreshHdProgress()
end

local hd_max_width = 3.84
local hd_max_height = 0.15
function C:RefreshHdProgress()
	--现在用fill_amount控制
	local fill_amount = self.attribute_data.hd / (self.attribute_data.hd_max or 500)
	if fill_amount > 1 then fill_amount = 1 end
	if self.hd_progress_bar:GetComponent("Image") then
		local hd_progress = self.hd_progress_bar:GetComponent("Image")
		hd_progress.fillAmount = fill_amount
	elseif self.hd_progress_bar:GetComponent("SpriteRenderer") then
		local hd_progress = self.hd_progress_bar:GetComponent("SpriteRenderer")
		hd_progress.size = {x = hd_max_width * fill_amount,y = hd_max_height}
	end
	self.player_hd_txt.text = self.attribute_data.hd
	self.player_hd_txt.transform.parent.gameObject:SetActive(not (self.attribute_data.hd <= 0))
end

function C:OnAttackChange(modify_value)
	-- modify_value = modify_value or 0
	--数据
	self.attribute_data.at = self.attribute_data.at or 0
	self.attribute_data.at = self.attribute_data.at + modify_value
	--UI
	self.player_attack_txt.text = self.attribute_data.at
	local seq = DoTweenSequence.Create()
	seq:Append(self.player_attack_txt.transform:DOScale(Vector3.New(1.5,1.5,1),0.3))
	seq:Append(self.player_attack_txt.transform:DOScale(Vector3.New(1,1,1),0.3))
end

function C:OnSpeedChange(modify_value)
	--数据
	self.attribute_data.sp = self.attribute_data.sp or 0
	self.attribute_data.sp = self.attribute_data.sp + modify_value
	--UI
	self.player_speed_txt.text = self.attribute_data.sp / 10
	local seq = DoTweenSequence.Create()
	seq:Append(self.player_speed_txt.transform:DOScale(Vector3.New(1.5,1.5,1),0.3))
	seq:Append(self.player_speed_txt.transform:DOScale(Vector3.New(1,1,1),0.3))
end

function C:OnMoneyChange(modify_value)
	--数据
	self.attribute_data.money = self.attribute_data.money or 0
	self.attribute_data.money = self.attribute_data.money + modify_value
	--UI
	self.player_gold_txt.text = self.attribute_data.money
end

function C:OnCircleChange(modify_value)
	--数据
	self.attribute_data.circle = self.attribute_data.circle or 0
	self.attribute_data.circle = self.attribute_data.circle + modify_value
	--UI

	if self.virtual_circle_end ~= self.virtual_circle_start then
		self.virtual_circle_offset = self.virtual_circle_offset + 1
	end

	if self.virtual_circle_start + self.virtual_circle_offset > self.virtual_circle_end then
		self.virtual_circle_offset = self.virtual_circle_end - self.virtual_circle_start
	end

	local virtual_circle = self.virtual_circle_start + self.virtual_circle_offset
	local cur_circle = self.attribute_data.circle or 0

	-- dump({start = self.virtual_circle_start,e = self.virtual_circle_end,o = self.virtual_circle_offset},"<color=white>当前虚拟数值</color>")

	self.player_circle_txt.text = (cur_circle - virtual_circle).. "/" .. (DriveModel.data.total_round or 60)
	self:RefreshCircleProgress()
end

function C:RefreshCircleProgress(cur_circle)
	--现在用fill_amount控制
	local virtual_circle = self.virtual_circle_start + self.virtual_circle_offset
	cur_circle = cur_circle or (self.attribute_data.circle - virtual_circle)
	local fill_amount = cur_circle / (DriveModel.data.total_round or 60)
	if fill_amount > 1 then fill_amount = 1 end
	local circle_progress = self.circle_progress_bar:GetComponent("Image")
	circle_progress.fillAmount = fill_amount
end

function C:on_drive_game_process_data_msg_begin(  )
	self.virtual_circle_start = DriveCarManager.GetVirtualCircle({is_start = true,seat_num = self.seat_num})
	self.virtual_circle_end = DriveCarManager.GetVirtualCircle({seat_num = self.seat_num})
	self.virtual_circle_offset = 0
end
