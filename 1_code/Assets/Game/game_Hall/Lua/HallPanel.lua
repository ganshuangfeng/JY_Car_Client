local basefunc = require "Game.Common.basefunc"
HallPanel = basefunc.class()
local M = HallPanel
M.name = "HallPanel"

local instance

local listener
function M:MakeListener()
	listener={}
	listener["ExitScene"] = basefunc.handler(self,self.onExitScene)
    listener["asset_change"] = basefunc.handler(self,self.on_asset_change)
	listener["set_head_image"] = basefunc.handler(self, self.set_head_image)
	listener["set_player_name"] = basefunc.handler(self, self.set_player_name)
end

function M:AddListener()
    for proto_name,func in pairs(listener) do
        Event.AddListener(proto_name, func , true)
    end
end

function M:RemoveLister()
    if listener and next(listener) then
		for msg,cbk in pairs(listener) do
			Event.RemoveListener(msg, cbk)
		end	
	end
    listener = nil
end

function M.Create()
	if instance then
		instance:MyExit()
		instance = nil
	end
	instance = M.New()
	return instance
end

function M.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function M:ctor()
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	self.gameObject = newObject(M.name, parent)
	self.transform =  self.gameObject.transform
	basefunc.GeneratingVar(self.transform, self)
	self:MakeListener()
	self:AddListener()

	DeepLinkHelper.OpenDeepLink()
	HandleLoadChannelLua(M.name, self)
	MainLogic.SetGameBGScale(self.BGImg)
	self:InitUI()
	self:MyRefresh()
end

function M:InitUI()
	self.curr_panel = nil
	local config = {
		{btn = "chariot",gotoui = {_goto = "sys_car_upgrade",goto_parm = "view",parent = self.view_node},dbss_key = "sys_car_upgrade_panel"},
		{btn = "equip",gotoui = {_goto = "sys_equipment",goto_parm = "view",parent = self.view_node},dbss_key = "sys_equipment_view"},
		{btn = "match",gotoui = {_goto = "sys_match",goto_parm = "view",parent = self.view_node},dbss_key = "sys_match_panel"},
		{btn = "SAT",gotoui = {_goto = "sys_technology",goto_parm = "view",parent = self.view_node},dbss_key = "sys_techlogy_view"},
		{btn = "shop",gotoui = {},dbss_key = "shop_btn_onclick"},
	}
	local _click_func = function(_c,is_click)
		local mask = _c.btn
		if mask == "shop" then
			TipsShowUpText.Create("暂未开放！")
			return
		end
		Event.Brocast("hall_panel_change_view")
		for k,v in pairs(config) do
			self[v.btn.."_mask"].gameObject:SetActive(false)
		end
		self[mask.."_mask"].gameObject:SetActive(true)
		if self.curr_panel and next(self.curr_panel) then
			self.curr_panel:MyExit()
		end
		self.curr_panel = GameManager.Goto(_c.gotoui)
		if is_click then
			if mask == "chariot" or mask == "match" then
				Event.Brocast("guide_step_complete")
			end
		end
		Event.Brocast("guide_step_trigger")
	end

	for k,v in pairs(config) do
		self[v.btn.."_btn"].onClick:AddListener(
			function()
				if v.dbss_key then
					Event.Brocast("dbss_send_power",{key = v.dbss_key})
				end
				_click_func(v,true)
			end
		)
		local mask_btn = self[v.btn .. "_mask"].transform:GetComponent("Button")
		mask_btn.onClick:AddListener(
			function()
				Event.Brocast("guide_step_complete")
				Event.Brocast("guide_step_trigger")
			end
		)
	end
	_click_func(config[3],false)
	self.set_btn.onClick:AddListener(function()
		self:OnSetBtnClick()
	end)
	self:set_player_name()
	self.shop_gold_txt.text = StringHelper.ToCash(SysAssetModel.GetItemCount("jing_bi")) or 0
	self.shop_diamond_txt.text = StringHelper.ToCash(SysAssetModel.GetItemCount("diamond")) or 0
end

function M:OnSetBtnClick()
	local gotoUI = {_goto = "sys_setting",goto_parm = "view"}
	GameManager.Goto(gotoUI)
end

function M:MyRefresh()

end

function M:MyExit()
	self:RemoveLister()
	destroy(self.gameObject)
	instance = nil
	clear_table(self)
end

function M:set_head_image()
	--刷新头像
	NetworkImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
end

function M:set_player_name()
	self.player_name_txt.text = MainModel.UserInfo.name
end

function M:on_asset_change(data)
	if IsEquals(self.shop_gold_txt) then
		self.shop_gold_txt.text = StringHelper.ToCash(SysAssetModel.GetItemCount("jing_bi")) or 0
	end

	if IsEquals(self.shop_diamond_txt) then
		self.shop_diamond_txt.text = StringHelper.ToCash(SysAssetModel.GetItemCount("diamond")) or 0
	end
end

function M:onExitScene()
	self:MyExit()
	if self.curr_panel then
		self.curr_panel:MyExit()
	end
	self.curr_panel = nil
end