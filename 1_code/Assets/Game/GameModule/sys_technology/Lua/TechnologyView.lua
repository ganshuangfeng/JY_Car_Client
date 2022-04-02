-- 创建时间:2018-05-30

local basefunc = require "Game.Common.basefunc"
TechnologyView = basefunc.class()
local M = TechnologyView
M.name = "TechnologyView"
M.slectBtnName = "TechnologyViewSlectBtn"
local instance
function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeListener()
    self.listener = {}
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M.Create(parm)
	if instance then
		instance:Exit()
	end
	instance = nil
	instance = M.New(parm)
	return instance
end

function M.Close()
	if instance then
		instance:Exit()
	end
	instance = nil
end

function M:ctor(parm)
	local parent = GameObject.Find("Canvas/LayerLv1/HallPanel/@view_node").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	basefunc.GeneratingVar(self.transform, self)
	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function M:Exit()
	self:RemoveListener()

	if self.DOTScrollPage then
		self.DOTScrollPage:Kill()
	end

	destroy(self.gameObject)
	clear_table(self)
	instance = nil
end

function M:MyExit()
	self:Exit()
end

function M:InitUI()
	--初始化UI设置

	self.techCount = TechnologyModel.GetTechCount()
	self:InitSelectBtnPre()
	self:InitSvPoint()
	self:InitTechPre()
	-- EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function(eventData)
	-- 	self:OnSvDragEnd()
	-- end
	-- EventTriggerListener.Get(self.sv.gameObject).onBeginDrag = function(eventData)
	-- 	self:OnSvDragBegin()
	-- end

	self.lscroll_btn.onClick:AddListener(function()
		self:TurnToLeft()
	end)
	self.rscroll_btn.onClick:AddListener(function()
		self:TurnToRight()
	end)
	self:SlectPage(1)
end

function M:InitSelectBtnPre()
	self.selectPre = {}
	for i = 1, self.techCount do
		local b = newObject(M.slectBtnName, self.b_content)
		local b_ui = {}
		basefunc.GeneratingVar(b.transform, b_ui)
		b_ui.name_txt.text = TechnologyModel.GetTechCfgById(i).name
		b_ui.slect_btn.onClick:AddListener(function()
			self:SlectPage(i)
		end)
		self.selectPre[i] = b_ui
	end
end

function M:InitTechPre()
	self.portPred = {}
	for i = 1, self.techCount do
		local p = GameObject.Instantiate(self.t_scroll_rect, self.p_content)
		p.gameObject:SetActive(true)
		local p_ui = {}
		basefunc.GeneratingVar(p.transform, p_ui)
		self.portPred[i] = p_ui
		p_ui.sv = p.transform:GetComponent("ScrollRect")
		self:ScrollViewAddListener(p_ui.sv)
		local skills = TechnologyModel.GetSkillsByTechId(i)
		for j = 1, #skills do
			local skilCfg = skills[j]--TechnologyModel.GetSkillCfgById(skills[j])
			local t = newObject("TechnologyViewItem", p_ui.t_content)
			local t_ui = {}
			basefunc.GeneratingVar(t.transform, t_ui)
			t_ui.icon_img.sprite = GetTexture(SysCarManager.GetMapAssets(skilCfg.icon))
			t_ui.name_txt.text = skilCfg.name
			if skilCfg.desc then
				local parm = {
					parent = self.transform,
					name = skilCfg.name,
					desc = skilCfg.desc,
					icon_img = SysCarManager.GetMapAssets(skilCfg.icon),
				}
				t_ui.tip_btn.onClick:AddListener(function()
					local x = t.gameObject.transform.position.x - 300
					if x < -300 then
						x = t.gameObject.transform.position.x + 300
					end
					parm.ui_pos = Vector3.New(x,t.gameObject.transform.position.y,0)
					ComShowTips.Create(parm)
				end)
			end
		end
	end
end

