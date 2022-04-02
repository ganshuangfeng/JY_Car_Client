-- 创建时间:2021-03-03
-- Panel:DriveWaitTablePanel
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

 --匹配中界面
local basefunc = require "Game/Common/basefunc"

DriveWaitTablePanel = basefunc.class()
local C = DriveWaitTablePanel
C.name = "DriveWaitTablePanel"

local instance
function C.Create(parent)
	if instance then
		instance:MyExit()
	end
	instance = C.New(parent)
	return instance
end

function C.Close()
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

function C.GetInstance()
	return instance
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
    self.listener = {}
	self.listener["drive_logic_exit_game"] = basefunc.handler(self,self.MyClose)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
	if self.start_timer then
		self.start_timer:Stop()
		self.start_timer = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
	dump("DriveWaitTablePanel:MyExit")
	clear_table(self)
end
function C:MyClose()
	if self.start_timer then
		self.start_timer:Stop()
		self.start_timer = nil
	end
	self:RemoveListener()
	-- destroy(self.gameObject)
	dump("DriveWaitTablePanel:MyExit")
	clear_table(self)
end

function C:ctor()
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)

	if self.start_timer then self.start_timer:Stop() end
	local start_count = 1
    self.start_timer = Timer.New(
        function()
			start_count = start_count + 1
			if start_count > 3 then start_count = 1 end
			for i = 1,3 do
				if i <= start_count then
					self["icon_" .. i].gameObject:SetActive(true)
				else
					self["icon_" .. i].gameObject:SetActive(false)
				end
			end
        end,1,-1
    )
	self.start_timer:Start()
	self:MakeListener()
	self:AddListener()
	self:InitUI()
	self.cancel_btn.onClick:AddListener(function()
		DriveModel.SendRequest("pvp_quit_game")
	end)

	Event.Brocast("guide_step_trigger")
end

function C:InitUI()
	local match_data = SysMatchManager.GetMatchData()
	local match_cfg = SysMatchManager.GetGradeLevelAward(match_data.grade,match_data.level)
	if match_data then
		self.rank_txt.text = match_cfg.name
		self.rank_img.sprite = GetTexture(match_cfg.icon)
	end
	self:MyRefresh()
end

function C:MyRefresh()
end