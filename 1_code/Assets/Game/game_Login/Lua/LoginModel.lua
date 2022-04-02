
LoginModel={}
local this
local listener
local function AddListener()
    listener={}
    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(listener) do
        Event.RemoveListener(msg, cbk)
    end
    listener=nil
end

function LoginModel.Init()
    this = LoginModel
    AddListener()
    return this
end

function LoginModel.Exit()
    if this then
        RemoveLister()
        this = nil
    end
end
