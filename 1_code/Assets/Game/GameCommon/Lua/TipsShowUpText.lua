
local basefunc = require "Game.Common.basefunc"

TipsShowUpText = basefunc.class()
local M = TipsShowUpText
M.name = "TipsShowUpText"

function M.Create(text, pos, params)
    local p = {x = 0,y =150}
    if pos then p = pos end
    
    params = params or {}
    if not params.bg then
    	params.bg = "hint_bg_black"
    end

    return M.New(text, p, params)
end

function M:ctor(parm, pos, params)
    local x, y = pos.x, pos.y
    self.parm = parm

    local parent = AdaptLayerParent("Canvas/LayerLv5", params)
    if not IsEquals(parent) then return end
    self.parent = parent
    
    self.UIEntity = newObject(M.name, self.parent.transform)

    local tran = self.UIEntity.transform
    local layerOrder = params.layerOrder
    if layerOrder then
        local canvas = tran:GetComponent("Canvas")
        canvas.sortingOrder = layerOrder
    end

    self.UIEntity.transform.localPosition=Vector3.New(x,y,0)
    self:InitComTips(params)

    local seqMove = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToExit(seqMove)
    seqMove:Append(self.UIEntity.transform:DOLocalMoveY(y+100,0.4))
    seqMove:AppendInterval(params.showtime or 1.5)
    seqMove:Append(self.UIEntity.transform:GetComponent("CanvasGroup"):DOFade(0,0.4))
    seqMove:OnKill(function ()
        DOTweenManager.RemoveExitTween(tweenKey)
    	if IsEquals(tran) then
    		tran:SetParent(nil)
    	end
        destroy(self.UIEntity)
        clear_table(self)
    end)
end

function M:InitComTips(params)
    local tran = self.UIEntity.transform

    self.text = tran:Find("ComNode/info_txt"):GetComponent("TMP_Text")
    self.text.text = self.parm

    params = params or {}
    local bg = params.bg
    if bg then
    	local image = tran:Find("ComNode").transform:GetComponent("Image")
	    image.sprite = GetTexture(bg)
    end
end