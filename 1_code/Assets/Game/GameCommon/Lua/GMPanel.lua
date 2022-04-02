local basefunc = require "Game.Common.basefunc"

GMPanel = basefunc.class()
GMPanel.name = "GMPanel"

local instance

function GMPanel.Create()
	GMPanel.Close()
	if not instance or not IsEquals(instance.gameObject) then
		instance = GMPanel.New()
	end
	return instance
end

function GMPanel.Close()
	if instance then
		instance:ClearCMDList()
		instance:RemoveListener()
		GameObject.Destroy(instance.gameObject)
		instance = nil
	end
end

function GMPanel:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func)
    end
end

function GMPanel:MakeListener()
	self.listener = {}
	self.listener["gm_command_response"] = basefunc.handler(self, self.gm_command_response)
end

function GMPanel:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
end

function GMPanel:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(GMPanel.name, parent)
	self.transform = obj.transform
	self.gameObject = self.transform.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeListener()
	self:AddListener()
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)

	self:CreateItem(MainModel.UserInfo.user_id)

    local a,b = GameModuleManager.RunFun({_goto="sys_permission"}, "debug_test")
    if a and b then
		self:CreateItem(b)
	end
	
end

function GMPanel:InitRect()
	local transform = self.transform

	self.scrollRect = transform:Find("Scroll View"):GetComponent("ScrollRect")

	self.inputCMDField = transform:Find("InputCMDField"):GetComponent("InputField")
	self.inputCMDField.onValueChanged:AddListener(function (val)
		
	end)
	self.inputCMDField.onEndEdit:AddListener(function ()
		if UnityEngine.Input.GetKeyDown(Enum.KeyCode.Return) or UnityEngine.Input.GetKeyDown(Enum.KeyCode.KeypadEnter) then
			self:DoCommand()
		end
	end)

	self.close_btn.onClick:AddListener(function()
		GMPanel.Close()
	end)

	self.send_btn.onClick:AddListener(function()
		self:DoCommand()
	end)

	self.cmdList = {}
end

function GMPanel:DoCommand()
	local cmd = self.inputCMDField.text
	if cmd == "" then
		return
	end

	self:Refresh(cmd)
	print("[Debug] send gm command: " .. cmd)

	if string.sub(cmd, 1, 1) == "@" then
		local ss = string.sub(cmd, 2, -1)
		print("<color=red><size=20>===========================</size></color>")
		xpcall(function ()
			loadstring(ss)()
		end, function (error)
			dump(error, "<color=red>error</color>")
		end)
	else
		Network.SendRequest("gm_command",{command=cmd})
	end

	self.inputCMDField.text = "";
	self.inputCMDField:ActivateInputField();
end

function GMPanel:Refresh(item)
	local cnt = #self.cmdList
	self.cmdList[cnt + 1] = self:CreateItem(item)

	UnityEngine.Canvas.ForceUpdateCanvases()
	self.scrollRect.verticalNormalizedPosition = 0
end

function GMPanel:ClearCMDList()
	for i,v in pairs(self.cmdList) do
		GameObject.Destroy(v.gameObject)
	end
	self.cmdList = {}
end

function GMPanel:CreateItem(item)
	if not IsEquals(self.cmd_item_tmpl) then return end
	local obj = GameObject.Instantiate(self.cmd_item_tmpl)
	obj.transform:SetParent(self.list_node)
	obj.transform.localScale = Vector3.one
	local cmd_text = obj.transform:GetComponent("Text")
	cmd_text.text = item or ""
	obj.gameObject:SetActive(true)

	-- EventTriggerListener.Get(obj.gameObject).onClick = basefunc.handler(self, self.OnCopyClick)

	return obj
end
function GMPanel:OnCopyClick(obj)
	local tt = obj.transform:GetComponent("Text")
	self.inputCMDField.text = tt.text;
end

--启动事件--
function GMPanel:Awake()
end

function GMPanel:Start()	
end

function GMPanel:OnDestroy()
	GMPanel.Close()
end

function GMPanel:gm_command_response(_, result)
	self:Refresh(result.result)
end
