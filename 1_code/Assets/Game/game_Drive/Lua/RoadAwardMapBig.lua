local basefunc = require "Game/Common/basefunc"

RoadAwardMapBig = basefunc.class(RoadAwardBase)
local M = RoadAwardMapBig
M.name = "RoadAwardMapBig"

function M.Create(road_award_data,create_cbk)
	return M.New(road_award_data,create_cbk)
end

function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:ctor(road_award_data,create_cbk)
	M.super.ctor(self,road_award_data)
	local parent = DriveMapManager.GetMapPrefabByRoadID(road_award_data.road_id,true)
	if not IsEquals(parent) then return end
	parent = parent.transform:Find("skill_node").transform
	local obj = newObject(M.name, parent)
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
    dump(process_datas,"<color=red>process_datas</color>")
    local skill_create_process_data
    local skill_create_data
    for k, v in ipairs(process_datas) do
        if v.skill_create then
            skill_create_data = v.skill_create
            skill_create_process_data = v
        end
    end

	self.cur_loop_sound = AudioManager.PlaySceneBGM(audio_config.drive.com_main_map_getbig.audio_name)
    local seq =DoTweenSequence.Create()
    seq:AppendInterval(5)
    seq:AppendCallback(function()
        AudioManager.PlayOldBGM()
    end)
    local fx_pre = newObject("zhongjiang_BIG", self.transform)

    local car
    if skill_create_data then
        car = DriveCarManager.GetCarByNo(skill_create_data.owner_data.owner_id)
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
					target_pos = DriveModel.Get3DTo2DPoint(target_pos)
                    DriveAnimManager.PlayGetSkillFx(self.road_award_cfg.icon, start_pos, target_pos)
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
            self.icon_node.gameObject:SetActive(true)
            if cbk then
                cbk()
            end
            dump(self,"<color=green>大招技能XXXX</color>")
            Event.Brocast("process_play_next")
        end
    )
    Event.Brocast("on_road_award_on_trigger", {obj = self.gameObject})
end
