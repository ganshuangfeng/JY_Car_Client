local basefunc = require "Game/Common/basefunc"

RoadAwardBase = basefunc.class()
local M = RoadAwardBase
M.name = "RoadAwardBase"

function M.Create(data, create_cbk)
    return M.New(data, create_cbk)
end

function M:AddListener()
    for proto_name, func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:MakeListener()
    self.listener = {}
    self.listener["car_move_to_pos"] = basefunc.handler(self,self.on_car_move_to_pos)
end

function M:RemoveListener()
    for proto_name, func in pairs(self.listener or {}) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:MyExit(play_next_process)
    if self.seq then
        -- self.seq:Kill()
        self.seq = nil
    end
    if self.seq1 then
        self.seq1:Kill()
        self.seq1 = nil
    end
    self:RemoveListener()
    destroy(self.gameObject)
    if play_next_process then
        -- Event.Brocast("process_play_next")
    end
    clear_table(self)
end

function M:ctor(data, create_cbk)
    self.road_award_data = data
	self.road_award_cfg = RoadAwardManager.GetRoadAwardCfgByTypeId(data.type_id)
	self.create_cbk = create_cbk
    --用于路过的时候的显示
    if self.road_award_cfg then
        self.obj_name = self.road_award_cfg.name
	end
    self:MakeListener()
	self:AddListener()
end

function M:InitUI()

end

function M:MyRefresh(data)
	
end

function M:MyClose(cbk)
    self:OnClose(
        function()
            self:MyExit()
            if cbk then
                cbk()
            end
        end
    )
end

function M:Refresh(road_award_data)
    if not road_award_data or not road_award_data.road_award_type  or not road_award_data.type_id or not road_award_data.road_id then
        dump(road_award_data, "<color=red>road_award_data 刷新数据错误</color>")
        return
    end

    if not self.road_award_cfg then
        dump(self.road_award_cfg, "<color=red>road_award_cfg 刷新配置错误</color>")
        return
    end

    if self.road_award_data.road_award_type ~= road_award_data.road_award_type or self.road_award_cfg.type_id ~= road_award_data.type_id then
        return
    end

    self.road_award_data = road_award_data
    self:MyRefresh()
end

local blink_interval = 0.1

function M:OnCreate()
    --创建时动画
    if self.seq then
        self.seq:Kill()
        self.seq = nil
    end
    self.seq = DoTweenSequence.Create()
    for i = 1, 4 do
        self.seq:AppendCallback(
            function()
                if IsEquals(self.gameObject) then
                    self.gameObject:SetActive(false)
                end
            end
        )
        self.seq:AppendInterval(blink_interval)
        self.seq:AppendCallback(
            function()
                if IsEquals(self.gameObject) then
                    self.gameObject:SetActive(true)
                end
            end
        )
        self.seq:AppendInterval(blink_interval)
    end

    self.seq:OnForceKill(
        function()
            if IsEquals(self.gameObject) then
                self.gameObject:SetActive(true)
            end
            self.seq = nil
            if self.create_cbk then
                self.create_cbk()
                self.create_cbk = nil
            end
            -- Event.Brocast("process_play_next")
        end
    )
end

function M:OnRefresh()
    --刷新时动画
    if self.seq then
        self.seq:Kill()
        self.seq = nil
    end
    self.seq = DoTweenSequence.Create()
    self.seq:Append(self.transform:DOScale(Vector3.New(1.2, 1.2, 1), 0.4))
    self.seq:OnForceKill(
        function()
            self.transform.localScale = Vector3.New(1, 1, 1)
            self.seq = nil
        end
    )
end
function M:OnTrigger()
    --刷新时动画
    if self.seq then
        self.seq:Kill()
        self.seq = nil
    end
    self.seq = DoTweenSequence.Create()
    self.seq:Append(self.transform:DOScale(Vector3.New(1.2, 1.2, 1), 0.4))
    self.seq:OnForceKill(
        function()
            self.transform.localScale = Vector3.New(1, 1, 1)
            self.seq = nil
            Event.Brocast("process_play_next")
        end
    )
end

function M:OnClose(cbk)
    --关闭时动画
    if self.seq then
        self.seq:Kill()
        self.seq = nil
    end
    self.seq = DoTweenSequence.Create()
    for i = 1, 4 do
        self.seq:AppendCallback(
            function()
                self.gameObject:SetActive(true)
            end
        )
        self.seq:AppendInterval(blink_interval)
        self.seq:AppendCallback(
            function()
                self.gameObject:SetActive(false)
            end
        )
        self.seq:AppendInterval(blink_interval)
    end

    self.seq:OnForceKill(
        function()
            self.gameObject:SetActive(false)
            self.seq = nil
            if cbk then
                cbk()
            end
        end
    )
end

function M:on_car_move_to_pos(data)
    local _road_id = DriveMapManager.ServerPosConversionRoadId(data.pos)
    if _road_id == self.road_award_data.road_id then
        self:OnPassBy(data)
    end
end

function M:OnPassBy(data)
    --路过时动画
    if self.seq1 then
        self.seq1:Kill()
        self.seq1 = nil
    end
    if not IsEquals(self.transform) then return end
    local now_parent = self.transform.parent
    -- local new_parent = DrivePanel.Instance().skill_parent
    -- self.transform:SetParent(new_parent)
    self.seq1 = DoTweenSequence.Create()
    AudioManager.PlaySound(audio_config.drive.com_main_move.audio_name)
    self.seq1:Append(self.transform:DOScale(Vector3.New(1.3, 1.3, 1), 0.2))
    self.seq1:AppendCallback(function()
        self.transform:SetParent(now_parent)
    end)
    self.seq1:Append(self.transform:DOScale(Vector3.New(1, 1, 1), 0.2))
    self.seq1:OnForceKill(
        function()
            if IsEquals(self.transform) then
                self.transform.localScale = Vector3.New(1, 1, 1)
            end
            self.seq1 = nil
        end
    )
    Event.Brocast("road_award_on_pass_by",{obj = self.gameObject,skill_cfg = self.skill_cfg,obj_name = self.obj_name,car_data = data.car_data})
end

function M:SetBgImg(icon)
    RoadAwardManager.SetAwardBg(self.road_award_data.road_id,icon)
end

function M:CreateDoubleAward(award_value)
    self:ClearDoubleAward()
    self.double_award_icon = newObject("buff_double_award_icon",self.transform)
    if award_value and award_value > 0 then
        self.double_award_icon.transform:Find("@font_txt"):GetComponent("TMP_Text").text = TMPNormalStringConvertTMPSpriteStr("x" .. award_value)
    end
end

function M:ClearDoubleAward()
    if self.double_award_icon then
        destroy(self.double_award_icon)
        self.double_award_icon = nil
    end
end