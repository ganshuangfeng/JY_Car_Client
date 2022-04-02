local basefunc = require "Game/Common/basefunc"

BuffTriggerCarCrit = basefunc.class(BuffBase)

local M = BuffTriggerCarCrit
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffTriggerCarCrit.super.ctor(self,buff_data)
end