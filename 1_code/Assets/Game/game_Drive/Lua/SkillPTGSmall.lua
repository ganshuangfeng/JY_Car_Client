-- 创建时间:2021-03-17
-- 技能动画效果类：强行追尾
local basefunc = require "Game/Common/basefunc"

SkillPTGSmall = basefunc.class(SkillBase)

local C = SkillPTGSmall
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillPTGSmall.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if (v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd")) 
            or v.obj_car_move or v.obj_car_transfer  then
            return true
        end
    end
end

function C:OnTriggerBefore()
    self.obj_datas = self:GetObjs()
    --数据先处理好
    self.obj_car_transfers = {}
    self.obj_car_modify_propertys = {}
    for k,v in ipairs(self.obj_datas) do
        if v.obj_car_move then
            --大油门移动数据
            if v.obj_car_move.type == "ptg_big_youmen" then
                self.ptg_big_youmen = v
            elseif v.obj_car_move.type == "ptg_attack" then
                self.ptg_attack = v
            end
            DriveLogicProcess.set_process_data_use(v.process_no)
        end
        if v.obj_car_transfer then
            --碰撞后车的位置移动数据
            self.obj_car_transfers = self.obj_car_transfers or {}
            self.obj_car_transfers[v.obj_car_transfer.car_no] = v
            DriveLogicProcess.set_process_data_use(v.process_no)
        end
        if v.obj_car_modify_property then
            self.obj_car_modify_propertys = self.obj_car_modify_propertys or {}
            self.obj_car_modify_propertys[#self.obj_car_modify_propertys + 1] = v
            -- DriveLogicProcess.set_process_data_use(v.process_no)
        end
    end
    if self.ptg_big_youmen then
        --先进行移动后触发技能
        -- self.launcher_car:drive_car_move(self.ptg_big_youmen,{end_call = function()
        --     self.launcher_car.DriveCarPTG:CloseEffectRange()
        --     self.launcher_car.DriveCarPTG.lock_show_range = true
        --     self.launcher_car.DriveCarPTG:PlayBurnOut(function()
        --         self.launcher_car.DriveCarPTG:CreateShaoTaiPre()
        --     end,function()
        --         self:OnTriggerMain()
        --     end)
        -- end},nil,true)
        self.launcher_car:drive_car_move(self.ptg_big_youmen,{end_call = function()
            local seq = DoTweenSequence.Create()
            seq:AppendInterval(0.1)
            seq:AppendCallback(function()
                self:OnTriggerMain()
            end)
        end},nil,true)
    else
        self.launcher_car.DriveCarPTG:PlayBurnOut(function()
            self.launcher_car.DriveCarPTG:CreateShaoTaiPre()
        end,function()
            self:OnTriggerMain()
        end,nil,true)
    end
end

function C:OnTriggerMain()
    local ptg_chongji_pre = newObject("ZWC_chongchi",self.launcher_car.car.transform)
    self.launcher_car.DriveCarPTG:MoveToPosAnim(self.ptg_attack.obj_car_move.pos + self.ptg_attack.obj_car_move.move_nums,nil,function()
        self:OnTriggerEnd()
        destroy(ptg_chongji_pre)
    end)
end

function C:OnTriggerEnd()
    self.obj_datas = self:GetObjs()
    local boom_pre
    if self.obj_car_modify_propertys and next(self.obj_car_modify_propertys) then
        boom_pre = newObject("ZWC_baozha",GameObject.Find("3DNode").transform)
        boom_pre.transform.position = self.effecter_car.transform.position
        DriveAnimManager.PlayShakeScreen(DriveModel.camera3dParent,0.3)
        local seq = DoTweenSequence.Create()
        for k,obj_car_modify_property in ipairs(self.obj_car_modify_propertys) do
            seq:AppendCallback(function()
                self:PlayDamageFx(obj_car_modify_property.obj_car_modify_property)
                self.effecter_car:PlayOnAttack(obj_car_modify_property.obj_car_modify_property.modify_value)
                self:PlayObjData(obj_car_modify_property)
            end)
            seq:AppendInterval(0.3)
        end
    end
    if self.obj_car_transfers and next(self.obj_car_transfers) then
        for car_no,data in pairs(self.obj_car_transfers) do 
            local target_car = DriveCarManager.GetCarByNo(car_no)
            target_car.car_data.pos = data.obj_car_transfer.end_pos
            -- target_car:RefreshTransform()
        end
    end
    local seq = DoTweenSequence.Create()
    seq:AppendCallback(function()
        self.launcher_car.DriveCarPTG:CloseShaoTaiPre()
        self.launcher_car.car_data.pos = self.ptg_attack.obj_car_move.pos + self.ptg_attack.obj_car_move.move_nums
        if self.obj_car_modify_propertys and next(self.obj_car_modify_propertys) then
            local target_pos = DriveMapManager.ServerPosConversionMapVector(self.effecter_car.car_data.pos)
            AudioManager.PlaySound(audio_config.drive.com_main_map_zhuangji.audio_name)
            DriveAnimManager.PlayCrashFly(self.effecter_car,target_pos,function()
                self.launcher_car:RefreshTransform()
                self.effecter_car:RefreshTransform()
            end)
        else
            self.launcher_car:RefreshTransform()
        end
        DriveLogicProcess.set_car_move_end()
    end)
    if self.obj_car_modify_propertys then
        seq:AppendInterval(2)
    else
        seq:AppendInterval(0.2)
    end
    seq:AppendCallback(function()
        if IsEquals(boom_pre) then
            destroy(boom_pre)
        end
        Event.Brocast("ptg_skill_end",{car_data = self.launcher_car.car_data})
        self:OnActEnd()
    end)
end

function C:RefreshSubclass()
    if self.skill_data then
        local car = DriveCarManager.GetCarByNo(self.skill_data.owner_id)
        if car then
            car.DriveCarPTG:SetAttackRadius(tonumber(self.skill_data.attack_radius))
        end
    end
end