local basefunc = require "Game.Common.basefunc"

LoginToolPanel = basefunc.class()
local M = LoginToolPanel
M.name = "LoginToolPanel"

local instance

function M.Create()
	instance = M.New()
	return instance
end

function M.Close()
	if instance then
		instance:ClearServerList()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function M:ctor()
	local parent = GameObject.Find("Canvas").transform
	local obj = newObject(M.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitRect()
end

function M:InitRect()
	local transform = self.transform

	self.ok_btn.onClick:AddListener(function()
		local ip_port = self.setting_txt.text
		local segs = basefunc.string.split(ip_port, ":")
		if segs ~= nil and #segs == 2 then
			AppConst.SocketAddress = ip_port
		end

		local version = self.inputVersionField.text
		gameMgr:SetForceVersion(version)

		local remoteConfigDir = self.inputRemoteConfigDirField.text
		gameMgr:SetForceConfig(remoteConfigDir)

		M.Close()
	end)

	self.clear_localconfig_btn.onClick:AddListener(function()
		local local_cfgs = {"localconfig"}
		for _, v in pairs(local_cfgs) do
			local dir = gameMgr:getLocalPath(v)
			if Directory.Exists(dir) then
				Directory.Delete(dir, true)
			end
		end
		PlayerPrefs.DeleteKey("_CLAUSE_IDENT_")

		local web_caches = {"_shop_"}
		for _, v in pairs(web_caches) do
			gameWeb:ClearCookies(v)
		end
		if Directory.Exists(AppDefine.LOCAL_DATA_PATH) then
			Directory.Delete(AppDefine.LOCAL_DATA_PATH, true)
		end
		PlayerPrefs.DeleteAll()

		self.inputRemoteConfigDirField.text = ""
	end)

	self.debug_btn.onClick:AddListener(function()
		PlayerPrefs.SetInt("_DEBUG_CORE_", 15)
	end)

	self.inputIPField = transform:Find("option/InputIPField"):GetComponent("InputField")
	self.inputIPField.onValueChanged:AddListener(function (val)
		self.setting_txt.text = val .. ":" .. self.inputPortField.text
	end)

	self.inputPortField = transform:Find("option/InputPortField"):GetComponent("InputField")
	self.inputPortField.onValueChanged:AddListener(function (val)
		self.setting_txt.text = self.inputIPField.text .. ":" .. val
	end)

	self.inputVersionField = transform:Find("version/InputVersionField"):GetComponent("InputField")
	self.inputVersionField.onValueChanged:AddListener(function (val)
		self.setting_version_txt.text = val
	end)
	local version_txt = transform:Find("version/InputVersionField/Placeholder"):GetComponent("Text")
	version_txt.text = PlayerPrefs.GetString("_Cheat_Force_Version_", "输入版本号")

	self.inputRemoteConfigDirField = transform:Find("version/InputRemoteConfigDirField"):GetComponent("InputField")
	self.inputRemoteConfigDirField.text = PlayerPrefs.GetString("_Cheat_Force_Config_", "")

	self.accountPwd = 0
	self.inputAccountField = transform:Find("user/InputAccountField"):GetComponent("InputField")
	self.inputAccountField.onValueChanged:AddListener(function (val)
		if LoginModel.loginData then
			LoginModel.loginData.youke = val
		end
	end)

	self.inputAccountField.gameObject:SetActive(false)
	self.account_btn.onClick:AddListener(function()
		self.accountPwd = self.accountPwd + 1
		if self.accountPwd >= 6 then
			self.accountPwd = 0
			self.inputAccountField.gameObject:SetActive(true)
		end
	end)

	local versionNode = transform:Find("version")
	if MainModel.IsLoged then
		local UserInfo = MainModel.UserInfo or {}
		local player_level = UserInfo.player_level or 0
		if player_level > 0 then
			versionNode.gameObject:SetActive(true)
		end
	else
		versionNode.gameObject:SetActive(false)
	end

	self.serverList = {}

	self:Refresh()
end

function M:Refresh()
	local IPTable = {
		"jygate.jyhd919.cn:5101",
		"47.107.102.33:5004",
		"jygame.jyhd919.cn:5002",
		"171.223.209.152:5101",
		"192.168.10.12:5002",
	}

	self.current_txt.text = AppConst.SocketAddress
	self.version_txt.text = gameMgr:GetVersionNumber() .. " : " .. gameMgr:getConfigVersion()
	self.url_txt.text = gameMgr:GetRootURL()

	self:ClearServerList()
	for k, v in pairs(IPTable) do
		self.serverList[#self.serverList + 1] = self:CreateItem(v)
	end

	local loginData = LoginModel.loginData or {}
	self.inputAccountField.text = loginData.wechat or ""	--(loginData.youke or "") .. "+#+" .. (loginData.wechat or "")
end

function M:ClearServerList()
	for i,v in pairs(self.serverList) do
		GameObject.Destroy(v.gameObject)
	end
	self.serverList = {}
end

function M:CreateItem(item)
	local obj = GameObject.Instantiate(self.server_item_tmpl)
	obj.transform:SetParent(self.list_node)
	obj.transform.localScale = Vector3.one

	local obj_t = {}
	LuaHelper.GeneratingVar(obj.transform, obj_t)
	obj_t.ip_btn.onClick:AddListener(function()
		self.setting_txt.text = item
		self.inputIPField.text = ""
		self.inputPortField.text = ""
	end)
	obj_t.ip_txt.text = item

	obj.gameObject:SetActive(true)

	return obj
end