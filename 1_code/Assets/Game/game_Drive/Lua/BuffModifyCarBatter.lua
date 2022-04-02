local basefunc = require "Game/Common/basefunc"

BuffModifyCarBatter = basefunc.class(BuffBase)

local M = BuffModifyCarBatter
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffModifyCarBatter.super.ctor(self,buff_data)
end