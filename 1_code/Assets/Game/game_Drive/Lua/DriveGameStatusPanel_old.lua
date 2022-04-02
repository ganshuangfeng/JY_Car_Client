-- 创建时间:2021-03-03
-- Panel:DriveGameInfoPanel
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
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

DriveGameStatusPanel = basefunc.class()
local C = DriveGameStatusPanel
C.name = "DriveGameStatusPanel"

local instance
function C.Create(parent)
	if instance then
		instance:MyExit()
	end
	instance = C.New(parent)
	return instance
end

function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C.Refresh()
	if instance then
		instance:MyRefresh()
		return
	end
	C.Create()
end

function C.GetInstance()
	return instance
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
    self.listener = {}
	self.listener["road_award_on_pass_by"] = basefunc.handler(self,self.on_road_award_on_pass_by)
	self.listener["car_move_end"] = basefunc.handler(self,self.on_car_move_end)
	self.listener["road_award_on_trigger"] = basefunc.handler(self,self.on_road_award_on_trigger)
	self.listener["view_round_end"] = basefunc.handler(self,self.on_view_round_end)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
	if self.timer_countdown then
		self.timer_countdown:Stop()
		self.timer_countdown = nil
	end
	self:CloseWaitTimer()
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end

function C:ctor()
	local parent = parent or GameObject.Find("Canvas/GUIRoot/DrivePanel/@center_node/@game_status_parent").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	self.timer_countdown = Timer.New(function ()
		self:Countdowm()
	end,1,-1,nil,nil)

	self.timer_countdown:Start()
	
	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function C:SetStyle()
	self.bg_title_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_img_zj_mzd"))
	self.title_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_img_zj_bg02"))
	self.bg_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_img_zj_bg"))
	self.obj_parent_img = self.obj_parent.transform:GetComponent("Image")
	self.obj_parent_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_img_zj_bg01"))
	self.title_txt_out_line = self.title_txt.transform:GetComponent("Outline")
	self.title_txt_out_line.effectColor = DriveMapManager.GetMapColor("game_status_title_out_line")
	self.enemy_me_txt_out_line = self.enemy_me_txt.transform:GetComponent("Outline")
end

function C:InitUI()
	self:SetStyle()
	self:MyRefresh()
end

function C:MyRefresh()
	self:on_view_round_end()
end

function C:on_road_award_on_pass_by(data)
	--路过奖励时，在界面上显示奖励的位置
	self.timeout_txt.gameObject:SetActive(false)
	self.wait_txt.gameObject:SetActive(false)
	self:CloseWaitTimer()
	self.obj_parent.gameObject:SetActive(true)
	if self.road_award_obj then
		destroy(self.road_award_obj)
		self.road_award_obj = nil
	end
	self.road_award_obj = GameObject.Instantiate(data.obj)
	self.road_award_obj.transform:SetParent(self.obj_node)
	set_layer(self.road_award_obj,"UI")
	if string.match(self.road_award_obj.gameObject.name,"RoadAwardCenterAttack") then
		self.road_award_obj.transform.localPosition = Vector3.New(0,-30,0)
		set_sorting_layer(self.road_award_obj,"3DMiddle_middle")
	else
		self.road_award_obj.transform.localPosition = Vector3.zero
		set_sorting_layer(self.road_award_obj,"2DMiddle_middle")
	end
	self.road_award_obj.transform.localScale = Vector3.New(DriveModel.scale2Dto3D,DriveModel.scale2Dto3D,DriveModel.scale2Dto3D)
	

	local objs = self.road_award_obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.SpriteRenderer), true)
    for i = 0, objs.Length - 1 do
        objs[i].material = GetMaterial("2DUITransParent")
    end
	if data.skill_cfg or data.obj_name then
		self.title_txt.text = data.obj_name or data.skill_cfg.name
	end

	if data.car_data then
		-- local mat
		-- if data.car_data.move_speed > 1000 then
		-- 	mat = GetMaterial("FrontBlur")
		-- 	SetGameObjectFrontBlur(self.road_award_obj,mat)
		-- end
		-- self.title_txt.material = mat

		local id = DriveModel.data.map_data.map_id or 1
		local b = data.car_data.move_speed > 10 and data.car_data.end_pos ~= data.car_data.pos
		self["blur_" .. id].gameObject:SetActive(b)
	end
end

function C:on_road_award_on_trigger(data)
	--中奖时，在界面上显示
end

function C:on_car_move_end()
	local id = DriveModel.data.map_data.map_id or 1
	if id == 3 then id = 1 end
	self["blur_" .. id].gameObject:SetActive(false)
end

function C:on_view_round_end()
	--回合结束时,判断游戏是否结束并做相应表现
	self.obj_parent.gameObject:SetActive(false)
	local id = DriveModel.data.map_data.map_id or 1
	if id == 3 then id = 1 end
	self["blur_" .. id].gameObject:SetActive(false)
	self.title_txt.material = nil
	self.title_txt.text = DriveMapManager.SetMapString("game_status_title","准备发车")
	for k,v in ipairs(DriveModel.data.players_info) do
		if v.player_op then
			if v.player_op.op_type == DriveModel.OPType.select_road then
				self.title_txt.text = DriveMapManager.SetMapString("game_status_title","放置路障") 
			elseif v.player_op.op_type == DriveModel.OPType.select_skill then
				self.title_txt.text = DriveMapManager.SetMapString("game_status_title","选择技能")
			else
				self.title_txt.text = DriveMapManager.SetMapString("game_status_title","准备发车")
			end
			if v.seat_num == DriveModel.data.seat_num then
				self.enemy_me_txt.text = DriveMapManager.SetMapString("wo_fang_hui_he","我方回合")
				self.enemy_me_txt_out_line.effectColor = DriveMapManager.GetMapColor("wo_fang_hui_he_out_line")
			else
				self.enemy_me_txt.text = DriveMapManager.SetMapString("dui_fang_hui_he","敌方回合")
				self.enemy_me_txt_out_line.effectColor = DriveMapManager.GetMapColor("dui_fang_hui_he_out_line")
			end
			if v.seat_num == DriveModel.data.seat_num then
				self.timeout_txt.gameObject:SetActive(true)
				self.wait_txt.gameObject:SetActive(false)
				self:CloseWaitTimer()
			else
				self.timeout_txt.gameObject:SetActive(true)
				-- self.wait_txt.gameObject:SetActive(true)
				-- self:WaitTimer()
			end
		end
	end
end

function C:Countdowm()
	local op_timeout = DriveModel.get_op_timeout()
	if op_timeout <= 5 then
		ExtendSoundManager.PlaySound(audio_config.drive.com_main_map_caozuodaojishi.audio_name)
	end
	if IsEquals(self.timeout_txt) then
		self.timeout_txt.text = op_timeout < 0 and "" or op_timeout
	end
end

function C:WaitTimer()
	self:CloseWaitTimer()
	local count = 1
	self.wait_timer = Timer.New(function()
		count = count + 1
		if count > 3 then count = 1 end
		if IsEquals(self.wait_txt) then
			local txt = "对方回合\n"
			for i = 1,count do
				txt = txt .. "。"
			end
			self.wait_txt.text = txt
		end
	end,0.6,-1)
	self.wait_timer:Start()
end

function C:CloseWaitTimer()
	if self.wait_timer then 
		self.wait_timer:Stop()
		self.wait_timer = nil
	end
end