-- 创建时间:2021-06-09
-- Panel:SysAssetGetView
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

SysAssetGetView = basefunc.class()
local C = SysAssetGetView
C.name = "SysAssetGetView"
C.itemName = "SysAssetGetViewItem"

local ctrl = SysAssetController
local model = SysAssetModel

local instance
function C.Create(assetGetData)
	if not instance then
		instance = C.New(assetGetData)
	end
	return instance
end

function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
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
	instance = nil
	self:KillTween()
	self:RemoveListener()
	ctrl.HandleAssetGetViewClose()
	destroy(self.gameObject)
	clear_table(self)
	Event.Brocast("guide_step_trigger")
end

function C:ctor(assetGetData)
	self.assetGetData = assetGetData
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	
	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function C:InitUI()
	self:CreateAward()
	self.close_btn.onClick:AddListener(function()
		self:TweenLeaveCenter()
	end)
	self.bg_black_btn = self.bg_black:GetComponent("Button")
	self.bg_black_btn.onClick:AddListener(function()
		self:TweenLeaveCenter()
	end)
	self:TweenToCenter()
	self:MyRefresh()
end

function C:CreateAward()
	for i = 1, #self.assetGetData do
		local b = newObject(C.itemName, self.i_content)
		local b_ui = {}
		basefunc.GeneratingVar(b.transform, b_ui)
		local cfg = model.GetItemConfig(self.assetGetData[i].asset_type)
		if cfg then
			b_ui.icon_img.sprite = GetTexture(cfg.image)
		end
		b_ui.num_txt.text = "x" .. self.assetGetData[i].asset_value
	end
end

function C:MyRefresh()
end

--进入动画
function C:TweenToCenter()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.content.transform:DOLocalMoveX(0,0.2))
	self.seq:SetEase(Enum.Ease.Linear)
end

--离开动画
function C:TweenLeaveCenter()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.content.transform:DOLocalMoveX(1240,0.2))
	self.seq:SetEase(Enum.Ease.Linear)
	self.seq:OnKill(function()
		self:MyExit()
	end)
end

function C:KillTween()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end