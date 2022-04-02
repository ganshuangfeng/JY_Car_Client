-- 创建时间:2021-02-01

local basefunc = require "Game/Common/basefunc"

RoadBarrierRedLamp = basefunc.class(RoadBarrierBase)
local M = RoadBarrierRedLamp
M.name = "RoadBarrierRedLamp"

-- local effecter_field = 1

function M.Create(data)
    return M.New(data)
end

function M:MyExitSubclass()
    if self.road_rang_nodes then
        for k,v in pairs(self.road_rang_nodes) do
            destroy(v.gameObject)
        end
    end
    self.road_rang_nodes = nil
end

function M:ctor(data)
    RoadBarrierRedLamp.super.ctor(self,data)
end

function M:OnCreate()
    if not self.road_rang_nodes then
        local range = self:CheckEffectRange()
        if range and range > 0 then
            if tonumber(range) % 2 ~= 0 then
                local effecter_field = math.floor(range / 2)
                self.road_rang_nodes = DriveMapManager.ShowMapRangNode(
                    DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id - effecter_field),
                    DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id + effecter_field))
            else
                local behind_count = range / 2 - 1
                local after_count = range / 2
                self.road_rang_nodes = DriveMapManager.ShowMapRangNode(
                    DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id - behind_count),
                    DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id + after_count))
            end
        end
    end
end
function M:SetEnemyMeStyle()
    local mat = GetMaterial("InLightOutLine")
    if DriveModel.CheckOwnerIsMe(self.road_barrier_data) then
        mat = GetMaterial("InLightOutLineGreen")
    else
        mat = GetMaterial("InLightOutLineRed")
    end
    -- self.icon_img.material = mat
    self.item_img.material = mat
end

function M:MyRefresh(data)
	
end

function M:Refresh()
end

function M:PlayOnBoom(cbk)
    AudioManager.PlaySound(audio_config.drive.com_main_map_hongdeng.audio_name)
    self.transform:Find("luzhang"):GetComponent("Animator").enabled = false
    self.hong_img.gameObject:SetActive(true)
    -- self.item_img.material = nil
    self.lv_img.gameObject:SetActive(false)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1)
    seq:AppendCallback(function()
    self.transform:Find("luzhang"):GetComponent("Animator").enabled = true
    self.transform:Find("luzhang"):GetComponent("Animator"):Play("honglvdeng_xiaoshi",0,0)
    end)
    seq:AppendInterval(2/3)
    seq:AppendCallback(function()
        self.gameObject:SetActive(false)
        if cbk then cbk() end
    end)
end