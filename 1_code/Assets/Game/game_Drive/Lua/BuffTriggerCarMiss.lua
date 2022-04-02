local basefunc = require "Game/Common/basefunc"

BuffTriggerCarMiss = basefunc.class(BuffBase)

local M = BuffTriggerCarMiss
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffTriggerCarMiss.super.ctor(self,buff_data)
end