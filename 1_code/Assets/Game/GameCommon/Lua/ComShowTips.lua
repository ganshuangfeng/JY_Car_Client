-- 创建时间:2021-06-03
-- Panel:ComShowTips
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

ComShowTips = basefunc.class()
local C = ComShowTips
C.name = "ComShowTips"
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
	self.listener["ExitScene"] = basefunc.handler(self, self.OnExitScene)
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

function C:OnExitScene()
	self:MyExit()
end

function C:ctor(parm)
	local parent = parm.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	basefunc.GeneratingVar(self.transform, self)
	self.parm = parm
	self:MakeListener()
	self:AddListener()
	self:InitUI()
	self.close_btn.onClick:AddListener(function()
		self:MyExit()
	end)
end

function C:InitUI()
	local parm = self.parm
	if parm.ui_pos then
		self.content.transform.localPosition = parm.ui_pos
	end
	if parm.icon_img then
		self.tips_icon_img.gameObject:SetActive(true)
		self.tips_icon_img.sprite = GetTexture(parm.icon_img)
	else
		self.tips_icon_img.gameObject:SetActive(false)
	end
	
	if parm.name then
		self.tips_name_txt.gameObject:SetActive(true)
		self.tips_name_txt.text = parm.name
	else
		self.tips_name_txt.gameObject:SetActive(false)
	end

	if parm.desc then
		self.tips_desc_txt.gameObject:SetActive(true)
		self.tips_desc_txt.text = parm.desc
	else
		self.tips_desc_txt.gameObject:SetActive(false)
	end
	self:LayOutByMySelf()
	self:MyRefresh()
end

function C:MyRefresh()
end

--自适应
function C:LayOutByMySelf()
	local tips_desc_txt_rect = self.tips_desc_txt.gameObject:GetComponent("RectTransform")
	local preferredHeight = self.tips_desc_txt.preferredHeight
	tips_desc_txt_rect.sizeDelta = Vector2.New(tips_desc_txt_rect.sizeDelta.x , preferredHeight)
	self.content.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New(464,192 + preferredHeight + 90)
end