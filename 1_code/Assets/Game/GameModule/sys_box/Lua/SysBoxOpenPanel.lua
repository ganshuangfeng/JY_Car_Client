-- 创建时间:2021-06-08
-- Panel:SysBoxOpenPanel
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

SysBoxOpenPanel = basefunc.class()
local C = SysBoxOpenPanel
C.name = "SysBoxOpenPanel"
local jiantou_x = {
	-395,-138,129,393
}

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
    for proto_name,func in pairs(self.listener or {}) do
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
	clear_table(self)
end

function C:ctor(parm)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parm = parm
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	
	self.unlock_btn.onClick:AddListener(
		function()
			dump(self.all_data,"<color=white>解锁？？？？？？？？</color>")
			Network.SendRequest("unlock_timer_box_by_time",{pos_id = self.parm.index},function(data)
				if data.result ~= 0 then
					TipsShowUpText.Create(errorCode[data.result])
					return
				end
				dump(data,"<color=red>unlock_timer_box_by_time</color>")
				self:MyExit()
				Event.Brocast("guide_step_complete")
				Event.Brocast("guide_step_trigger")
			end)
		end
	)
	self.immediately_open_btn.onClick:AddListener(
		function()
			Network.SendRequest("get_award_timer_box",{pos_id = self.parm.index,is_spend_diamond = 1},function(data)
				dump(data,"<color=red>unlock_timer_box_by_diamond</color>")
				if data.result ~= 0 then
					TipsShowUpText.Create(errorCode[data.result],nil,{showtime = 1})
					return
				end
				Network.SendRequest("query_player_timer_box_data")
				Event.Brocast("notify_asset_change_msg","notify_asset_change_msg",{change_asset = data.award_list,result = 0})
				self:MyExit()
			end)
		end
	)
	self.immediately_open2_btn.onClick:AddListener(
		function()
			Network.SendRequest("get_award_timer_box",{pos_id = self.parm.index,is_spend_diamond = 1},function(data)
				dump(data,"<color=red>unlock_timer_box_by_diamond</color>")
				if data.result ~= 0 then
					TipsShowUpText.Create(errorCode[data.result],nil,{showtime = 1})
					return
				end
				Network.SendRequest("query_player_timer_box_data")
				Event.Brocast("notify_asset_change_msg","notify_asset_change_msg",{change_asset = data.award_list,result = 0})
				self:MyExit()
			end)
		end
	)

	self:MakeListener()
	self:AddListener()
	self:InitUI()
	self.jiantou.transform.localPosition = Vector3.New(jiantou_x[self.parm.index],-399.3,0)
	self:MyUpDate()
	self.Timer = Timer.New(
		function()
			self:MyUpDate()
		end
	,1,-1)
	self.Timer:Start()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	local config = SysBoxManager.GetBoxConfigByID(self.parm.box_id)
	dump(SysBoxManager.GetAwardConfigByID(self.parm.box_id))
	self.box_name_img.sprite = GetTexture(config.desc_img)
	self.box_img.sprite = GetTexture(config.icon)
	self:InitAWARDUI(config.certainly_award,self.node1)
	self:InitAWARDUI(config.probability_award,self.node2)
	self:MyRefresh()
end

function C:InitAWARDUI(config,node)
	local AWARD = config
	local init_func = function(id)
		local temp_ui = {}
		local b = GameObject.Instantiate(self.award_item,node)
		local award_config = SysBoxManager.GetAwardConfigByID(id)
		basefunc.GeneratingVar(b.transform,temp_ui)
		temp_ui.award_img.sprite = GetTexture(award_config.award_icon)
		temp_ui.award_txt.text = award_config.award_desc
		temp_ui.award_btn.onClick:AddListener(function()
			if award_config and award_config.item_key then
				local item_cfg = SysAssetModel.GetItemConfig(award_config.item_key)
				if item_cfg then
					local _dis = 250
					if b.transform.position.x > 0 then _dis = -_dis end
					local parm = {
						parent = self.transform.parent,
						name = item_cfg.name,
						desc = item_cfg.desc,
						icon_img = item_cfg.image,
						ui_pos = Vector3.New(b.transform.position.x + _dis,b.transform.position.y,0)
					}
					ComShowTips.Create(parm)
				end
			end
		end)
		b.gameObject:SetActive(true)
	end
	if type(AWARD) == "table" then
		for i = 1,#AWARD do
			init_func(AWARD[i])
		end
	else
		init_func(AWARD)
	end
end

function C:MyUpDate()
	if not self.parm then self:MyExit() return end
	local config = SysBoxManager.GetBoxConfigByID(self.parm.box_id)
	self.all_data = SysBoxManager.GetDataByPos(self.parm.index)

	if SysBoxManager.IsCanOpenByTime() then
		self.use_diamond2.gameObject:SetActive(false)
		self.use_diamond.gameObject:SetActive(false)
		self.use_time.gameObject:SetActive(true)
		self.use_diamond_txt.text = config.use_diamond
		self.cut_down_time_txt.text = StringHelper.formatTimeDHMS5_1(config.use_time)
		if config.use_diamond <= SysAssetModel.GetItemCount("diamond") then
			self.use_diamond_txt.color = Color.New(255,255,255,255)
		else
			self.use_diamond_txt.color = Color.New(255,0,0,255)
		end
	else
		if self.all_data and self.all_data.start_time then
			local t = self.all_data.start_time + config.use_time - os.time()
			self.cut_down_time_txt.text = StringHelper.formatTimeDHMS5_1(t)
			self.use_diamond2.gameObject:SetActive(true)
			self.use_diamond.gameObject:SetActive(false)
			self.use_time.gameObject:SetActive(false)
			self.cut_down_time2_txt.text = StringHelper.formatTimeDHMS5_1(t)
			local need_diamond = math.ceil(t/600) + config.use_diamond
			self.use_diamond2_txt.text = need_diamond
			if need_diamond <= SysAssetModel.GetItemCount("diamond") then
				self.use_diamond2_txt.color = Color.New(255,255,255,255)
			else
				self.use_diamond2_txt.color = Color.New(255,0,0,255)
			end
			if t<= 0 then
				self:MyExit()
			end
		else
			self.cut_down_time_txt.text = StringHelper.formatTimeDHMS5_1(config.use_time)
			self.use_diamond2.gameObject:SetActive(false)
			self.use_diamond.gameObject:SetActive(true)
			self.use_time.gameObject:SetActive(false)
			self.use_diamond_txt.text = math.ceil(config.use_time/600) + config.use_diamond
			if config.use_diamond <= SysAssetModel.GetItemCount("diamond") then
				self.use_diamond_txt.color = Color.New(255,255,255,255)
			else
				self.use_diamond_txt.color = Color.New(255,0,0,255)
			end
		end
	end

	

end

function C:MyRefresh()
end
