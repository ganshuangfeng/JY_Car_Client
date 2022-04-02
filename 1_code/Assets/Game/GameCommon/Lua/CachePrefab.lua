-- 创建时间:2019-01-10

local basefunc = require "Game.Common.basefunc"

CachePrefab = basefunc.class()
local C = CachePrefab

function C.Create(prefabname, parent)
	return C.New(prefabname, parent)
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeListener()
    self.listener = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:ctor(prefabname, parent)
	self.prefabObj = GameObject.Instantiate(GetPrefab(prefabname), parent)
    self.gameObject = self.prefabObj
end

function C:MyExit()
    destroy(self.gameObject)
    clear_table(self)
end

function C:GetObj()
	return self.prefabObj
end

function C:SetObjName(name)
    if IsEquals(self.prefabObj) then
        self.prefabObj.name = name
    end
end
function C:SetParent(parent)
	if IsEquals(parent) and IsEquals(self.prefabObj) then
		self.prefabObj.transform:SetParent(parent)
	end
end
