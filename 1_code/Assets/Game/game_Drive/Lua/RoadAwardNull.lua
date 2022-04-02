local basefunc = require "Game/Common/basefunc"

RoadAwardNull = basefunc.class(RoadAwardBase)
local M = RoadAwardNull
M.name = "RoadAwardNull"

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

    local obj = newObject(DriveMapManager.GetMapAssets(obj_name), parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    basefunc.GeneratingVar(self.transform, self)
    self:InitUI()
end

function M:InitUI()
    self:MyRefresh()
end

function M:MyRefresh()
    if not IsEquals(self.gameObject) then
        return
    end
end

function M:SetBgImg(icon)
    if icon then
        self.bg_img.sprite = icon
    else
        self.bg_img.sprite = GetTexture("zd_bg_jnd_1_map3")
    end
end

function M:OnCreate()
end
function M:OnTrigger()
end
function M:OnPassBy()
    --路过时动画
    if self.seq1 then
        self.seq1:Kill()
        self.seq1 = nil
    end
    if not IsEquals(self.transform) then return end
    local now_parent = self.transform.parent
    self.seq1 = DoTweenSequence.Create()
    self.seq1:Append(self.transform:DOScale(Vector3.New(1.3, 1.3, 1), 0.2))
    self.seq1:AppendCallback(function()
        self.transform:SetParent(now_parent)
    end)
    self.seq1:Append(self.transform:DOScale(Vector3.New(1, 1, 1), 0.2))
    self.seq1:OnForceKill(
        function()
            self.transform.localScale = Vector3.New(1, 1, 1)
            self.seq1 = nil
        end
    )
end
function M:OnClose()
end