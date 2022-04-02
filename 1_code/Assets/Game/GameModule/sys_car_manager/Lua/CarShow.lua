-- 创建时间:2021-06-01
-- Panel:CarShow
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- AudioManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- AudioManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

CarShow = basefunc.class()
local C = CarShow
C.name = "CarShow"

--parm
--{
--1.车辆ID   car_id
--2.车辆星级  car_star
--3.父节点   parent
--}

function C.Create(parm)
	return C.New(parm)
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
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

function C:MyExit()
	self:RemoveListener()
    destroy(self.car)
	destroy(self.gameObject)
    clear_table(self)
end

function C:ctor(parm)
    parm = parm or {}
	local parent = parm.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    self.star = parm.car_star + 1
    self.id = parm.car_id
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	self.CameraMove = self.transform:Find("Camera"):GetComponent("CameraMove")
	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function C:InitUI()
    local config = SysCarManager.GetCarCfg({car_type_id = self.id})

    local car_prefab_name = config.car_name.."_"..(self.star or 1)
    self.car = newObject(car_prefab_name,self.car_node)
    self.car.transform.localPosition = Vector3.zero
    local name2pos = {
        car_1 = {pos = Vector3.New(-0.042,0.066,0.008),rot = Quaternion.Euler(0,0,-15.178)},
        car_2 = {pos = Vector3.New(-0.074,-0.166,0.048),rot = Quaternion.Euler(0,0,72.914)},
        car_3 = {pos = Vector3.New(0.01545,0.163,0.002),rot = Quaternion.Euler(0,0,-4.275),scale = Vector3.New(0.85,0.85,0.85)},
        car_4 = {pos = Vector3.New(0.01545,0.163,0.002),rot = Quaternion.Euler(0,0,-4.275),scale = Vector3.New(0.85,0.85,0.85)},
    }
    self.car.transform.localPosition = name2pos[config.car_name].pos
    self.car.transform.localRotation = name2pos[config.car_name].rot
    if name2pos[config.car_name].scale then
        self.car.transform.localScale = name2pos[config.car_name].scale
    end
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:Set(parm)
    self.CameraMove.targetTf = parm.targetTf and parm.targetTf or self.CameraMove.targetTf
    self.CameraMove.rotateSpeed = parm.rotateSpeed and parm.rotateSpeed or self.CameraMove.rotateSpeed
    self.CameraMove.yMaxLimit = parm.yMaxAngle and parm.yMaxAngle or self.CameraMove.yMaxLimit
    self.CameraMove.yMinLimit = parm.yMinAngle and parm.yMinAngle or self.CameraMove.yMinLimit
    self.CameraMove.zoomSpeed = parm.zoomSpeed and parm.zoomSpeed or self.CameraMove.zoomSpeed
    self.CameraMove.minDistance = parm.minDistance and parm.minDistance or self.CameraMove.minDistance
    self.CameraMove.maxDistance = parm.maxDistance and parm.maxDistance or self.CameraMove.maxDistance
    self.CameraMove.isCamp = parm.isCamp and parm.isCamp or self.CameraMove.isCamp
end

function C:PlayCarShowFx()
    self.car_show_fx.gameObject:SetActive(false)
    self.car_show_fx.gameObject:SetActive(true)
end
