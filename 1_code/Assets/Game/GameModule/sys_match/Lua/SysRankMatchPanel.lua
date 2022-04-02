-- 创建时间:2021-06-02
-- Panel:SysRankMatchPanel
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

SysRankMatchPanel = basefunc.class()
local C = SysRankMatchPanel
C.name = "SysRankMatchPanel"

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
	self.listener["ExitScene"] = basefunc.handler(self,self.onExitScene)
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
	self:InitRankUI()
	self:InitMyRankUI()
	self:InitBtnUI()
	self:InitTop()
	self.back_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	self:MyRefresh()
	self:SetOnOff(false)
end

function C:InitBtnUI()
	local config = {"jiangli_btn","duanwei_btn","liansheng_btn"}
	local func = function(btn_name)
		for i = 1,#config do
			self[config[i]].gameObject:SetActive(true)
		end
		self[btn_name].gameObject:SetActive(false)
	end
	self.jiangli_btn.onClick:AddListener(function()
		--奖杯排名
		func("jiangli_btn")
	end)
	self.duanwei_btn.onClick:AddListener(function()
		--段位排名
		func("duanwei_btn")
	end)
	self.liansheng_btn.onClick:AddListener(function()
		--连胜排名
		func("liansheng_btn")
	end)
	func("jiangli_btn")
end

function C:InitRankUI()
	local data = {
		[1] = {head = "xx",rank = 1,jb_num = "",name = ""},
		[2] = {head = "xx",rank = 2,jb_num = "",name = ""},
		[3] = {head = "xx",rank = 3,jb_num = "",name = ""},
		[3] = {head = "xx",rank = 4,jb_num = "",name = ""},
	}
	if self.rank_items then
		for i = 1,#self.rank_items do
			destroy(self.rank_items[i])
		end
	end
	self.rank_items = {}
	for i = 1,#self.rank_items do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.rank_item,self.content)
		basefunc.GeneratingVar(b.transform,temp_ui)
		temp_ui.rank_txt.text = data[i].rank
		temp_ui.head_img.sprite = GetTexture(data[i].head)
		temp_ui.name_txt.text = data[i].name
		temp_ui.jb_num_txt.text = data[i].jb_num
	end
end

function C:InitMyRankUI()
	local data = {
		head = "phb_tx",rank = 1,jb_num = "",name = ""
	}
	self.my_rank_txt.text = data.rank
	self.my_head_img.sprite = GetTexture(data.head)
	self.my_name_txt.text = data.name
	self.my_jb_num_txt.text = data.jb_num
end

function C:InitTop()
	for i = 1,3 do
		self["top"..i.."_jb_num_txt"].text = ""
		self["top"..i.."_jb_name_txt"].text = ""
		self["top"..i.."_head_img"].sprite = GetTexture("") 
	end
end

function C:SetOnOff(isOn)
	for i = 1,3 do
		self["top"..i.."_jb_num_txt"].gameObject:SetActive(isOn)
		self["top"..i.."_jb_name_txt"].text = isOn and self["top"..i.."_jb_name_txt"].text or "虚位以待"
		self["top"..i.."_head_img"].gameObject:SetActive(isOn)
		self["top"..i.."_hold"].gameObject:SetActive(not isOn)
	end
	self.wait.gameObject:SetActive(not isOn)
end

function C:MyRefresh()

end

function C:onExitScene()
	self:MyExit()
end