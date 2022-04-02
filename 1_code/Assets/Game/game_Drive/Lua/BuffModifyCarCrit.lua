local basefunc = require "Game/Common/basefunc"

BuffModifyCarCrit = basefunc.class(BuffBase)

local M = BuffModifyCarCrit
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffModifyCarCrit.super.ctor(self,buff_data)
end