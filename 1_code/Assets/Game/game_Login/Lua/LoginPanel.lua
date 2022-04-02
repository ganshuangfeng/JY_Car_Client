local basefunc = require "Game/Common/basefunc"
LoginPanel= basefunc.class()
local M = LoginPanel
M.name = "LoginPanel"



local instance
function M.Create()
	instance = M.New()
	return instance
end

function M.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function M.Exit()
	if instance then
		instance:RemoveListener()
		clear_table(instance)
		instance = nil
	end
end

function M:ctor()
	self:MakeListener()
	self:AddListener()
	local parent = GameObject.Find("GUIRoot").transform
	self.gameObject = newObject(M.name, parent)
	self.transform = self.gameObject.transform
	basefunc.GeneratingVar(self.transform, self)

	self.login_youke_btn.onClick:AddListener(function ()
		self:OnLoginYK()
	end)

	self.logout_youke_btn.onClick:AddListener(function ()
		self:OnLogOutYK()
	end)

	self.repair_btn.onClick:AddListener(function ()
		self:OnRepair()
	end)


	HandleLoadChannelLua(M.name, self)

	self.privacy = true
	self.service = true
	local ClauseHintNode = self.transform:Find("ClauseHintNode")
	if ClauseHintNode then
		ClauseHintPanel.Create(ClauseHintNode)
	end

	self:SetVersion()
	Event.Brocast("LoginPanelCreateFinish")

	if gameRuntimePlatform == "IOS" or gameRuntimePlatform == "Android" then
        self.logout_youke_btn.gameObject:SetActive(false)
    end
end

function M:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end

function M:AddListener()
	for proto_name,func in pairs(self.listener) do
		Event.AddListener(proto_name, func)
	end
end

function M:MakeListener()
	self.listener = {}
	self.listener["upd_privacy_setting"] = basefunc.handler(self, self.upd_privacy_setting)
	self.listener["upd_service_setting"] = basefunc.handler(self, self.upd_service_setting)
	self.listener["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function M:upd_privacy_setting(value)
	self.privacy = value
end

function M:upd_service_setting(value)
	self.service = value
end

function M:OnExitScene()
	self:MyExit()
end

function M:RemoveListener()
	for proto_name,func in pairs(self.listener) do
		Event.RemoveListener(proto_name, func)
	end
	self.listener = {}
end

function M:SetVersion()
	--version
	local vf = resMgr.DataPath .. "udf.txt"
	if File.Exists(vf) then
		local luaTbl = json2lua(File.ReadAllText(vf))
		if luaTbl then
			local versionTxt = self.transform:Find("Version_txt"):GetComponent("Text")
			versionTxt.text = "Ver:" .. luaTbl.version .. " " .. gameMgr:getMarketChannel()
		end
	end
end

function M:CheatButtonClick(key)
	self.cheatPwd = self.cheatPwd .. key
	--print("key:" .. key .. ", " .. self.cheatPwd)
	if self.cheatPwd == "264153" then
		self.cheatPwd = ""
		LoginLogic.checkServerStatus = false
		package.loaded["Game.game_Login.Lua.CheatPanel"] = nil
		require "Game.game_Login.Lua.CheatPanel"
		CheatPanel.Create()
	end
end

--游客登录
function M:OnLoginYK()
	print("<color=white>游客登录</color>")
	Event.Brocast("dbss_send_power",{key = "click_login_youke"})
	if self.privacy == true and self.service == true then
		LoginHelper.Login(LoginHelper.ChannelType.youke)
	else
		TipsShowUpText.Create("勾选同意下方协议才能进入游戏")
	end
end

function M:OnLogOutYK()
	LoginHelper.ClearLogin(LoginHelper.ChannelType.youke)
end

function M:OnRepair()
	if Directory.Exists(resMgr.DataPath) then
		Directory.Delete(resMgr.DataPath, true)
	end
	local web_caches = {"_shop_"}
	for _, v in pairs(web_caches) do
		gameWeb:ClearCookies(v)
	end
	HintPanel.Create({show_yes_btn = true,msg =  "修复完毕，请重新运行游戏",yes_call_back = function ()
		gameMgr:QuitAll()
	end})
	Event.Brocast("dbss_send_power",{key = "click_repair"})
end