-- 创建时间:2018-08-29

local basefunc = require "Game.Common.basefunc"

LodingSmallPanel = basefunc.class()

LodingSmallPanel.name = "LodingSmallPanel"

local Rate
local RateNode
local RateWidth = 1000
local Title
local bufferStateType = LodingModel.BufferStateType.BST_Null
local loadResType = LodingModel.LoadResType.LRT_Null
local totallLoadCount = 0
local currLoadCount = 0
local assetShare = 80
local sceneShare = 20

local instance
function LodingSmallPanel.Create(data)
    instance = LodingSmallPanel.New(data)
    return instance
end

function LodingSmallPanel.Close()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function LodingSmallPanel:ctor(data)
    local parent = GameObject.Find("Canvas/LayerLv5")
    parent = parent or GameObject.Find("Canvas")
    if not IsEquals(parent) then return end
    parent = parent.transform
    local obj = newObject(LodingSmallPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj

    --Rate = self.transform:Find("Rate"):GetComponent("Image")
    Title = self.transform:Find("Title"):GetComponent("TMP_Text")
    bufferStateType = LodingModel.BufferStateType.BST_Begin
    loadResType = LodingModel.LoadResType.LRT_Asset
    Title.text = "资源加载中..."
    --Rate.fillAmount = 0
    totallLoadCount = data.totallLoadCount
    currLoadCount = 0

    --RateNode = tran:Find("Rate/RateNode")
    --RateNode.localPosition = Vector3.New(-RateWidth / 2, 0, 0)
end

function LodingSmallPanel:MyExit()
    --Rate = nil
    Title = nil
    destroy(self.gameObject)
    clear_table(self)
end

function LodingSmallPanel:LoadingUpdate(data)
    currLoadCount = data.curr_load_count
    local nn = (assetShare * (currLoadCount / totallLoadCount)) / (assetShare + sceneShare)
    local str = "资源加载中..." 
    Title.text = str
    --Rate.fillAmount = nn
    --RateNode.localPosition = Vector3.New(-RateWidth / 2 + RateWidth * nn, 0, 0)

    self:LoadingFinish()
end


function LodingSmallPanel:LoadingFinish()
    if currLoadCount < totallLoadCount then return end
    Title.text = "资源加载完成..."
    --Rate.fillAmount = 1
    --RateNode.localPosition = Vector3.New(RateWidth / 2, 0, 0)
end