-- 创建时间:2018-07-31

local basefunc = require "Game.Common.basefunc"

HallBannerWidget = basefunc.class()

local instance = nil
function HallBannerWidget.Create(parent,widget_config)
	instance = HallBannerWidget.New(parent,widget_config)
    return instance
end
function HallBannerWidget.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

local listener
function HallBannerWidget:MakeListener()
	listener={}
	listener["finish_gift_shop"] = basefunc.handler(self, self.finish_gift_shop)
end
function HallBannerWidget:AddListener()
    for proto_name,func in pairs(listener) do
        Event.AddListener(proto_name, func)
    end
end

function HallBannerWidget:RemoveLister()
    for msg,cbk in pairs(listener) do
        Event.RemoveListener(msg, cbk)
    end
    listener=nil
end

local widget_obj_list = {}

local widget_obj_config = {}

function HallBannerWidget:ctor(parent,widget_config)
    self.gameObject = newObject("HallBannerWidget", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform
	widget_obj_config = widget_config
	widget_obj_list = widget_config
    self:MakeListener()
    self:AddListener()

    self.Content = tran:Find("Mask/Content")
    self.TopScroll = tran:Find("TopScroll"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopScroll.gameObject).onDown = basefunc.handler(self, self.OnScrollDown)
    EventTriggerListener.Get(self.TopScroll.gameObject).onUp = basefunc.handler(self, self.OnScrollUp)
	self.cell = GetPrefab("BannerPrefab")
	self.dotCell = tran:Find("DotPrefab")
	self.DotNode = tran:Find("DotNode")

	self.CellSize = {x = 1080, y = 690}
	self.isScroll = false
	self.isScrollLock = false
	self.isOpenScroll = true
	self.UpdateTime = Timer.New(basefunc.handler(self, self.Update), 0.1, -1, nil, true)
	self.UpdateTime:Start()
	self:InitRect()
	self.minPY = 0
end

function HallBannerWidget:finish_gift_shop(id)
	self.isScroll = false
	self.isScrollLock = false
	self.isOpenScroll = false
	if self.UpdateTime then
		self.UpdateTime:Stop()
	end
	self:KillAnim()

	self.UpdateTime = Timer.New(basefunc.handler(self, self.Update), 0.1, -1, nil, true)
	self.UpdateTime:Start()
    self:InitRect()	
end

function HallBannerWidget:OnScrollDown()
	if not self.isOpenScroll then
		return
	end
	if self.isScrollLock then
		return
	end
	self:KillAnim()
	self.begPos = UnityEngine.Input.mousePosition
	self.latelyPos = UnityEngine.Input.mousePosition
	self.isScroll = true
end
function HallBannerWidget:OnScrollUp()
	if not self.isOpenScroll then
		return
	end
	if self.isScrollLock then
		return
	end
	self.isScroll = false
	self.isScrollLock = true
	self.minPY = self.latelyPos.x - self.begPos.x
	self:Springback()
end
function HallBannerWidget:Springback()
	local x = -1 * self.Content.transform.localPosition.x
	local jindian
	local i
	for k,v in ipairs(self.BannerCellList) do
		local bx = v.transform.localPosition.x
		if math.abs(self.minPY) > 20 then
			if self.minPY < 0 then
				if bx > x then
					if jindian then
						if math.abs(jindian - x) > math.abs(bx - x) then
							jindian = bx
							i = k
						end
					else
						jindian = bx
						i = k
					end
				end
			else
				if bx < x then
					if jindian then
						if math.abs(jindian - x) > math.abs(bx - x) then
							jindian = bx
							i = k
						end
					else
						jindian = bx
						i = k
					end
				end
			end
		else
			if jindian then
				if math.abs(jindian - x) > math.abs(bx - x) then
					jindian = bx
					i = k
				end
			else
				jindian = bx
				i = k
			end
		end
	end
	if jindian then
		self.forSeq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToExit(self.forSeq)
		self.forSeq:Append(self.Content.transform:DOLocalMoveX(-1 * jindian, 0.2))
		self.forSeq:OnComplete(function ()
			self:UpdateSelect(i)
		end)
		self.forSeq:OnKill(function ()
			self.isScrollLock = false
			DOTweenManager.RemoveExitTween(tweenKey)
			if IsEquals(self.Content) then
				self.Content.transform.localPosition = Vector3.New(-1 * jindian, 0, 0)
			end
		end)
	else
		self.isScrollLock = false
	end
end
function HallBannerWidget:Update()
	if self.isScrollLock then
		return
	end
	if self.isScroll then
		local pos = UnityEngine.Input.mousePosition
		local px = pos.x - self.latelyPos.x
		self.Content.transform:Translate (px, 0, 0)
		self.latelyPos = pos

		local x = -1 * self.Content.transform.localPosition.x
		self:RefreshData(x)
	end
end
function HallBannerWidget:RefreshData(x)
	while(true)	do
		if self.leftX > x then
			self.leftX = self.leftX - self.CellSize.x
			self.rightX = self.rightX - self.CellSize.x
			self.leftIndex = self.leftIndex - 1
			if self.leftIndex <= 0 then
				self.leftIndex = #widget_obj_list
			end
			self.rightIndex = self.rightIndex - 1
			if self.rightIndex <= 0 then
				self.rightIndex = #widget_obj_list
			end
			self.BannerCellList[self.leftIndex].gameObject.transform.localPosition = Vector3.New(self.leftX, 0, 0)
		elseif self.rightX < x then
			self.leftX = self.leftX + self.CellSize.x
			self.rightX = self.rightX + self.CellSize.x
			self.leftIndex = self.leftIndex + 1
			if self.leftIndex > #widget_obj_list then
				self.leftIndex = 1
			end
			self.rightIndex = self.rightIndex + 1
			if self.rightIndex > #widget_obj_list then
				self.rightIndex = 1
			end
			self.BannerCellList[self.rightIndex].gameObject.transform.localPosition = Vector3.New(self.rightX, 0, 0)
		else
			break
		end
	end
end
function HallBannerWidget:UpdateSelect(id)
	self.selectIndex = id
	for k,v in ipairs(self.DotCellList) do
		if k == self.selectIndex then
			v:Find("Image").gameObject:SetActive(true)
		else
			v:Find("Image").gameObject:SetActive(false)
		end
	end
	if self.DotCellList and #self.DotCellList > 1 then
		-- self:PlayAnim()
	end
end
function HallBannerWidget:InitRect()
	self:CloseItem()
	-- BannerModel.CalcHallBannerList()
	if #widget_obj_list > 1 then
		self.isOpenScroll = true
	else
		self.isOpenScroll = false
	end
	self.leftX = 0
	self.rightX = (#widget_obj_list-1) * self.CellSize.x
	self.leftIndex = 1
	self.rightIndex = #widget_obj_list
	self.selectIndex = 1
	local nn = 0
	for k,v in ipairs(widget_obj_list) do
		local obj = self:CreateItem(k)
		obj.transform.localPosition = Vector3.New(nn * self.CellSize.x, 0, 0)
		nn = nn + 1
		self.BannerCellList[#self.BannerCellList + 1] = obj

		local dotObj = GameObject.Instantiate(self.dotCell, self.DotNode)
		self.DotCellList[#self.DotCellList + 1] = dotObj
		dotObj.gameObject:SetActive(true)
		dotObj.name = "" .. k
		EventTriggerListener.Get(dotObj.gameObject).onClick = basefunc.handler(self, self.OnDotClick)
	end
	self:UpdateSelect(1)
end
function HallBannerWidget:CreateItem(id)
	local config = widget_obj_config[id]
	local obj = GameObject.Instantiate(self.cell, self.Content)
	local obj_img = obj.transform:Find("Image"):GetComponent("Image")
	-- GetTextureExtend(obj_img, config.imageName, config.is_local_icon)
	obj_img.sprite = GetTexture(config.imageName)
	obj_img:SetNativeSize()
	obj.name = "" .. id
	EventTriggerListener.Get(obj).onClick = basefunc.handler(self, self.OnClick)
	if GameGlobalOnOff.Banner then
		obj:GetComponent("Button").enabled = false
	else
		obj:GetComponent("Button").enabled = false
	end

	return obj
end
function HallBannerWidget:OnDotClick(obj)
	local id = tonumber(obj.name)
	local x = self.BannerCellList[id].gameObject.transform.localPosition.x
	self.Content.transform.localPosition = Vector3.New(-1 * x, 0, 0)
	self:UpdateSelect(id)
end
function HallBannerWidget:OnClick(obj)
	if true then return end
	if not self.minPY or math.abs(self.minPY) > 20 then
		return
	end
	AudioManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	local id = tonumber(obj.name)
	local config = widget_obj_config[id]
	if config.gotoUI and next(config.gotoUI) then
		if #config.gotoUI == 1 then
			GameManager.Goto({_goto=config.gotoUI[1]})
		elseif #config.gotoUI == 2 then
			GameManager.Goto({_goto=config.gotoUI[1], goto_scene_parm=config.gotoUI[2]})
		else
			dump(config.gotoUI, "<color=red>不支持2个以上的参数</color>")
		end
	else
		if config.gotoID then
			GameManager.Goto({_goto = "sys_banner",goto_scene_parm="panel_show",id = config.gotoID})
		else
			print("<color=red>没有地方可去 id=" .. id .. "</color>")
		end
	end	
end

function HallBannerWidget:CloseItem()
	if self.BannerCellList then
		for k,v in ipairs(self.BannerCellList) do
			GameObject.Destroy(v)
		end
	end
	self.BannerCellList = {}

	if self.DotCellList then
		for k,v in ipairs(self.DotCellList) do
			GameObject.Destroy(v.gameObject)
		end
	end
	self.DotCellList = {}
end
function HallBannerWidget:PlayAnim()
	local xx = -1 * (self.Content.transform.localPosition.x - 10)
	self:RefreshData(xx)

	self:KillAnim()
	local x=self.Content.transform.localPosition.x - self.CellSize.x
	self.bannerSeq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToExit(self.bannerSeq)
	self.bannerSeq:AppendInterval(5)
	self.bannerSeq:Append(self.Content.transform:DOLocalMoveX(x, 0.2))
	self.bannerSeq:OnComplete(function ()
		self.selectIndex = self.selectIndex + 1
		if self.selectIndex > #widget_obj_list then
			self.selectIndex = 1
		end
		self:UpdateSelect(self.selectIndex)
	end)
	self.bannerSeq:OnKill(function ()
		DOTweenManager.RemoveExitTween(tweenKey)
		if IsEquals(self.Content) then
			self.Content.transform.localPosition.x=x
		end
	end)
end
function HallBannerWidget:KillAnim()
	if self.bannerSeq then
		self.bannerSeq:Kill()
		self.bannerSeq = nil
	end
	if self.forSeq then
		self.forSeq:Kill()
		self.forSeq = nil
	end
end

function HallBannerWidget:MyExit()
	if self.UpdateTime then
		self.UpdateTime:Stop()
	end
	self:RemoveLister()
	self.cell = nil
	self.UpdateTime = nil
	clear_table(self)
end