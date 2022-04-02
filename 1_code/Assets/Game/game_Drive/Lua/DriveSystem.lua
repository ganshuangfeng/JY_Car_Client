-- 游戏车辆类
local basefunc = require "Game/Common/basefunc"
DriveSystem = basefunc.class()

local M = DriveSystem
M.name = "DriveSystem"

function M.Create(system_data)
    return M.New(system_data)
end

function M:MyExit()
    self:RemoveListener()
    clear_table(self)
end

function M:ctor(system_data)
    self.system_data = system_data
    dump(self.system_data,"<color=yellow>Drive系统的数据</color>")
    self:MakeListener()
	self:AddListener()
    self:InitUI()
    self:Refresh()
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

function M:InitUI()
    
end

function M:Refresh(system_data)
    if system_data and self.system_data ~= system_data then
        --不是同一辆车了，重新创建
        self:MyExit()
        self:ctor(system_data)
        return
    end
    self.system_data = system_data or self.system_data
end

function M:RefreshData(data)
    self.system_data = data
end