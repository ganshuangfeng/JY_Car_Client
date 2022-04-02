local basefunc = require "Game/Common/basefunc"

BuffModifyCarAtRange = basefunc.class(BuffBase)

local M = BuffModifyCarAtRange
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffModifyCarAtRange.super.ctor(self,buff_data)
end

--刷新回调
function M:OnRefresh()
    dump({data = self.buff_data,cfg = self.buff_cfg},"buff_refresh")
    self:SetBuffModify(self.buff_data,self.buff_cfg)
end

--创建回调
function M:OnCreate()
    dump("buff_create")
    self:SetBuffModify(self.buff_data,self.buff_cfg)
    self:OnTrigger()
end

--移除回调
function M:OnDead()
    dump("buff_dead")
    local buff_cfg = basefunc.deepcopy(self.buff_cfg)
    buff_cfg.modify_value.arg_value = 0
    self:SetBuffModify(self.buff_data,buff_cfg)
    self:PlayObjs()
    self:OnActEnd()
end