--[[
Auth:Chiuan
like Unity Brocast Event System in lua.
]]

local EventLib = require "Game.Common.3rd.eventlib.eventlib"

Event = {}
local events = {}
local events_flag={}
----------------------- add by ryx
--is_gameobject : 如果这个event中的参数与gameObject相关,则需要在切换场景时自动清理掉
function Event.AddListener(event,handler,is_gameobject)
	if not event or type(event) ~= "string" then
		error("event parameter in addlistener function has to be string, " .. type(event) .. " not right.")
	end
	if not handler or type(handler) ~= "function" then
		error("handler parameter in addlistener function has to be function, " .. type(handler) .. " not right")
	end

	if not events[event] then
		--create the Event with name
		events[event] = EventLib:new(event)
	end

	events_flag[event]=events_flag[event] or {}
	if events_flag[event][handler] then
		print("error AddListener  repeat !!!   event : "..event)
		print(debug.traceback())
		return 
	else
		events_flag[event][handler]={
			is_gameobject = is_gameobject
		}
	end
	--conn this handler
	events[event]:connect(handler)
end

function Event.Brocast(event,...)
	if not events[event] then
		-- logWarn("brocast " .. event .. " has no event.")
	else
		-- print("event>>>>>>>","/",event,"/",...,"/")
		events[event]:fire(...)
	end
end

function Event.RemoveListener(event,handler)
	if not events[event] then
		-- error("remove " .. event .. " has no event.")
	else
		events[event]:disconnect(handler)
		if event and events_flag[event] and handler then
			events_flag[event][handler]=nil
		end
	end
end

----------------------- add by ryx
--在切换场景时调用,移除所有与gameObject相关的Listener
function Event.RemoveAllGameObjectEvent()
	for event,v in pairs(events_flag) do
		for handler,flag in pairs(v) do
			if flag.is_gameobject then
				Event.RemoveListener(event,handler)
			end
		end
	end
end

function Event.IsExist(event)
	if events[event] then
		return true;
	else
		return false;
	end
end

return Event