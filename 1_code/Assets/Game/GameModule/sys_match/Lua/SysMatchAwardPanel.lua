-- 创建时间:2021-06-03
-- Panel:SysMatchAwardPanel
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

SysMatchAwardPanel = basefunc.class()
local C = SysMatchAwardPanel
C.name = "SysMatchAwardPanel"
local num2luoma = {
	"Ⅰ","Ⅱ","Ⅲ","Ⅳ","Ⅴ","Ⅵ","Ⅶ","Ⅷ","Ⅸ"
}
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
	self.listener["manager_pvp_get_award_list_change_msg"] = basefunc.handler(self,self.on_manager_pvp_get_award_list_change_msg)
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
	self.PosData = self:InitHeightPos()
	self.SV = self.transform:Find("Scroll View"):GetComponent("ScrollRect")
	self:MakeListener()
	self:AddListener()
	self:InitUI()
	self:RefreshPro()
	self.SV.verticalNormalizedPosition = self.PosData[self.grade][self.level] / self.total_height
	self:CreateItemByNormalizedPos()
	self:LockUITimer()
	Network.SendRequest("pvp_duanwei_get_award_list")
end

function C:InitUI()
	self.back_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	self.SV.onValueChanged:AddListener(
		function()
			self:CreateItemByNormalizedPos()
		end
	)
	self:InitBaseUI()
	self:MyRefresh()
	self.awardPre = {}
end

