local basefunc = require "Game/Common/basefunc"

DriveSkillBuffContainer = basefunc.class()
local M = DriveSkillBuffContainer
M.name = "DriveSkillBuffContainer"
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
	
end

function M:InitUI()
	self:SetStyle()
	self:MyRefresh()
end

function M:MyRefresh()
	local skill_map = SkillManager.GetAllSkill()
	for owner_type,v in pairs(skill_map or {}) do
        for owner_id,v1 in pairs(v) do
            for skill_id,skill in pairs(v1) do
                skill:RefreshView()
            end
        end
    end

	local buff_map = BuffManager.GetAllBuff()
	for owner_type,v in pairs(buff_map or {}) do
        for owner_id,v1 in pairs(v) do
            for buff_id,buff in pairs(v1) do
                buff:RefreshView()
            end
        end
    end
end