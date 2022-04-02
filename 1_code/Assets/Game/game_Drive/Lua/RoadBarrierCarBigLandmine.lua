-- 创建时间:2021-02-01

local basefunc = require "Game/Common/basefunc"

RoadBarrierCarBigLandmine = basefunc.class(RoadBarrierBase)
local M = RoadBarrierCarBigLandmine
M.name = "RoadBarrierCarBigLandmine"


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
end

function M:ctor(data)
    RoadBarrierCarBigLandmine.super.ctor(self,data)
end

function M:DefaultOnCreate()
    AudioManager.PlaySound(audio_config.drive.com_main_map_fangzhiluzhang.audio_name)
    local animator = self.transform:Find("luzhang"):GetComponent("Animator")
    animator.enabled = true
    self.transform.localPosition = Vector3.zero
    self:OnCreate()
end

function M:OnCreate()
    self.life_value_txt.gameObject:SetActive(false)
    -- if not self.road_rang_nodes then
    --     local range = self:CheckEffectRange()
    --     if range and range > 0 then
    --         if tonumber(range) % 2 ~= 0 then
    --             local effecter_field = math.floor(range / 2)
    --             self.road_rang_nodes = DriveMapManager.ShowMapRangNode(
    --                 DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id - effecter_field),
    --                 DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id + effecter_field))
    --         else
    --             local behind_count = range / 2 - 1
    --             local after_count = range / 2
    --             self.road_rang_nodes = DriveMapManager.ShowMapRangNode(
    --                 DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id - behind_count),
    --                 DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id + after_count))
    --         end
    --     end
    -- end
end

function M:SetEnemyMeStyle()
    local mat = GetMaterial("InLightOutLine")
    if DriveModel.CheckOwnerIsMe(self.road_barrier_data) then
        mat = GetMaterial("InLightOutLineGreen")
    else
        mat = GetMaterial("InLightOutLineRed")
    end
    if DriveModel.CheckOwnerIsMe(self.road_barrier_data) then
        local mesh_renderer  = self.transform:Find("luzhang/@item_img/dilei_Super"):GetComponent("MeshRenderer")
        for i = 0 ,mesh_renderer.materials.Length - 1 do
            if mesh_renderer.materials[i].shader.name == "MyUnlit/CartoonShading" then
                mesh_renderer.materials[i]:SetFloat("_Outline",0.009)
                mesh_renderer.materials[i]:SetColor("_OutlineColor",Color.green)
            end
        end
    else
        local mesh_renderer  = self.transform:Find("luzhang/@item_img/dilei_Super"):GetComponent("MeshRenderer")
        for i = 0 ,mesh_renderer.materials.Length - 1 do
            if mesh_renderer.materials[i].shader.name == "MyUnlit/CartoonShading" then
                mesh_renderer.materials[i]:SetFloat("_Outline",0.009)
                mesh_renderer.materials[i]:SetColor("_OutlineColor",Color.red)
            end
        end
    end
    self.icon_img.material = mat
    self.item_img.material = mat
end

function M:MyRefresh(data)
	
end

function M:Refresh()
end

function M:PlayOnBoom(cbk)
    self.transform:Find("luzhang"):GetComponent("Animator").enabled = false
    local seq = DoTweenSequence.Create()
    seq:Append(self.icon_img.transform:DOScale(Vector3.New(1.5,1.5,1),0.4))
    seq:Append(self.icon_img.transform:DOScale(Vector3.New(0.8,0.8,1),0.2))
    seq:Append(self.icon_img.transform:DOScale(Vector3.New(1,1,1),0.1))
    seq:Append(self.icon_img.transform:DOScale(Vector3.New(1.5,1.5,1),0.4))
    seq:Append(self.icon_img.transform:DOScale(Vector3.New(0.8,0.8,1),0.2))
    seq:Append(self.icon_img.transform:DOScale(Vector3.New(1,1,1),0.1))
    seq:AppendCallback(function()
        if cbk then cbk() end
    end)
end