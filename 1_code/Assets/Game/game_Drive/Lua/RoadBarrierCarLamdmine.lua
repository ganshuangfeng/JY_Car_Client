-- 创建时间:2021-02-01

local basefunc = require "Game/Common/basefunc"

RoadBarrierCarLamdmine = basefunc.class(RoadBarrierBase)
local M = RoadBarrierCarLamdmine
M.name = "RoadBarrierCarLamdmine"



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
    destroy(self.gameObject)
    clear_table(self)
end

function M:MakeListener()
    self.listener = {}
end

function M:ctor(data)
    RoadBarrierCarLamdmine.super.ctor(self,data)
    self.life_value_txt.text = "Lv" .. tonumber(self.road_barrier_data.lv or 0)
    self.life_value_txt.gameObject:SetActive(false)
end

function M:DefaultOnCreate()
    if self.road_barrier_data.lv and self.road_barrier_data.lv > 1 then
        AudioManager.PlaySound(audio_config.drive.com_main_map_leishengji.audio_name)
        self:OnCreate()
        --升级采用不同的表现
        self.yanwu.gameObject:SetActive(false)
        self.transform:Find("luzhang").transform:GetComponent("Animator").enabled = false
        local level_up_pre = newObject("dilei_LG",self.transform)
        local fx_pre = DriveAnimManager.PlayNewAttributeChangeFx("normal_text_font_fx",nil,"Lv." .. self.road_barrier_data.lv,true,self.transform.position,function()
            destroy(level_up_pre)
        end)
        fx_pre.transform:Find("@add_desc_txt"):GetComponent("TMP_Text").color = Color.New(1,183/255,0)
        
    else
        self.super.DefaultOnCreate(self)
    end
end

function M:OnCreate()
    if self.road_barrier_data.lv then
        for i = 1,3 do
            if i == self.road_barrier_data.lv then
                self["lv" .. i].gameObject:SetActive(true)
            else
                self["lv" .. i].gameObject:SetActive(false)
            end
        end
    else
        self.lv1.gameObject:SetActive(true)
    end
end

function M:SetEnemyMeStyle()
    local mat = GetMaterial("InLightOutLine")
    if DriveModel.CheckOwnerIsMe(self.road_barrier_data) then
        local mesh_renderer  = self["lv" .. self.road_barrier_data.lv]:GetComponent("MeshRenderer")
        for i = 0 ,mesh_renderer.materials.Length - 1 do
            if mesh_renderer.materials[i].shader.name == "MyUnlit/CartoonShading1" then
                mesh_renderer.materials[i]:SetFloat("_Outline",0.009)
                mesh_renderer.materials[i]:SetColor("_OutlineColor",Color.green)
            end
        end
    else
        local mesh_renderer  = self["lv" .. self.road_barrier_data.lv]:GetComponent("MeshRenderer")
        for i = 0 ,mesh_renderer.materials.Length - 1 do
            if mesh_renderer.materials[i].shader.name == "MyUnlit/CartoonShading1" then
                mesh_renderer.materials[i]:SetFloat("_Outline",0.009)
                mesh_renderer.materials[i]:SetColor("_OutlineColor",Color.red)
            end
        end
    end
    self.icon_img.material = mat
    self.item_img.material = mat
end

function M:MyRefresh(data)
	self:SetEnemyMeStyle()
end

function M:Refresh()
end

function M:PlayOnBoom(cbk)
    self.transform:Find("luzhang"):GetComponent("Animator").enabled = false
    local seq = DoTweenSequence.Create()
    seq:Append(self.item_img.transform:DOScale(Vector3.New(1.5,1.5,1),0.4))
    seq:Append(self.item_img.transform:DOScale(Vector3.New(0.8,0.8,1),0.2))
    seq:Append(self.item_img.transform:DOScale(Vector3.New(1,1,1),0.1))
    seq:Append(self.item_img.transform:DOScale(Vector3.New(1.5,1.5,1),0.4))
    seq:Append(self.item_img.transform:DOScale(Vector3.New(0.8,0.8,1),0.2))
    seq:Append(self.item_img.transform:DOScale(Vector3.New(1,1,1),0.1))
    seq:AppendCallback(function()
        if cbk then cbk() end
    end)
end