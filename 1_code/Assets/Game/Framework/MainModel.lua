local basefunc = require "Game.Common.basefunc"
MainModel = {}
local this
local UpdateTimer
local UPDATE_INTERVAL = 0.5
local UserInfo

local listener
local function AddListener()
    listener = {}    
    for msg, cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg, cbk in pairs(listener) do
        Event.RemoveListener(msg, cbk)
    end
    listener = nil
end

function MainModel.Init()
    this = MainModel
    AddListener()

    UpdateTimer = Timer.New(this.Update, UPDATE_INTERVAL, -1, nil, true)
    UpdateTimer:Start()

    return this
end

function MainModel.Update()
    --登录后之后才会有这些操作
end

function MainModel.Exit()
    if this then
        UpdateTimer:Stop()
        RemoveLister()
        this.UserInfo = nil
        this = nil
    end
end

function MainModel.InitPlayerData(data)
    if data.result ~= 0 then
        this.UserInfo = {}
        return
    end

    this.UserInfo = data
    this.UserInfo.shop_gold_sum = 0
    this.UserInfo.jing_bi = 0
    this.UserInfo.player_asset = nil
    this.UserInfo.GiftShopStatus = {}

    if not this.UserInfo.name then
        this.UserInfo.name = ""
    end
end

