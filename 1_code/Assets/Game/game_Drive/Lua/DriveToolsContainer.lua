local basefunc = require "Game/Common/basefunc"

DriveToolsContainer = basefunc.class()
local M = DriveToolsContainer
M.name = "DriveToolsContainer"
local instance
function M.Create(parent)
	if instance then
		instance:MyExit()
	end
	instance = M.New(parent)
	if not instance.gameObject or not IsEquals(instance.gameObject) then
		--初始化未成功
		instance = nil
	end
	return instance
end
 
function M.Close()
	if instance then
		instance:MyExit()
	end
	clear_table(instance)
	instance = nil
end
 
function M.Refresh()
	if instance then
		instance:MyRefresh()
		return instance
	end
	return M.Create()
end
 
function M:AddListener()
	for proto_name,func in pairs(self.listener) do
		Event.AddListener(proto_name, func, true)
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
 
function M:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end
 
function M:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot/DrivePanel/@down_node")
	if not parent then return end
	parent = parent.transform
	self.gameObject = newObject(M.name, parent)
	self.transform = self.gameObject.transform
	basefunc.GeneratingVar(self.transform, self)
 
	self:MakeListener()
	self:AddListener()

	self:InitUI()
	self:MyRefresh()
end

function M:SetStyle()
	for i=1,4 do
		self["bg_" .. i .."_img"].sprite = GetTexture(DriveMapManager.GetMapAssets("zd_bg_jnd"))
	end
end

function M:InitUI()
	self:SetStyle()
	self:MyRefresh()
end

function M:MyRefresh()
	local tools_map = ToolsManager.GetAllTools()
	for owner_type,v in pairs(tools_map or {}) do
        for owner_id,v1 in pairs(v) do
            for tools_id,tools in pairs(v1) do
                tools:RefreshView()
            end
        end
    end
end