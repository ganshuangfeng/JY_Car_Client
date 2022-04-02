-- 创建时间:2018-05-30

local basefunc = require "Game.Common.basefunc"
GuideView = basefunc.class()
local M = GuideView
M.name = "GuideView"
local instance
function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeListener()
    self.listener = {}
end

function M:RemoveListener()
	if not self.listener or not next(self.listener) then return end
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = nil
end

function M.Create(parm)
	if instance then
		instance:Exit()
	end
	instance = nil
	instance = M.New(parm)
	return instance
end

function M.Close()
	if instance then
		instance:Exit()
	end
	instance = nil
end

function M:ctor(parm)
	dump(parm,"<color=yellow>新手引导界面ctor</color>")
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.cfg = GuideModel.GetCurSetpCfg()
	self.transform = tran
	self.gameObject = obj
	basefunc.GeneratingVar(self.transform, self)
	self:MakeListener()
	self:AddListener()
	self:InitUI()
	-- self.update_timer = Timer.New(function ()
	-- 	-- M.CheckClickScreen()
	-- end,0.02,-1)
	-- self.update_timer:Start()
	self:MyRefresh()
end

function M:Exit()
	if self.update_timer then
		self.update_timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
	instance = nil
end

function M:MyExit()
	self:Exit()
end

function M:InitUI()
	--初始化UI设置
	if self.cfg.ok_func then
		self.ok_btn.onClick:AddListener(function()
			if GuideFunction[self.cfg.ok_func] then
				GuideFunction[self.cfg.ok_func]()
			else
				dump(self.cfg,"<color=red>新手引导配置错误</color>")
			end
		end)
	end

	if self.cfg.target then
		local target = GameObject.Find(self.cfg.target)
		if IsEquals(target) then
			if not self.cfg.mask_type or self.cfg.mask_type == 0 then
				--方形
				self.guidance_controller = self.bg_img.gameObject:GetComponent("RectGuidanceController")
				self.bg_img.material = GetMaterial("RectGuidance")
			else
				--圆形
				self.guidance_controller = self.bg_img.gameObject:GetComponent("CircleGuidanceController")
				self.bg_img.material = GetMaterial("CircleGuidance")
			end
			self.guidance_controller:SetTarget(target.transform,true)
		else
			dump(self.cfg,"<color=red>新手引导配置错误</color>")
		end
	end	
end

function M:MyRefresh()
	dump(self.cfg,"<color=white>新手引导刷新</color>")
	if self.cfg.qp_des then
		self.qp_txt.text = self.cfg.qp_des
	end
	if self.cfg.qp_pos then
		self.qp_node.transform.localPosition = self.cfg.qp_pos
		self.qp_node.gameObject:SetActive(true)
	end
	if self.cfg.rw_pos then
		self.rw_node.transform.localPosition = self.cfg.rw_pos
		self.rw_node.gameObject:SetActive(true)
	end
	if self.cfg.sz_pos then
		self.sz_node.transform.localPosition = self.cfg.sz_pos
		self.sz_node.gameObject:SetActive(true)
	end
	if self.cfg.sz_des then
		self.sz_txt.text = self.cfg.sz_des
	end
end

function M.Update()
	
end

function M.CheckClickScreen()
	local is_pointer_over
	local click_position
	if gameRuntimePlatform == "WindowsEditor" or gameRuntimePlatform == "" then
		if UnityEngine.Input.GetMouseButtonDown(0) then
			if IsEquals(EventSystem.current) then
				is_pointer_over = EventSystem.current:IsPointerOverGameObject()
				click_position = UnityEngine.Input.mousePosition
				Event.Brocast("guide_click_screen",{click_position = click_position,is_pointer_over = is_pointer_over})
			end
		end
	else
		if UnityEngine.Input.touchCount > 0 then
			local first_touch = UnityEngine.Input.GetTouch(0)
			if first_touch.phase == UnityEngine.TouchPhase.Began then
				if IsEquals(EventSystem.current) then
					is_pointer_over = EventSystem.current:IsPointerOverGameObject(first_touch.fingerId)
					click_position = first_touch.position
					Event.Brocast("guide_click_screen",{click_position = click_position,is_pointer_over = is_pointer_over})
				end
			end
		end
	end
end