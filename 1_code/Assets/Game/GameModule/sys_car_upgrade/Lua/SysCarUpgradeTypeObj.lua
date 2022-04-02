-- 创建时间:2021-05-31
-- Panel:SysCarUpgradeTypeObj
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

SysCarUpgradeTypeObj = basefunc.class()
local C = SysCarUpgradeTypeObj
C.name = "SysCarUpgradeTypeObj"

function C.Create(type_id,parent,panel)
	return C.New(type_id,parent,panel)
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
	destroy(self.gameObject)
	clear_table(self)
end

function C:ctor(type_id,parent,panel)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.type_id = type_id
	self.type_cfg = SysCarUpgradeManager.car_upgrade_type_config[self.type_id]
	self.panel = panel
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	
	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function C:InitUI()
	if self.type_cfg.type_name_img then
		self.car_type_name_img.sprite = GetTexture(self.type_cfg.type_name_img)
	end
	self.car_type_name_txt.text = self.type_cfg.type_name
	local default_car_id_cfg = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 4,
	}
	self.default_car_jy = GameObject.Instantiate(self.type_car_obj.transform,self.type_cars_layout)
	local default_jy_cfg = SysCarManager.GetCarCfg({car_type_id = default_car_id_cfg[self.type_id]})
	local tbl = basefunc.GeneratingVar(self.default_car_jy)
	self.default_car_jy.transform:GetComponent("Button").onClick:AddListener(function()
		TipsShowUpText.Create("尚未获得！")
	end)
	if default_jy_cfg.tag_name then
		self.car_type_name_txt.text = default_jy_cfg.tag_name
	end
	self.default_car_jy.gameObject:SetActive(true)
	tbl.car_small_img.sprite = GetTexture(default_jy_cfg.image_config.game_top_img)
	self.car_type_level_txt.text = 0
	self.car_type_level_name_txt.text = self.car_type_name_txt.text .. "大师"
	if self.type_id then
		local item_key_cfg = {
			[1] = "patch_falali",
			[2] = "patch_tanke",
			[3] = "patch_pingtou",
			[4] = "patch_dilei"
		}
		local patch_count = SysAssetModel.GetItemCount(item_key_cfg[self.type_id]) or 0
		tbl.star_progress_txt.text = patch_count .. "/10"
		tbl.star_progress_img.fillAmount = patch_count / 10
	end
	self:MyRefresh()
end

function C:RefreshItem(car_data)
	if not IsEquals(self.transform) then return end
	if self.default_car_jy then
		destroy(self.default_car_jy.gameObject)
		self.default_car_jy = nil
	end
	local car_id = car_data.base_data.car_id
	self.type_car_objs = self.type_car_objs or {}
	if not self.type_car_objs[car_id] then
		self.type_car_objs[car_id] = {
			car_id = car_id,
			obj = GameObject.Instantiate(self.type_car_obj.transform,self.type_cars_layout)
		}
		self.type_car_objs[car_id].obj.gameObject:SetActive(true)
		self.type_car_objs[car_id].tbl = basefunc.GeneratingVar(self.type_car_objs[car_id].obj.transform)
		
		self.type_car_objs[car_id].obj.transform:GetComponent("Button").onClick:AddListener(function()
			if self.panel then
				self.panel:MyRefresh(car_id)
			end
		end)
	end
	--通过base_data刷新单个车辆
	local tbl = self.type_car_objs[car_id].tbl
	tbl.car_level_txt.text = "Lv." .. car_data.base_data.level
	tbl.star_txt.text = car_data.base_data.star
	local car_cfg = SysCarUpgradeManager.GetCarUpgradeCfg(car_id)
	tbl.car_name_txt.text = car_cfg.car_name
	local _sys_car_cfg = SysCarManager.GetCarCfg({car_type_id = car_id})
	tbl.car_small_img.sprite = GetTexture(_sys_car_cfg.image_config.game_top_img)
	if self.panel and self.panel.cur_car_id == car_id then
		if IsEquals(tbl.highlight_img) then
			tbl.highlight_img.gameObject:SetActive(true)
		end
	else
		if IsEquals(tbl.highlight_img) then
			tbl.highlight_img.gameObject:SetActive(false)
		end
	end
	local spend_cfgs = {}
	for k,v in pairs(car_cfg.star_rule) do
		spend_cfgs[k] = SysCarUpgradeManager.car_upgrade_spend_config[v.spend] or {}
	end
	local spend_data = SysCarUpgradeManager.GetCurUpgradeSpend(car_data.base_data.star,spend_cfgs)
	tbl.star_progress_img.fillAmount = 1
	if car_data.base_data.star == 4 then
		tbl.star_progress_txt.text = "MAX"
	else
		tbl.star_progress_txt.text = "0/0"
		for k,v in pairs(spend_data) do
			if string.split(k,"_")[1] == "patch" then
				local cur_value = car_data.base_data.star
				local need_value = v
				tbl.star_progress_img.fillAmount = tonumber(cur_value) / need_value
				tbl.star_progress_txt.text = cur_value .. "/" .. need_value
			end
		end
	end
	
	if SysCarManager.car_id and SysCarManager.car_id == car_id then
		tbl.chuzhan_img.gameObject:SetActive(true)
	else
		tbl.chuzhan_img.gameObject:SetActive(false)
	end
	self.car_type_name_txt.text = SysCarManager.GetCarTagByCarId(car_id)
	--刷新类型等级
	local stars = 0
	for k,v in pairs(self.type_car_objs) do
		local type_car_obj_data = SysCarUpgradeManager.GetCarData(v.car_id)
		if type_car_obj_data and type_car_obj_data.base_data and type_car_obj_data.base_data.star then
			stars = stars + type_car_obj_data.base_data.star
		end
	end
	self.car_type_level_txt.text = stars
	self.car_type_level_name_txt.text = self.car_type_name_txt.text .. "大师"
end

function C:MyRefresh()
end
