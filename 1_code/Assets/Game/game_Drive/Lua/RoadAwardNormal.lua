local basefunc = require "Game/Common/basefunc"

RoadAwardNormal = basefunc.class(RoadAwardBase)
local M = RoadAwardNormal
M.name = "RoadAwardNormal"

function M.Create(road_award_data, create_cbk)
    return M.New(road_award_data, create_cbk)
end

function M:ctor(road_award_data, create_cbk)
    M.super.ctor(self, road_award_data)

    local parent = DriveMapManager.GetMapPrefabByRoadID(road_award_data.road_id, true)
    if not IsEquals(parent) then
        return
    end
    parent = parent.transform:Find("skill_node").transform
    
    local obj_name = M.name
    if self.road_award_cfg.map_icon_prefab then
        obj_name = self.road_award_cfg.map_icon_prefab
    end

    local obj = newObject(DriveMapManager.GetMapAssets(obj_name), parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    basefunc.GeneratingVar(self.transform, self)
    self:InitUI()
end

function M:InitUI()
    self:MyRefresh()
    self:OnCreate()
end

function M:MyRefresh()
    if not IsEquals(self.gameObject) then
        return
    end

    if not self.road_award_cfg then return end
    local level = self.road_award_cfg.level or 1
    if not self.road_award_cfg.map_icon_prefab then
        -- self.bg_img.sprite = GetTexture(DriveMapManager.GetMapAssets("zd_bg_jnd_" .. (level == 1 and 1 or 3)))
        self:SetBgImg(GetTexture(DriveMapManager.GetMapAssets("zd_bg_jnd_" .. (level == 1 and 1 or 3))))
        self.icon_img.sprite = GetTexture(DriveMapManager.GetMapAssets(self.road_award_cfg.icon))
    else
        self:SetBgImg(self.bg_img.sprite)
    end
    self.bg_img.gameObject:SetActive(false)
end

function M:OnCreate(cbk)
    if cbk then
        cbk()
    end
    -- Event.Brocast("process_play_next")
end

function M:OnTrigger(road_award_change_data, cbk)
    --关闭时动画
    if self.seq then
        self.seq:Kill()
        self.seq = nil
    end
    local process_datas = DriveLogicProcess.get_process_data_by_father_process_no(road_award_change_data.process_no)
    local create_data
    --按创建的效果找到发奖的对象
    for k, v in ipairs(process_datas) do
        if v.skill_create or v.tool_create then
            create_data = v.skill_create or v.tool_create
        end
    end
    
    local fx_pre
    if self.road_award_cfg.key == "zailaiyici" then
        fx_pre = newObject("zhongjiang_agin", self.transform)
    else
        fx_pre = newObject("zhongjiang_zong", self.transform)
        if self.road_award_cfg.level == 1 then
            AudioManager.PlaySound(audio_config.drive.com_main_map_getaward.audio_name)
        else
            AudioManager.PlaySound(audio_config.drive.com_main_map_getaward2.audio_name)
        end
    end
    fx_pre.transform.rotation = Quaternion:SetEuler(0,0,0)

    local car
    if create_data then
        car = DriveCarManager.GetCarByNo(create_data.owner_data.owner_id)
    end

    self.seq = DoTweenSequence.Create()
    self.seq:AppendInterval(1)
    if car then
        self.seq:AppendCallback(
            function()
                if IsEquals(self.icon_node) then
                    self.icon_node.gameObject:SetActive(false)
                end
                if IsEquals(self.transform) then
                    local start_pos = DriveModel.Get3DTo2DPoint(self.transform.position)
                    local target_pos = car:GetCenterPosition()
                    if self.road_award_cfg.key == "zailaiyici" and car.car_data.seat_num == DriveModel.data.seat_num then
                        target_pos = DriveAccelerator.GetInstance().start_btn.transform.position
                    elseif self.road_award_cfg.key == "bomb2" or self.road_award_cfg.key == "bomb1" then
                        self.icon_node.gameObject:SetActive(true)
                        target_pos = nil
                    else
                        target_pos = DriveModel.Get3DTo2DPoint(target_pos)
                    end
                    if start_pos and target_pos then
                        DriveAnimManager.PlayGetSkillFx(self.road_award_cfg.icon, start_pos, target_pos)
                    end
                end
            end
        )
        self.seq:AppendInterval(0.5)
        self.seq:AppendCallback(
            function()
                destroy(fx_pre)
            end
        )
    end
    self.seq:OnForceKill(
        function()
            if fx_pre and IsEquals(fx_pre) then
                destroy(fx_pre)
            end
            if self.road_award_cfg and (self.road_award_cfg.key == "zailaiyici") then
                self.icon_node.gameObject:SetActive(true)
            end
            if cbk then
                cbk()
            end
            Event.Brocast("process_play_next")
        end
    )
    Event.Brocast("on_road_award_on_trigger", {obj = self.gameObject})
end
