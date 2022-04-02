-- 创建时间:2021-06-08
-- Panel:SysBoxItem
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

SysBoxItem = basefunc.class()
local C = SysBoxItem
C.name = "SysBoxItem"

function C.Create(parm)
	return C.New(parm)
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
    self.listener = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
	if self.Timer then
		self.Timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
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
	self.parm = parm
	self.all_data = parm.data
	self:MakeListener()
	self:AddListener()
	self:InitUI()
	self:MyUpDate()
	self.Timer = Timer.New(
		function()
			self:MyUpDate()
		end
	,1,-1)
	self.Timer:Start()
end

function C:InitUI()
	self.main_btn.onClick:AddListener(
		function()
			if self.time_can_open then
				Network.SendRequest("get_award_timer_box",{pos_id = self.parm.data.index},function(data)
					dump(data,"<color=red>get_award_timer_box</color>")
					Network.SendRequest("query_player_timer_box_data")
					Event.Brocast("notify_asset_change_msg","notify_asset_change_msg",{change_asset = data.award_list,result = 0})
					self:MyExit()
				end)
			else
				SysBoxOpenPanel.Create({index = self.parm.data.index,box_id = self.parm.data.box_id,all_data = self.all_data})
			end
			Event.Brocast("guide_step_complete")
			Event.Brocast("guide_step_trigger")
		end
	)
	local config = SysBoxManager.GetBoxConfigByID(self.parm.data.box_id)
	self.box_img.sprite = GetTexture(config.icon)
	self.use_txt.text = config.use_diamond
	local format_func = function(second)
		if not second or second < 0 then
			return "00分00秒"
		end
		local timeDay = math.floor(second/86400)
		local timeHour = math.fmod(math.floor(second/3600), 24)
		local timeMinute = math.fmod(math.floor(second/60), 60)
		local timeSecond = math.fmod(second, 60)
		if timeDay > 0 then
			return string.format("%d天%d时%d分", timeDay, timeHour, timeMinute, timeSecond)
		elseif timeHour > 0 then
			return string.format("%d时%d分", timeHour, timeMinute, timeSecond)
		elseif timeMinute > 0 then
			return string.format("%d分%02d秒", timeMinute, timeSecond)
		else
			return string.format("%d分%02d秒",0, timeSecond)
		end
	end
	
	self.cut_down_time_txt.text = format_func(config.use_time)
	self.name_img.sprite = GetTexture(config.desc_img)
	self:MyRefresh()
end

function C:MyRefresh()
	local img = {
		"ty_bxbg_1","ty_bxbg_2","ty_bxbg_3"
	}
	self.bg_img.sprite = GetTexture(img[2])
	self.bg_img:SetNativeSize()
end

function C:MyUpDate()
	self.all_data = SysBoxManager.GetDataByPos(self.parm.data.index)
	local box_id = self.parm.data.box_id
	if box_id then
		local config = SysBoxManager.GetBoxConfigByID(self.parm.data.box_id)
		if SysBoxManager.IsCanOpenByTime() then
			self.tips.gameObject:SetActive(true)
			self.name_img.gameObject:SetActive(true)
			self.use.gameObject:SetActive(false)
			self.immediately_open_btn.gameObject:SetActive(false)
			self.swjs.gameObject:SetActive(false)
			self.open_btn.gameObject:SetActive(false)
		else
			self.bg_img.sprite = GetTexture("ty_bxbg_2")
			self.tips.gameObject:SetActive(false)
			self.name_img.gameObject:SetActive(false)
			if self.all_data and self.all_data.start_time then
				local t = self.all_data.start_time + config.use_time - os.time()
				local format_func = function(second)
					if not second or second < 0 then
						return "00分00秒"
					end
					local timeDay = math.floor(second/86400)
					local timeHour = math.fmod(math.floor(second/3600), 24)
					local timeMinute = math.fmod(math.floor(second/60), 60)
					local timeSecond = math.fmod(second, 60)
					if timeDay > 0 then
						return string.format("%d天%d时%d分", timeDay, timeHour, timeMinute, timeSecond)
					elseif timeHour > 0 then
						return string.format("%d时%d分", timeHour, timeMinute, timeSecond)
					elseif timeMinute > 0 then
						return string.format("%d分%02d秒", timeMinute, timeSecond)
					else
						return string.format("%d分%02d秒",0, timeSecond)
					end
				end
				self.cut_down_time_txt.text = format_func(t)
				self.immediately_open_btn.gameObject:SetActive(true)
				self.swjs.gameObject:SetActive(false)
				self.open_btn.gameObject:SetActive(false)
				self.bg_img.sprite = GetTexture("ty_bxbg_1")
				if t<= 0 then
					self.time_can_open = true
					self.bg_img.sprite = GetTexture("ty_bxbg_3")
					self.bg_img:SetNativeSize()
					self.cut_down_time_txt.gameObject:SetActive(false)
					if not self.guangxiao_pre then
						self.guangxiao_pre = newObject("BX_guangxiao",self.transform)
					end
				else
					if self.guangxiao_pre then
						destroy(self.guangxiao_pre)
						self.guangxiao_pre = nil
					end
				end
			else
				self.cut_down_time_txt.text = StringHelper.formatTimeDHMS5_1(config.use_time)
				self.immediately_open_btn.gameObject:SetActive(false)
				self.open_btn.gameObject:SetActive(false)
				self.name_img.gameObject:SetActive(true)
				self.swjs.gameObject:SetActive(true)
			end
		end
	end
end