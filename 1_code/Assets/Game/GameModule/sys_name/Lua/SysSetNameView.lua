-- 创建时间:2021-06-10
-- Panel:SysSetNameView
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

SysSetNameView = basefunc.class()
local C = SysSetNameView
C.name = "SysSetNameView"

function C.Create()
	return C.New()
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
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end

function C:ctor()
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
	self.comfirm_btn.onClick:AddListener(function()
		self:MyExit()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end
