-- 创建时间:2021-02-01

local basefunc = require "Game/Common/basefunc"

RoadBarrierTimeBomb = basefunc.class(RoadBarrierBase)
local M = RoadBarrierTimeBomb
M.name = "RoadBarrierTimeBomb"

local effecter_field = 3


function M.Create(data)
    return M.New(data)
end

function M:MyExit()
    if self.listener then
        self:RemoveListener()
    end
    if self.life_value_change_seq then
        self.life_value_change_seq:Kill()
    end
    if self.road_rang_nodes then
        for k,v in pairs(self.road_rang_nodes) do
            destroy(v.gameObject)
        end
    end
    self.road_rang_nodes = nil
    destroy(self.gameObject)
    clear_table(self)
end

function M:MakeListener()
    self.listener = {}
    self.listener["logic_drive_game_process_data_msg_status_change"] = basefunc.handler(self,self.on_logic_drive_game_process_data_msg_status_change)
end

function M:ctor(data)
    RoadBarrierTimeBomb.super.ctor(self,data)
end

function M:OnCreate()
    if not self.road_rang_nodes then
        self.road_rang_nodes = DriveMapManager.ShowMapRangNode(
            DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id - effecter_field)
            ,DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id + effecter_field)
        )
    end
    self.skill_data = self.road_barrier_data.skill_datas[1]
    if self.skill_data then
        self.life_value = self.skill_data.life_value
        self.life_value_txt.text = self.skill_data.life_value
    end
end

function M:SetEnemyMeStyle()
    local mat = GetMaterial("InLightOutLine")
    if DriveModel.CheckOwnerIsMe(self.road_barrier_data) then
        mat = GetMaterial("InLightOutLineGreen")
    else
        mat = GetMaterial("InLightOutLineRed")
    end
    self.icon_img.material = mat
    self.item_img.material = mat
end

function M:MyRefresh(data)
	
end

function M:Refresh()
end

function M:PlayOnBoom(cbk)
    self.transform:Find("luzhang").gameObject:SetActive(false)
    self.boom_fx.gameObject:SetActive(true)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(85/60)
    seq:AppendCallback(function()
        if cbk then cbk() end
    end)
end

function M:on_logic_drive_game_process_data_msg_status_change(data)
    if DriveModel.GameingStatus[data.status] == DriveModel.GameingStatus.round_start then
        self.life_value = self.life_value or 0
        self.life_value = self.life_value - 1
        self.life_value_txt.text = self.life_value
        self.life_value_change_seq = DoTweenSequence.Create()
        self.life_value_change_seq:Append(self.life_value_txt.transform:DOScale(Vector3.New(0.8,0.8,1),0.4))
        self.life_value_change_seq:Append(self.life_value_txt.transform:DOScale(Vector3.New(0.4,0.4,1),0.2))
        self.life_value_change_seq:OnForceKill(function()
            self.life_value_change_seq = nil
        end)
    end
end