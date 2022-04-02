-- 创建时间:2021-02-21
local basefunc = require "Game/Common/basefunc"
SkillBuffBase = basefunc.class()

local M = SkillBuffBase
M.name = "SkillBuffBase"

local tag = "show_buff"

function M.Create(super)
    return M.New(super)
end

function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:MakeListener()
	self.listener = {}
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
    clear_table(self)
end

function M:ctor(super)
    self.super = super
    self:MakeListener()
    self:AddListener()
    self:InitUI()
end

function M:CheckSkillIsMe()
    if self.super.skill_data then
        if not DriveModel.CheckOwnerIsMe(self.super.skill_data) then
            return
        end
    
        for i,v in pairs(self.super.skill_cfg.tag or {}) do
            if v == tag then
                return true
            end
        end
    else
        if not DriveModel.CheckOwnerIsMe(self.super.buff_data) then
            return
        end
    
        for i,v in pairs(self.super.buff_cfg.tag or {}) do
            if v == tag then
                return true
            end
        end
    end
end

function M:SetStyle()
    self.bg_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_bg_jnd"))
    local cfg
    local icon_name
    if self.super.skill_cfg then
        cfg = self.super.skill_cfg
        if cfg.icon then
            icon_name = cfg.icon
        elseif cfg.skill_buff_icon then
            icon_name = cfg.skill_buff_icon
        end
    elseif self.super.buff_cfg then
        cfg = self.super.buff_cfg
        icon_name = cfg.icon
    end
    local sprite = GetTexture(DriveMapManager.GetMapAssets(icon_name))
    if sprite then
        self.icon_img.sprite = sprite
        self.tips_icon_img.sprite = sprite
    end
    sprite = nil
end

function M:InitUI(parent)
    if self.init_ui then return end
    if not self:CheckSkillIsMe() then return end

    -- dump(debug.traceback(),"<color=yellow>堆栈</color>")
    -- dump(self.super,"<color=white>buff栏初始化？？？？？</color>")

	--自己的技能
	local parent = parent or GameObject.Find("Canvas/GUIRoot/DrivePanel/@down_node/DriveSkillBuffContainer/@layout/@skill_layout")
    if not IsEquals(parent) then return end

    self.init_ui = true
	self.gameObject = newObject("SkillBuffBase",parent.transform)
	self.transform = self.gameObject.transform
	basefunc.GeneratingVar(self.transform, self)
	self:SetStyle()
    if self.super.skill_cfg then
        self.gameObject.name = self.super.skill_data.skill_id
        self.name_txt.text = self.super.skill_cfg.name
        self.tips_name_txt.text = self.super.skill_cfg.name
        self.tips_desc_txt.text = self.super.skill_cfg.desc
    elseif self.super.buff_cfg then
        self.gameObject.name = self.super.buff_data.buff_id
        self.name_txt.text = self.super.buff_cfg.name
        self.tips_name_txt.text = self.super.buff_cfg.name
        self.tips_desc_txt.text = self.super.buff_cfg.desc
    end
	EventTriggerListener.Get(self.icon_img.gameObject).onDown = basefunc.handler(self, self.OnDown)
	EventTriggerListener.Get(self.icon_img.gameObject).onUp = basefunc.handler(self, self.OnUp)
	EventTriggerListener.Get(self.icon_img.gameObject).onBeginDrag = basefunc.handler(self, self.OnBeginDrag)
	EventTriggerListener.Get(self.icon_img.gameObject).onDrag = basefunc.handler(self, self.OnDrag)
	EventTriggerListener.Get(self.icon_img.gameObject).onEndDrag = basefunc.handler(self, self.OnEndDrag)
end

function M:RefreshView(parent)
    if not self:CheckSkillIsMe() then return end
	--自己的道具
    if not self.init_ui then
        self:InitUI(parent)
    end
    self.num_txt.text = ""
    self.spend_mp_txt.text = ""
end

function M:OnDown(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnDown</color>")
	self.tips.gameObject:SetActive(true)
end

function M:OnUp(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnUp</color>")
	self.tips.gameObject:SetActive(false)
end

function M:OnBeginDrag(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnBeginDrag</color>")
	self.tips.gameObject:SetActive(false)
end

function M:OnDrag(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnDrag</color>")
end

function M:OnEndDrag(go,data)
	-- dump({go = go,data = data},"<color=yellow>OnEndDrag</color>")
end