--创建一个奖励
function C:CreateOneAward(data, parent, grade, level)
	local temp_ui = {}
	local b = GameObject.Instantiate(self.award_item,parent)
	basefunc.GeneratingVar(b.transform,temp_ui)
	temp_ui.award_txt.text = SysAssetModel.GetItemConfig(data.award_name).name .. "x" .. StringHelper.ToCash(data.award_count)
	b.gameObject:SetActive(true)
	temp_ui.award_icon_img.sprite = GetTexture(SysAssetModel.GetItemImage(data.award_name))
	temp_ui.award_get_btn.onClick:AddListener(function()
		self:OnGetAwardClick(data, grade, level)
	end)
	self:RefreshAwardItemView(grade, level , temp_ui)
	self.awardPre[#self.awardPre + 1] = {}
	self.awardPre[#self.awardPre].grade = grade
	self.awardPre[#self.awardPre].level = level
	self.awardPre[#self.awardPre].temp_ui = temp_ui
	return b
end

function C:RefreshAwardItemView(grade, level, temp_ui)
	local status = SysMatchManager.GetAwardStatus(grade, level)
	if status == 2 then
		temp_ui.finsh.gameObject:SetActive(true)
		temp_ui.award_get_btn.gameObject:SetActive(false)
		temp_ui.award_red.gameObject:SetActive(false)
	else
		temp_ui.finsh.gameObject:SetActive(false)
		temp_ui.award_get_btn.gameObject:SetActive(true)
		temp_ui.award_red.gameObject:SetActive(status == 1)
	end
end

--刷新奖励界面显示
function C:RefreshAwardView()
	for i = 1, #self.awardPre do
		self:RefreshAwardItemView(self.awardPre[i].grade, self.awardPre[i].level, self.awardPre[i].temp_ui)
	end
end

--领取奖励
function C:OnGetAwardClick(data, grade, level)
	if SysMatchManager.GetAwardStatus(grade, level) == 0 then
		dump(self:GetBaseConfig(grade,level).need_score, "<color=red> 需要达到XXX可领取 </color>")
		TipsShowUpText.Create("奖杯数达到" .. self:GetBaseConfig(grade,level).need_score .. "可获得该奖励")
		return
	end
    Network.SendRequest("pvp_duanwei_take_award", {grade = grade , level = level})
end

--奖励列表更新
function C:on_manager_pvp_get_award_list_change_msg()
	self:RefreshAwardView()
end

--创建一个等级的UI
function C:CreateOneGradeUI(grade,level)
	local b = GameObject.Instantiate(self.OneGrade,self.Main_Layout)
	local config = SysMatchManager.config
	b.gameObject:SetActive(true)
	local temp_ui = {}
	basefunc.GeneratingVar(b.transform,temp_ui)
	temp_ui.grade_name_txt.text = config.grade[grade].name
	temp_ui.grade_icon_img.sprite = GetTexture(config.grade[grade].icon)
	temp_ui.grade_icon_img:SetNativeSize()
	temp_ui.level_name_txt.text = grade.."阶竞技场"..num2luoma[1]
	temp_ui.my_jb_num_txt.text = self:GetBaseConfig(grade,level).need_score
	temp_ui.curr_level_need_txt.text = self:GetBaseConfig(grade,level).need_score
	local award_data = self:GetAwardInfo(grade,level)
	for i = 1,#award_data do
		local obj = self:CreateOneAward(award_data[i], temp_ui.layout, grade, level)
	end
	b.transform.localPosition = Vector2.New(0,self.PosData[grade][level])
	return b
end

function C:CreateOneLevelUI(grade,level)
	local b = GameObject.Instantiate(self.level_layout_item,self.Main_Layout)
	local config = SysMatchManager.config
	b.gameObject:SetActive(true)
	local temp_ui = {}
	basefunc.GeneratingVar(b.transform,temp_ui)
	local award_data = self:GetAwardInfo(grade,level)
	for i = 1,#award_data do
		local obj = self:CreateOneAward(award_data[i], temp_ui.award_layout, grade, level)
	end
	temp_ui.level_txt.text = grade.."阶"..num2luoma[level]
	temp_ui.need_txt.text = self:GetBaseConfig(grade,level).need_score
	b.transform.localPosition = Vector2.New(0,self.PosData[grade][level])
	return b
end

function C:MyRefresh()
	local match_data = SysMatchManager.GetMatchData()
	self.curr_jb_num_txt.text = match_data.score
	self.curr_level_name2_txt.text = match_data.grade.."阶"..num2luoma[match_data.level]
	self.my_curr_score_txt.text = match_data.score
end

function C:GetAwardInfo(grade,level)
	local award_config = SysMatchManager.award_config
	local info = {}
	local award_ids = nil
	for i = 1,#award_config.base do
		if award_config.base[i].grade == grade and award_config.base[i].level == level then
			award_ids = award_config.base[i].award_id
		end
	end
	local find_award_info = function(award_id)
		for i = 1,#award_config.award_config do
			if award_config.award_config[i].award_id == award_id then
				return award_config.award_config[i]
			end
		end
	end
	if type(award_ids)== "table" then
		for i = 1,#award_ids do
			info[#info + 1] = find_award_info(award_ids[i])
		end
	else
		info[#info + 1] = find_award_info(award_ids)
	end
	return info
end

function C:GetBaseConfig(grade,level)
	local award_config = SysMatchManager.award_config
	for i = 1,#award_config.base do
		if award_config.base[i].grade == grade and award_config.base[i].level == level then
			return award_config.base[i]
		end
	end
end

function C:GetTotalHeight()
	local config = SysMatchManager.award_config
	local height = 0
	for i = 1,#config.base do
		if config.base[i].level == 1 then
			height = height + 1163.319
		else
			height = height + 280
		end
	end
	return height
end
-- 446 1597.7
function C:InitHeightPos()
	local data = {}
	local config = SysMatchManager.award_config
	local height = 0
	for i = 1,#config.base do
		data[config.base[i].grade] = data[config.base[i].grade] or {}
		if config.base[i - 1] and config.base[i - 1].level == 1 then
			height = height + 1163.319
		else
			height = height + 280
		end
		data[config.base[i].grade][config.base[i].level] = height - 126
	end
	return data
end

function C:GetPosData(grade,level)
	return self.PosData[grade][level]
end

function C:onExitScene()
	self:MyExit()
end

function C:InitBaseUI()
	local total_height = self:GetTotalHeight()
	self.total_height = total_height
	self.pro_bg.transform.sizeDelta = {x = 77.5, y = total_height}
	self.Content.transform.sizeDelta = {x = 1080,y = total_height + 600}
end

--2340 为1页最多可容纳的高度
function C:CreateItemByNormalizedPos()
	self.itmes = self.itmes or {}
	if self.lock then return end
	self.lock = true
	local is_need_create = function(grade,level)
		if self.itmes[grade] and self.itmes[grade][level] then
			return false
		else
			return true
		end
	end
	local vnp =  self.SV.verticalNormalizedPosition
	local see_height = vnp * self.total_height
	local need_create = {}
	for k,v in pairs(self.PosData) do
		for k1,v1 in pairs(v) do
			if math.abs(v1 - see_height) < 2400 and is_need_create(k,k1) then
				local data = {}
				data.grade = k
				data.level = k1
				need_create[#need_create + 1] = data
			end
		end
	end
	for i = 1,#need_create do
		local grade = need_create[i].grade
		local level = need_create[i].level
		if level == 1 then
			local b = self:CreateOneGradeUI(grade,level)
			self.itmes[grade] = self.itmes[grade] or {}
			self.itmes[grade][level] = b
		else
			local b = self:CreateOneLevelUI(grade,level)
			self.itmes[grade] = self.itmes[grade] or {}
			self.itmes[grade][level] = b
		end
	end
end

function C:LockUITimer()
	self.lock = true
	self.Timer = Timer.New(function()
		self.lock = false
	end,0.3,-1)
	self.Timer:Start()
end

function C:RefreshPro()
	--由@pro_bg相比较最低下距离和@pro_height和相比较@pro_bg 的值相加
	local dis_pro =  588.8501 + 19.88
	local big_tag = 436
	local small_tag = 143.625
	local score = SysMatchManager.GetMatchData().score
	local config = SysMatchManager.award_config.base
	local max_score = config[#config].need_score
	local level = 0
	local grade = 0
	local next_level = 0
	local next_grade = 0
	local get_pro_height = function(grade,level)
		local height = self.PosData[grade][level]
		local re = height - dis_pro
		if level == 1 then
			re = re + big_tag
		else
			re = re + small_tag
		end
		return re
	end

	for i = #config,1,-1 do
		if score >= config[i].need_score then
			level = config[i].level
			grade = config[i].grade
			break
		end
	end

	self.level = level
	self.grade = grade
	local base_height = get_pro_height(grade,level)
	local next_height = function()
		for i = #config,1,-1 do
			if score >= config[i].need_score then
				return get_pro_height(config[i + 1].grade,config[i + 1].level)
			end
		end
	end

	local next_score = function()
		for i = #config,1,-1 do
			if score >= config[i].need_score then
				return config[i + 1].need_score
			end
		end
	end

	local base_score = function()
		for i = #config,1,-1 do
			if score >= config[i].need_score then
				return config[i].need_score
			end
		end
	end

	if score < max_score then
		self.pro_height.transform.sizeDelta = {x = 47.1,y = base_height + (next_height() - base_height) * (score - base_score()) / (next_score() - base_score())}
	else
		self.pro_height.transform.sizeDelta = {x = 47.1,y = base_height}
	end
end