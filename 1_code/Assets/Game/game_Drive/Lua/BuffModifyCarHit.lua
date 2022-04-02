local basefunc = require "Game/Common/basefunc"

BuffModifyCarHit = basefunc.class(BuffBase)

local M = BuffModifyCarHit
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffModifyCarHit.super.ctor(self,buff_data)
end