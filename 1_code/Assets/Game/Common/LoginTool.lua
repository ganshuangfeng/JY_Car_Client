require "Game.game_Login.Lua.LoginToolPanel"

LoginTool = {}
local M = LoginTool

local listener
local function AddListener()
    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if listener then
        for msg,cbk in pairs(listener) do
            Event.RemoveListener(msg, cbk)
        end
    end
    listener=nil
end
local function MakeListener()
    listener = {}
    listener["LoginPanelCreateFinish"] = M.LoginPanelCreateFinish
    listener["ExitScene"] = M.ExitScene
end

function M.Init()
	MakeListener()
	AddListener()
end

function M.Exit()
	RemoveLister()
	M.ClearObject()
end

function M.LoginPanelCreateFinish()
	M.InitEnter()
end

function M.ExitScene()
	M.ClearObject()
end

function M.ClearObject()
	destroy(M.enter_gameObject)
	M.enter_gameObject = nil
	M.cheatPwd = ""
	LoginToolPanel.Close()
end

function M.CheatCtrlButtonClick()
	local tran = M.enter_gameObject.transform

	M.cheatCtrlCount = M.cheatCtrlCount + 1
	if M.cheatCtrlCount >= 6 then
		M.cheatCtrlCount = 0

		for i = 1, 6, 1 do
			local btn = tran.transform:Find("cbtn_" .. i)
			btn.gameObject:SetActive(true)
		end
	end

	for i = 1, 6, 1 do
		local img = tran.transform:Find("cbtn_" .. i):GetComponent("Image")
		img.color = Color.New(1, 1, 1, 0.5)
	end
	M.cheatPwd = ""
	-- tran = nil
end

function M.CheatButtonClick(key)
	M.cheatPwd = M.cheatPwd .. key
	--print("key:" .. key .. ", " .. M.cheatPwd)
	if M.cheatPwd == "264153" then
		M.cheatPwd = ""
		LoginToolPanel.Create()
	end
end

function M.InitEnter()
	local parent = GameObject.Find("Canvas").transform
	M.enter_gameObject = newObject("LoginToolEnter", parent)
	local tran = M.enter_gameObject.transform
	M.cheatPwd = ""
	for i = 1, 6, 1 do
		local btn = tran:Find("cbtn_" .. i):GetComponent("Button")
		btn.onClick:AddListener(function ()
			local img = tran:Find("cbtn_" .. i):GetComponent("Image")
			img.color = Color.red
			M.CheatButtonClick(tostring(i))
		end)
	end
	M.cheatCtrlCount = 0
	local cheatBtn = tran:Find("cheat_btn"):GetComponent("Button")
	cheatBtn.onClick:AddListener(function ()
		M.CheatCtrlButtonClick()
	end)
	-- tran = nil
end

M.Init()