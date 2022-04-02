-- 创建时间:2021-02-01

local basefunc = require "Game/Common/basefunc"

RoadBarrierBase = basefunc.class()
local M = RoadBarrierBase
M.name = "RoadBarrierBase"

function M.Create(data)
    return M.New(data)
end

function M:AddListener()
    for proto_name, func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:MakeListener()
    self.listener = {}
end

function M:RemoveListener()
    for proto_name, func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:MyExit()
    if self.listener then
        self:RemoveListener()
    end
    destroy(self.gameObject)
    self:MyExitSubclass()
    clear_table(self)
end

function M:MyExitSubclass()

end

function M:ctor(data)
    self.road_barrier_data = data
    
	local parent = DriveMapManager.GetMapPrefabByRoadID(self.road_barrier_data.road_id,true)
	local obj = newObject(self.road_barrier_data.class_type or M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    basefunc.GeneratingVar(self.transform, self)
    self:MakeListener()
    self:AddListener()
    if self.road_barrier_data.process_no then
        --播放创建自己所有的技能的数据的流程
        local skill_create_datas = DriveLogicProcess.get_process_data_by_father_process_no(self.road_barrier_data.process_no)
        for k,v in ipairs(skill_create_datas) do
            if v.skill_create then
                self.road_barrier_data.skill_datas = self.road_barrier_data.skill_datas or {}
                self.road_barrier_data.skill_datas[#self.road_barrier_data.skill_datas+1] = v.skill_create.skill_data
            end
        end
    end
    self:InitUI()
    self:SetEnemyMeStyle()
end

function M:InitUI()
    self:DefaultOnCreate()
end

function M:DefaultOnCreate()
    self.yanwu.gameObject:SetActive(false)
    local parent = self.transform.parent
    -- self.transform:SetParent(GameObject.Find("Canvas/LayerLv3").transform)
    -- self.transform.position = DriveModel.Get3DTo2DPoint(parent.position)
    local launcher_car 
    if self.road_barrier_data.owner_type == -1 then
        launcher_car = DriveSystemManager.GetSystem()
        self.transform.position = DriveMapManager.GetMapPrefabByRoadID(self.road_barrier_data.road_id,true).transform.position
    elseif self.road_barrier_data.owner_type == 1 then
        if self.road_barrier_data.owner_id == DriveModel.data.seat_num then
            -- set_sprite_renderer_alpha(self.transform,0.8)
        end
    elseif self.road_barrier_data.owner_type == 2 then
        --动画表现 生成时从车上抛出
        launcher_car = DriveCarManager.GetCarByNo(self.road_barrier_data.owner_id)
        self.transform.position = launcher_car.transform.position
        if launcher_car.car_data.seat_num == DriveModel.data.seat_num then
            -- set_sprite_renderer_alpha(self.transform,0.8)
        end
    end

    self.transform.localScale = Vector3.New(1.03,1.03,1)
    local animator = self.transform:Find("luzhang"):GetComponent("Animator")
    animator.enabled = false
    local seq = DoTweenSequence.Create()
    seq:Append(self.transform:DOLocalMove(parent.transform.position,0.5))
    seq:Join(self.transform:DOScale(Vector3.New(0.8,0.8,1),0.5))
    seq:AppendCallback(function()
        animator.enabled = true
        self.transform:SetParent(parent)
        self.transform.localPosition = Vector3.zero
        self:OnCreate()
    end)
    AudioManager.PlaySound(audio_config.drive.com_main_map_fangzhiluzhang.audio_name)
    local euler_z = 0
    self.transform.localRotation = Quaternion:SetEuler(0,0,euler_z)
end

function M:OnCreate()
end

function M:SetEnemyMeStyle()
    local mat = GetMaterial("InLightOutLine")
    if DriveModel.CheckOwnerIsMe(self.road_barrier_data) then
        mat = GetMaterial("InLightOutLineGreen")
    else
        mat = GetMaterial("InLightOutLineRed")
    end
    self.item_img.material = mat
end

function M:MyRefresh(data)
	
end

function M:Refresh()
end

function M:CheckEffectRange()
    local range = 0
    if self.road_barrier_data.skill_datas and next(self.road_barrier_data.skill_datas) then 
        for k,v in ipairs(self.road_barrier_data.skill_datas) do 
            if v and v.other_data then
                for k,v in ipairs(v.other_data) do
                    if v.key == "range" then
                        range = tonumber(v.value)
                        return range
                    end
                end
            end
        end
    end
    return range
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