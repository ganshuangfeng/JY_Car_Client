-- 创建时间:2021-1-26
-- Panel:DriveClearingPanel
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

 local game_end_reason_desc = {
	[2] = {
		"zd_img_ydbs",
		"zd_img_sdbs",
	},
	[1] = {
		"zd_img_jbds",
		"zd_img_cssh",
	},
	[3] = {
		"zd_img_jjsl",
		"zd_img_pc"
	}
}

local basefunc = require "Game/Common/basefunc"

DriveClearingPanel = basefunc.class()
local C = DriveClearingPanel
C.name = "DriveClearingPanel"

local instance
function C.Create(settlement_data)
	dump(instance,"<color=white>instance????????????</color>")
	dump(settlement_data,"<color=yellow>settlement_data 结算数据</color>")
	if instance then
		instance:MyExit()
	end
	instance = C.New(settlement_data)
	return instance
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
    self.listener = {}
	self.listener["model_on_pvp_game_settlement_msg"] = basefunc.handler(self,self.on_model_on_pvp_game_settlement_msg)
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
	instance = nil
end

function C:ctor(settlement_data)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = settlement_data
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	self.rank_progress_slider = self.rank_progress_slider.transform:GetComponent("Slider")
	
	self:MakeListener()
	self:AddListener()
	self:InitUI()
	self.quit_btn.onClick:AddListener(function()
		Event.Brocast("dbss_send_power",{key = "rank_match_clearing_panel"})
		DriveModel.SendRequest("pvp_quit_game",nil)
	end)
	self.replay_btn.onClick:AddListener(function()
		DriveModel.InitGameData()
		DriveModel.SendRequest("pvp_quit_game",nil,function()
			local game_id = DriveLogic.InitPram.game_id
			DriveModel.SendRequest("pvp_signup",{id = game_id,car_id = DriveLogic.InitPram.car_id or 1})
		end)
		self:MyExit()
	end)
end

function C:InitMapAsset()
	-- self.quit_btn.transform:GetComponent("Image").sprite = GetTexture(DriveMapManager.GetMapAssets("zd_btn_fh"))
	-- self.replay_btn.transform:GetComponent("Image").sprite = GetTexture(DriveMapManager.GetMapAssets("zd_btn_jx"))
end

function C:InitUI()
	self:InitMapAsset()
	if not self.data then return end
	if self.data.win_seat_num == DriveModel.data.seat_num then
		basefunc.GeneratingVar(self.win_node,self)
		AudioManager.PlaySound(audio_config.drive.com_main_map_gamewin.audio_name)
		self.win_node.gameObject:SetActive(true)
		self.lose_node.gameObject:SetActive(false)
		-- self.win_desc_img.sprite = GetTexture(game_end_reason_desc[self.data.win_reason][1])
		local cars_in_seat_num = DriveCarManager.cars[DriveModel.data.seat_num]
		self.win_car_img.gameObject:SetActive(false)
	elseif self.data.win_seat_num ~= DriveModel.data.seat_num then
		basefunc.GeneratingVar(self.lose_node,self)
		AudioManager.PlaySound(audio_config.drive.com_main_map_gamelose.audio_name)
		self.win_node.gameObject:SetActive(false)
		self.lose_node.gameObject:SetActive(true)
		-- self.lose_desc_img.sprite = GetTexture(game_end_reason_desc[self.data.win_reason][2])
	end
	if self.data.award and self.data.award[DriveModel.data.seat_num] then
		local award_count = self.data.award[DriveModel.data.seat_num]
		if award_count >= 0 then
			award_count = "+" .. award_count
		end
		if self.data.win_seat_num == DriveModel.data.seat_num then
			self.win_money_award_txt.text = TMPNormalStringConvertTMPSpriteStr(award_count)
		else
			self.lose_money_award_txt.text = TMPNormalStringConvertTMPSpriteStr(award_count)
		end
	end
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefershPvpSettlement()
end

function C:RefershPvpSettlement()
	dump(DriveModel.data.pvp_game_settlement_data)
	self.rank_progress_slider = self.rank_progress_slider.transform:GetComponent("Slider")
	if DriveModel.data.pvp_game_settlement_data then
		local pvp_settlement_data = DriveModel.data.pvp_game_settlement_data
		local change_score = pvp_settlement_data.change_score
		local level_cur_score = pvp_settlement_data.level_cur_score
		local level_all_score = pvp_settlement_data.level_all_score
		self.rank_progress_txt.text = level_cur_score .. "/" .. level_all_score
		self.rank_add_progress_txt.text = (change_score >= 0) and "+" .. change_score or change_score
		if change_score ~= 0 then
			local before_score = level_cur_score - change_score
			if before_score > level_all_score then before_score = level_all_score end
			if before_score <= 0 then before_score = 0 end
			self:PlayExp(before_score / level_all_score,level_cur_score / level_all_score,1)
		else
			local before_score = 0
			if before_score > level_all_score then before_score = level_all_score end
			if before_score <= 0 then before_score = 0 end
			self:PlayExp(before_score / level_all_score,level_cur_score / level_all_score,1)
		end
		local cfg = SysMatchManager.GetGradeLevelAward(pvp_settlement_data.grade,pvp_settlement_data.level)
		self.cur_rank_txt.text = cfg.name
		self.cur_rank_img.sprite = GetTexture(cfg.icon)
		if pvp_settlement_data.win_status == 1 and pvp_settlement_data.hold_count > 1 then
			self.cur_ls_txt.gameObject:SetActive(true)
			self.cur_ls_txt.text = pvp_settlement_data.hold_count .. "连胜"
		else
			self.cur_ls_txt.gameObject:SetActive(false)
		end
		if pvp_settlement_data.fight_award and next(pvp_settlement_data.fight_award) then
			for k,v in ipairs(pvp_settlement_data.fight_award) do
				if v.asset_type == "bao_xiang" then
					local box_award_obj = GameObject.Instantiate(self.award_item.gameObject,self.award_parent)
					local tbl = basefunc.GeneratingVar(box_award_obj.transform)
					box_award_obj.gameObject:SetActive(true)
					tbl.award_count_txt.gameObject:SetActive(false)
					local box_cfg = SysBoxManager.GetBoxConfigByID(tonumber(v.asset_value))
					tbl.award_icon_img.sprite = GetTexture(box_cfg.icon)
					local bg_id = string.split(box_cfg.bg,"_")[3] or 1
					tbl.award_di_img.sprite = GetTexture("ty_zbd_0" .. bg_id)
				else
				end
			end
		end
	end
end

function C:on_model_on_pvp_game_settlement_msg()
	if IsEquals(self.transform) then
		self:RefershPvpSettlement()
	end
end

function C:PlayExp(start_v,end_v,duration,cbk)
	self.rank_progress_slider = self.rank_progress_slider.transform:GetComponent("Slider")
	local cur_v = start_v
	self.DOTProcesse = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
			function(value)
				cur_v = start_v
				self.rank_progress_slider.value = cur_v
                return cur_v
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				cur_v = value
				self.rank_progress_slider.value = cur_v
            end
        ),
        end_v,
		duration
	)
	self.DOTProcesse:SetEase(Enum.Ease.Linear)
end