function M:ScrollViewAddListener(scrollview)
	EventTriggerListener.Get(scrollview.gameObject).onBeginDrag = function(_, eventData)
		self.sv:OnBeginDrag(eventData)
		self:OnSvDragBegin()
	end
	EventTriggerListener.Get(scrollview.gameObject).onDrag = function(_, eventData)
		self.sv:OnDrag(eventData)
		local angle = Vector2.Angle(eventData.delta, Vector2.up)
		if angle > 45 and angle < 135 then
			self.sv.enabled = true
			scrollview.enabled = false
		else
			self.sv.enabled = false
			scrollview.enabled = true
		end
	end
	EventTriggerListener.Get(scrollview.gameObject).onEndDrag = function(_, eventData)
		self.sv:OnEndDrag(eventData)
		self:OnSvDragEnd()
		self.sv.enabled = true
		scrollview.enabled = true
	end
end

function M:InitSvPoint()
	self.sv = self.p_scroll_rect:GetComponent("ScrollRect")
	self.svPoint = {}
	self.svSpace = (1 / (self.techCount - 1))
	for i = 1, self.techCount do
		self.svPoint[i] = (i - 1) * self.svSpace
	end
end

function M:OnSvDragEnd()
	self.isSvDrag = false
	local l = self.sv.horizontalNormalizedPosition
	for i = 1, #self.svPoint do
		if Mathf.Abs(self.svPoint[i] - l) < self.svSpace * 0.5 then
			self:SlectPage(i)
		end
	end
end

function M:OnSvDragBegin()
	self.isSvDrag = true
end

function M:RefreshUI()
	
end

function M:SlectPage(index)
	if index > self.techCount or index < 1 then
		return
	end
	self.svPointIndex = index
	--self.sv.horizontalNormalizedPosition = self.svPoint[index]
	self:PageScroll()
	if index == self.curIndex  then
		return
	end
	self.curIndex = index
	if self.lastIndex then
		self:UnSlectBtnView(self.lastIndex)
	end
	self:SlectBtnView(self.curIndex)
	self.lastIndex = self.curIndex

	if Mathf.Abs(self.curIndex - 1) <= 1 or Mathf.Abs(self.curIndex - self.techCount) <= 1 then
		self.lscroll_btn.gameObject:SetActive(self.curIndex ~= 1)
		self.rscroll_btn.gameObject:SetActive(self.curIndex ~= self.techCount)
	end
end

function M:SlectBtnView(index)
	self.selectPre[index].name_select_txt.text = TechnologyModel.GetTechCfgById(index).name
	self.t_tit_txt.text = TechnologyModel.GetTechCfgById(index).name
	self.tech_icon_img.sprite = GetTexture(TechnologyModel.GetTechCfgById(index).icon)
	self.tech_icon_img:SetNativeSize()
	self.selectPre[index].select_bg.gameObject:SetActive(true)
end

function M:UnSlectBtnView(index)
	self.selectPre[index].name_select_txt.text = ""
	self.selectPre[index].select_bg.gameObject:SetActive(false)
end

function M:TurnToLeft()
	self:SlectPage(self.curIndex - 1)
end

function M:TurnToRight()
	self:SlectPage(self.curIndex + 1)
end

function M:PageScroll()
	if self.isSvDrag then
		return
	end
	if not self.svPointIndex then
		return
	end
	if self.DOTScrollPage then
		self.DOTScrollPage:Kill()
	end
	local end_p = self.svPoint[self.svPointIndex]
	local duration = 0.2
	self.DOTScrollPage = DG.Tweening.DOTween.To(
		DG.Tweening.Core.DOGetter_float(
			function(value)
                return self.sv.horizontalNormalizedPosition
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				self.sv.horizontalNormalizedPosition = value
            end
        ),
        end_p,
		duration
	)
	self.DOTScrollPage:SetEase(Enum.Ease.Linear)
end