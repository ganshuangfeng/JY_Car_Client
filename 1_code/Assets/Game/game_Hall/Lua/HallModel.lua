HallModel={}
local this
local m_data
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

-- 初始化Data
local function InitData()
    m_data = {}
end

function HallModel.Init()
    this = HallModel
    AddListener()
    InitData()
    return this
end

function HallModel.Exit()
	if this then
	    RemoveLister()
        m_data=nil
	    this = nil
    end
end