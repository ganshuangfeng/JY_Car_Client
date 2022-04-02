local basefunc = require "Game/Common/basefunc"

BuffReverse = basefunc.class(BuffBase)

local M = BuffReverse
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffReverse.super.ctor(self,buff_data)
end

--创建回调
function M:OnCreate()
    dump(self.buff_data,"<color=red>反转buff创建 buff_data</color>")
    if self.buff_data.owner_type == 2 then
       self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    end
    self.car.reverse_flag = true
    self.car:RefreshTransform()
    self:OnTrigger()
end

--移除回调
function M:OnDead()
    dump(self.buff_data,"<color=red>反转技能移除 buff_data</color>")
    if self.car then
        self.car.reverse_flag = false
        self.car:RefreshTransform()
    end
    if IsEquals(DriveMapManager.reverse_arrow) then
        destroy(DriveMapManager.reverse_arrow)
        DriveMapManager.reverse_arrow = nil
    end
    self:PlayObjs()
    self:OnActEnd()
end

function M:OnRefresh()
    if not self.car then
        if self.buff_data.owner_type == 2 then
            self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
        end
    end
    if not DriveMapManager.reverse_arrow then
        DriveMapManager.reverse_arrow = newObject("fangxiangbiaoshi",GameObject.Find("3DNode/map_node").transform)
    end
     self.car.reverse_flag = true
     self.car:RefreshTransform()
end

function M:MyExitSubclass()
    if IsEquals(DriveMapManager.reverse_arrow) then
        destroy(DriveMapManager.reverse_arrow)
        DriveMapManager.reverse_arrow = nil
    end
end