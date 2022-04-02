-- 创建时间:2019-01-08

local basefunc = require "Game.Common.basefunc"

ComFlyAnim = basefunc.class()

local M = ComFlyAnim
local ComFlyType = 
{
	jing_bi = "CFT_Gold", -- 金币
	shop_gold_sum = "CFT_Red", -- 福卡
}
local ComFlyTypeToImage = 
{
	jing_bi = "zd_icon_jb_1", -- 金币
	shop_gold_sum = "com_award_icon_money", -- 福卡
}

local FlyParm = 
{
	[1] = 
	{
		mt = 0.5,
		count = 2,
		scale = 0.4,
		minr = 40,
		maxr = 100,
	},
	[2] = 
	{
		mt = 0.5,
		count = 6,
		scale = 0.3,
		minr = 40,
		maxr = 120,
	},
	[3] = 
	{
		mt = 0.5,
		count = 40,
		scale = 0.3,
		minr = 50,
		maxr = 150,
	},
	[4] = 
	{
		mt = 0.5,
		count = 1,
		scale = 0.3,
		minr = 1,
		maxr = 1,
	},
	[5] = 
	{
		mt = 0.5,
		count = 20,
		scale = 0.3,
		minr = 120,
		maxr = 360,
	},
}

M.name = "ComFlyAnim"
function M.Create(index, pos1, pos2, flytype, change_value, finishcall, parent, not_rotation)
	return M.New(index, pos1, pos2, flytype, change_value, finishcall, parent,not_rotation)
end

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

function M:MyClose()
	self:MyExit()
	GameObject.Destroy(self.gameObject)
end

function M:MyExit()
	self:RemoveListener()
	clear_table(self)
end

function M:ctor(index, pos1, pos2, flytype, change_value, finishcall, parent, not_rotation)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform

	self.pos1 = parent:InverseTransformPoint(pos1)
	self.pos2 = parent:InverseTransformPoint(pos2)
	self.change_value = change_value
	self.finishcall = finishcall
	self.flytype = flytype
	self.not_rotation = not_rotation
	
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeListener()
	self:AddListener()
	
	self.Cell = tran:Find("Cell")
	self.ChangeCell = tran:Find("ChangeCell")

	self.index = index
	self.finishcount = 0
	self:UpdateUI()
end

function M:UpdateUI()

	for i = 1, FlyParm[self.index].count do
		local prefab = CachePrefabManager.Take("ComFlyGlodPrefab")
		prefab.prefab:SetParent(self.transform)
		local go = prefab.prefab:GetObj()
		if IsEquals(go) then
			go.transform.localScale = Vector3.New(FlyParm[self.index].scale, FlyParm[self.index].scale, 0)
			local icon = go.transform:Find("Icon"):GetComponent("Image")
			if ComFlyTypeToImage[self.flytype] then
				icon.sprite = GetTexture(ComFlyTypeToImage[self.flytype])
			elseif GameItemModel.GetItemToKey(self.flytype) then
				local cfg = GameItemModel.GetItemToKey(self.flytype)
				GetTextureExtend(icon, cfg.image, cfg.is_local_icon)
			else
				icon.sprite = GetTexture(ComFlyTypeToImage["jing_bi"])
			end
			go.transform.localPosition = self.pos1
			self:BeginAnim(go, prefab)
		end
	end

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToExit(seq)
	seq:AppendInterval(FlyParm[self.index].mt)
	seq:OnComplete(function ()
	end)
	seq:OnKill(function ()
		DOTweenManager.RemoveExitTween(tweenKey)
	end)
end
function M:BeginAnim(go, prefab)
	local r = math.random(0, 360)
	local R = math.random(FlyParm[self.index].minr, FlyParm[self.index].maxr)
	local x = math.sin(math.rad(r))*R
	local y = math.cos(math.rad(r))*R

	local speed = 150
	local mt = FlyParm[self.index].mt--math.sqrt(x*x+y*y)/speed
	local rt = FlyParm[self.index].mt--math.sqrt(x*x+y*y)/speed
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToExit(seq)
	seq:Append(go.transform:DOLocalMove(Vector3.New(self.pos1.x + x, self.pos1.y + y, 0), mt):SetEase(Enum.Ease.Linear))
	if not self.not_rotation then
		seq:Join(go.transform:DORotate(Vector3.New(0, 660+math.random(0, 120), math.random(0, 180)), rt, Enum.RotateMode.FastBeyond360):SetEase(Enum.Ease.Linear))
	end
	seq:OnKill(function ()
		DOTweenManager.RemoveExitTween(tweenKey)
		self:MoveAnim(go, prefab)
	end)
end

function M:MoveAnim(go, prefab)
	if not IsEquals(go) then return end
	local h = math.random(100, 260)
	local t = math.random(50, 100) / 100.0
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToExit(seq)
	seq:Append(go.transform:DOMoveLocalBezier(self.pos2, h, t):SetEase(Enum.Ease.InCubic))
	seq:OnComplete(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
			prefab = nil
		end
	end)
	seq:OnKill(function ()
		self:AnimFinish()
		DOTweenManager.RemoveExitTween(tweenKey)
		if prefab then
			CachePrefabManager.Back(prefab)
			prefab = nil
		end
	end)
end
function M:AnimFinish()
	self.finishcount = self.finishcount + 1
	if self.finishcount >= FlyParm[self.index].count then
		self:FinishCall()
	end
end

function M:FinishCall()
	if self.finishcall then
		self.finishcall()
	end
	self.finishcall = nil

	if self.change_value and IsEquals(self.transform) then
		local go = GameObject.Instantiate(self.ChangeCell, self.transform)
    	go.gameObject:SetActive(true)
    	go.transform.localPosition = self.pos2
    	local cg = go.transform:GetComponent("CanvasGroup")
    	local pP = Vector3.New(self.pos2.x, self.pos2.y+150, 0)
    	local tt = go.transform:Find("Text"):GetComponent("Text")
    	local str = ""
		if self.change_value > 0 then
			str = "+"
		else
			str = "-"
		end
		tt.text = str .. StringHelper.ToCash(self.change_value)

		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToExit(seq)
		seq:Append(go.transform:DOLocalMove(pP, 1):SetEase(Enum.Ease.OutCubic))
		seq:Append(cg:DOFade(0.2, 0.5):SetEase(Enum.Ease.OutCubic))
		seq:OnKill(function ()
			DOTweenManager.RemoveExitTween(tweenKey)
			if IsEquals(go) then
				GameObject.Destroy(go.gameObject)
			end
			self:MyClose()
		end)
	else
		self:MyClose()
	end
end

function M:MyClose()
	GameObject.Destroy(self.gameObject)
end

function M.FlyingToTarget(node, targetPoint, targetScale, interval,direction, callback, forcecallback, delay,hight)
	if not IsEquals(node) then
		if callback then callback() end
		return
	end

	local seq = DoTweenSequence.Create()
	delay = delay or 0
	if delay > 0 then		
		seq:AppendInterval(delay)
	end
    direction = direction or math.random(0,1)
    hight = hight or 300
	seq:Append(node.transform:DOMoveBezier(targetPoint, hight, interval,direction))

	targetScale = targetScale or 1
	if targetScale ~= 1 then
		seq:Join(node.transform:DOScale(targetScale, interval))
	end

	seq:OnKill(function ()
		if callback then callback() end
	end)
	seq:OnForceKill(function ()
		if forcecallback then
			forcecallback()
		end
	end)
end