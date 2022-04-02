local basefunc = require "Game/Common/basefunc"

BuffModifyCarMiss = basefunc.class(BuffBase)

local M = BuffModifyCarMiss
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffModifyCarMiss.super.ctor(self,buff_data)
end