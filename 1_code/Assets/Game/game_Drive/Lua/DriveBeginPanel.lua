-- 创建时间:2021-02-02
-- Panel:DriveBeginPanel
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

DriveBeginPanel = basefunc.class()
local C = DriveBeginPanel
C.name = "DriveBeginPanel"

function C.Create(parent)
	return C.New(parent)
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
    self.listener = {}
	self.listener["model_pvp_all_info_req_response"] = basefunc.handler(self,self.on_model_pvp_all_info_req_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	
	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function C:InitUI()
	if DriveModel.data.players_info and next(DriveModel.data.players_info) then
		for seat_num = 1,2 do
			local name = DriveModel.data.players_info[seat_num].name
			local car_id = DriveModel.data.players_info[seat_num].car_id
			self["player" .. seat_num .. "_name_txt"].text = name
			self["player" .. seat_num .. "_car_img"].sprite = GetTexture(SysCarManager.config.car_config[car_id].image_config.game_top_img)
			if DriveModel.data.players_info[seat_num].duanwei_grade then
				self["player" .. seat_num .. "_rank_txt"].text = SysMatchManager.config.grade[DriveModel.data.players_info[seat_num].duanwei_grade].name
			end
			if seat_num == DriveModel.data.seat_num then
				self["player" .. seat_num .. "_car_img"].sprite = GetTexture(SysCarManager.config.car_config[SysCarManager.car_id].image_config.game_top_img)
			end
		end
	end
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_model_pvp_all_info_req_response()
	if DriveModel.data.car_data then
		for seat_num,cars in ipairs(DriveModel.data.car_data) do
			if cars and next(cars) then
				local car_data = cars[next(cars)]
				self["player" .. seat_num .. "_car_img"].sprite = GetTexture(SysCarManager.config.car_config[car_data.id].image_config.game_top_img)
			end
		end
	end
end