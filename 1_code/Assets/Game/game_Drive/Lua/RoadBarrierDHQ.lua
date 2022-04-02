-- 创建时间:2021-02-01

local basefunc = require "Game/Common/basefunc"

RoadBarrierDHQ = basefunc.class(RoadBarrierBase)
local M = RoadBarrierDHQ
M.name = "RoadBarrierDHQ"

function M.Create(data)
    return M.New(data)
end

function M:MyExitSubclass()
    if self.tag_pres then
        for k,v in pairs(self.tag_pres) do
            if IsEquals(v) then 
                destroy(v)
            end
        end
    end
    if self.road_rang_nodes then
        for k,v in pairs(self.road_rang_nodes) do
            destroy(v.gameObject)
        end
    end
    self.road_rang_nodes = nil
    self:CloseSmalAcc()
end
-- local range = 3

function M:ctor(data)
    RoadBarrierDHQ.super.ctor(self,data)
end

function M:MakeListener()
    self.listener = {}
    self.listener["small_youmen_small_acc_create"] = basefunc.handler(self,self.on_small_youmen_small_acc_create)
    self.listener["car_move_slide"] = basefunc.handler(self,self.on_car_move_slide)
    self.listener["car_move_end"] = basefunc.handler(self,self.CloseSmalAcc)
    self.listener["logic_drive_game_process_data_msg_player_op"] = basefunc.handler(self,self.CloseSmalAcc)
end

function M:OnCreate()
    local seq = DoTweenSequence.Create()
    local parent_position = DriveMapManager.ServerPosConversionMapVector(self.road_barrier_data.road_id)
    if not self.road_rang_nodes then
        local range = self:CheckEffectRange()
        if range and range > 0 then
            if tonumber(range) % 2 ~= 0 then
                local effecter_field = math.floor(range / 2)
                self.road_rang_nodes = DriveMapManager.ShowMapRangNode(
                    DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id - effecter_field),
                    DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id + effecter_field),2)
            else
                local behind_count = range / 2 - 1
                local after_count = range / 2
                self.road_rang_nodes = DriveMapManager.ShowMapRangNode(
                    DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id - behind_count),
                    DriveMapManager.ServerPosConversionMapPos(self.road_barrier_data.road_id + after_count),2)
            end
        end
    end
    -- for i = 0,5 do 
    --     seq:AppendInterval(1/5)
    --     seq:AppendCallback(function()
    --         --按间隔生成（最开始的两格特殊处理）
    --         for j = 1,2 do 
    --             local dis = 1
    --             if i == 0 then
    --                 dis = 0.4
    --             end
    --             local data = DriveMapManager.GetEvenlyDistributedVector(parent_position,dis)
    --             local position
    --             local vec_list = {}
    --             if i ~= 0 then
    --                 if j == 1 then 
    --                     vec_list = data.front_vec_list
    --                 else
    --                     vec_list = data.back_vec_list
    --                 end
    --             end
    --             position = vec_list[i + 2]
    --             local euler_z
    --             if i == 0 then
    --                 euler_z = DriveMapManager.CarMapEulerZ(parent_position) + ((j - 1) * 180)
    --                 position = tls.pAdd(parent_position, tls.pMul(tls.pForAngle(euler_z * math.pi / 180),dis))
    --             else
    --                 euler_z = DriveMapManager.CarMapEulerZ(position) + ((j - 1) * 180)
    --             end
    --             local obj = newObject("RoadBarrierDHQ_tag",GameObject.Find("3DNode/map_node").transform)
    --             self.tag_pres = self.tag_pres or {}
    --             self.tag_pres[#self.tag_pres+1] = obj
    --             obj.transform.position = position
    --             obj.transform.localRotation = Quaternion:SetEuler(0,0,euler_z)
    --             --如果超出范围直接关掉
    --             local obj_road_id = DriveMapManager.MapVectorConversionRoadId(obj.transform.position,true)
    --             local spac_1 = math.abs((obj_road_id - self.road_barrier_data.road_id) % math.floor(DriveMapManager.map_count))
    --             local spac = math.min(spac_1,DriveMapManager.map_count - spac_1)
    --             if  spac > range then
    --                 obj.gameObject:SetActive(false)
    --             end
    --         end
    --     end)
    -- end
end

function M:SetEnemyMeStyle()
    local mat = GetMaterial("InLightOutLine")
    if DriveModel.CheckOwnerIsMe(self.road_barrier_data) then
        mat = GetMaterial("InLightOutLineGreen")
    else
        mat = GetMaterial("InLightOutLineRed")
    end
end

function M:MyRefresh(data)
	
end

function M:Refresh()
end

function M:PlayOnBoom(cbk)
    self.transform:Find("luzhang"):GetComponent("Animator").enabled = false
    self.hong_img.gameObject:SetActive(true)
    self.item_img.material = nil
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

function M:on_small_youmen_small_acc_create(data)
    if data.car_no == self.road_barrier_data.owner_id then
        -- self:PlayRangeTip()
    end
end

function M:PlayRangeTip()
    DriveMapManager.ActiveAllSmallAcc(false)
    for i = 0, range do 
        for j = 1,2 do 
            local road_id = self.road_barrier_data.road_id + i * (j == 1 and 1 or -1)
            DriveMapManager.ActiveSmallAcc(road_id,true)
        end
    end
end

function M:on_car_move_slide(data)
    if DriveCarManager.GetCarByNo(data.car_no).car_data.seat_num == self.road_barrier_data.owner_id then
        -- self:PlayRangeTip()
    end
end

function M:CloseSmalAcc()
    DriveMapManager.ActiveAllSmallAcc(false)
end