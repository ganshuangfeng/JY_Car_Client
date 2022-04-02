local basefunc = require "Game.Common.basefunc"

NetwordWaitScene = basefunc.class()

local jhTags={}

-- 是否同时只有一个菊花
local is_one_jh = true

local listener
local function AddListener()
	listener={}
	listener["SendRequestSucceed"] = NetwordWaitScene.OnSendRequestSucceed
	listener["SendRequestResponesSucceed"] = NetwordWaitScene.OnSendRequestResponesSucceed
	listener["network_sendrequest_exception"] = NetwordWaitScene.OnNetworkSendrequestException
	listener["ServerConnecteSucceed"] = NetwordWaitScene.OnServerConnecteSucceed

    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(listener) do
        Event.RemoveListener(msg, cbk)
    end
    listener=nil
end

--检测菊花是否有效 里面会清理无效的菊花
local function chkJhIsValid(jh)
    if jh and jh.UIEntity and not jh.UIEntity:Equals(nil) then
    	return true
    end

    if jh and jh.tag then
    	jhTags[jh.tag] = nil
    end

    return false
end

--[[创建一个全屏菊花，返回一个实例，需要手动删除
	可以使用tag标记，同一个tag的菊花不会多次创建
	删除的时候可以使用tag进行删除
]]
function NetwordWaitScene.Create(msg,tag, parent)
	if tag then
	    local jh = jhTags[tag]
	    if chkJhIsValid(jh) then
	    	return jh
	    end
	end
    return NetwordWaitScene.New(msg, tag, parent)
end

function NetwordWaitScene.RemoveByTag(tag)
    local jh = jhTags[tag]
    if chkJhIsValid(jh) then
    	jh:Remove()
    end
end


--移除所有菊花
function NetwordWaitScene.RemoveAll()
    
    for tag,jh in pairs(jhTags) do
    	if chkJhIsValid(jh) then
	    	jh:Remove()
	    end
    end

end

function NetwordWaitScene.OnSendRequestSucceed(parm)
	if not parm or not parm.name or parm.name == "heartbeat" or parm.name == "client_breakdown_info" then return end
	NetwordWaitScene.Create(parm.name,parm.name)
end

function NetwordWaitScene.OnSendRequestResponesSucceed(parm)
	if not parm or not parm.name or parm.name == "heartbeat" or parm.name == "client_breakdown_info" then return end
	NetwordWaitScene.RemoveByTag(parm.name)
end

function NetwordWaitScene.OnNetworkSendrequestException(parm)
	if not parm or not parm.name or parm.name == "heartbeat" or parm.name == "client_breakdown_info" then return end
	NetwordWaitScene.Create(parm.name,parm.name)
end

function NetwordWaitScene.OnServerConnecteSucceed()
	NetwordWaitScene.RemoveAll()
end

function NetwordWaitScene:ctor(msg,tag, parent)
	self.tag = tag
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv50")
		if not parent then
			parent = GameObject.Find("Canvas/LayerLv5")
		end
	end

	self.UIEntity = newObject("NetwordWaitScene", parent.transform)
	local descText = self.UIEntity.transform:Find("MBBG/Text"):GetComponent("Text")
	self.jhImage = self.UIEntity.transform:Find("MBBG").gameObject
	descText.text = msg

	if self.tag then
		jhTags[self.tag] = self
	end
	self.jhImage:SetActive(false)
    self.updateTimer = Timer.New(function ()
    	if self.jhImage and not self.jhImage:Equals(nil) then
			self.jhImage:SetActive(true)
	    end
    end, 1)
    self.updateTimer:Start()
end


--移除
function NetwordWaitScene:Remove()
	self.updateTimer:Stop()
	GameObject.Destroy(self.UIEntity)
	if self.tag then
		jhTags[self.tag] = nil
	end 
end

AddListener()

--[[

-- GameObject
local fullJHPrefab
local descText

--菊花状态 nil-无  0-隐藏中  1-显示中
local jhStatus

-- 显示全屏JH
-- showType
local ShowJH = function ( showType, desc)

	if not jhStatus then
		local parent = GameObject.Find("Canvas/LayerLv4")
		fullJHPrefab = newObject("NetwordWaitScene", parent.transform)
		fullJHPrefab.transform:SetParent(parent.transform)
		descText = fullJHPrefab.transform:Find("Text"):GetComponent("Text")
		descText.text = desc
		fullJHPrefab:SetActive(true)
		jhStatus = 1
	elseif jhStatus == 0 then
		local parent = GameObject.Find("Canvas/LayerLv4")
		fullJHPrefab.transform:SetParent(parent.transform)
		descText.text = desc
		fullJHPrefab:SetActive(true)
		jhStatus = 1
	elseif jhStatus == 1 then
		return
	end

end

-- 隐藏全屏JH
local HideJH  = function ( )

	if jhStatus == 1 then

		fullJHPrefab:SetActive(false)
		local parent = GameObject.Find("GameManager").transform
		fullJHPrefab.transform:SetParent(parent)
		jhStatus = 0

	end

end

NetwordWaitScene.ShowJH = ShowJH
NetwordWaitScene.HideJH = HideJH

]]