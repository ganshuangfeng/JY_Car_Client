-- 创建时间:2021-06-01
-- Panel:SysMatchPanel
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

SysMatchPanel = basefunc.class()
local C = SysMatchPanel
C.name = "SysMatchPanel"

local instance

function C.Create(parm)
	if instance then
		instance:MyExit()
		instance = nil
	end
	instance = C.New(parm)
	return instance
end

function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
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
	self.listener["manager_pvp_duanwei_change_msg"] = basefunc.handler(self,self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
	dump("退出？？？？？？？？？？？？？？？？？？？？？？？")
	SysBoxManager.DeleteBox()
	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil
	clear_table(self)
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
	self.TalkSV = self.talk:Find("Scroll View"):GetComponent("ScrollRect")
	self:MakeListener()
	self:AddListener()
	self:InitUI()
	SysBoxManager.AddBoxNode({self.box1,self.box2,self.box3,self.box4})
end


function C:InitUI()
	self.main_btn.onClick:AddListener(
		function()
			SysMatchAwardPanel.Create()
		end
	)

	self.top_activity_btn.onClick:AddListener(
		function()
			TipsShowUpText.Create("暂未开放！")
		end
	)
	self.rank_btn.onClick:AddListener( 
		function()
			TipsShowUpText.Create("暂未开放！")
			-- SysRankMatchPanel.Create()
		end
	)
	self.rank_match_btn.onClick:AddListener(
		function()
			local main = function()
				Event.Brocast("dbss_send_power",{key = "rank_match_btn_onclick"})
				local game_id = 4
				local map_id = 4
				local scene_name = "game_Drive_map" .. map_id

				GameManager.Goto({
					_goto = scene_name,
					car_id = SysCarManager.GetCurCar().car_id,
					game_id = game_id,
					map_id = map_id
					}
				)
			end
			
			if SysBoxManager.IsEnough() then
				HintPanel.Create({show_no_btn = true,show_yes_btn = true,msg = "宝箱位已满，在段位赛中获胜将不再获得宝箱，是否确认参加段位赛？",yes_callback = function ()
					main()
				end})
			else
				main()
			end
		end
	)
	self.normal_match_btn.onClick:AddListener(
		function()
			TipsShowUpText.Create("暂未开放！")
		end
	)
	self.activity_btn.onClick:AddListener(
		function()
			TipsShowUpText.Create("暂未开放！")
		end
	)
	self.rank_img.gameObject.transform:GetComponent("Button").onClick:AddListener(
		function()
			SysMatchAwardPanel.Create()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	local match_data = SysMatchManager.GetMatchData()
	if match_data then
		self.cup_num_txt.text = match_data.score or ""
		self:RefreshRankProgress()
	end
end

--刷新进度条
function C:RefreshRankProgress()
	local cfg = SysMatchManager.GetMatchCfg()
	
	self.shugan_items = self.shugan_items or {}
	local max_lengh = 727.8
	for i = 1,#self.shugan_items do
		destroy(self.shugan_items[i])
	end
	local match_data = SysMatchManager.GetMatchData()
	local space = max_lengh / match_data.grade_all_level

	for i = 2,match_data.grade_all_level do
		local b = GameObject.Instantiate(self.shugan,self.shugan_node)
		b.gameObject:SetActive(true)
		b.transform.localPosition = Vector3.New((i - 1) *space,0,0)
		self.shugan_items[#self.shugan_items + 1] = b
	end
	local width = space * (match_data.level - 1) + space * match_data.level_cur_score/match_data.level_all_score
	self.rank_pro_width.transform.sizeDelta = {
		x = width,
		y = 60.93,
	}
	self.rank_tips.transform.localPosition = Vector3.New(space * (match_data.level) - (44.4 + max_lengh/2),93,0)
	local award_cfg = SysMatchManager.GetGradeLevelAward(match_data.grade,match_data.level)
	self.rank_tips_img.sprite = GetTexture(award_cfg.award_icon)
	self.rank_img.sprite = GetTexture(cfg.grade[match_data.grade].icon)
	self.rank_img:SetNativeSize()
	self.rank_txt.text = cfg.level[match_data.level].name
end

function C:AddTalkItem(data)
	self.talk_items = {}
	local data = {
		type = "friend",
		desc = "123457689043113",
		name = "张三"
	}
	local type2img = {
		friend = "bs_icon_hy",
		world = "bs_icon_sj",
	}
	local temp_ui = {}
	local b = GameObject.Instantiate(self.talk_item,self.talk_node)
	basefunc.GeneratingVar(b.transform,temp_ui)
	temp_ui.talk_type_img = GetTexture(type2img[data.type])
	temp_ui.talk_txt.text = data.name..": "..data.desc
	self.talk_items[#self.talk_items + 1] = b
	b.gameObject:SetActive(true)
	self.TalkSV.verticalNormalizedPosition = 0
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.TalkSV.gameObject.transform)
end