-- 创建时间:2021-03-17
-- 技能动画效果类：强行追尾
local basefunc = require "Game/Common/basefunc"

SkillPTGBig = basefunc.class(SkillBase)

--车辆移动格子数的随机区间
local anim_car_move_range = {0,22}
--车辆冲撞格子数的随机区间
local anim_car_crash_range = {3,16}

local C = SkillPTGBig
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillPTGBig.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd") then
            return true
        end
    end
end

function C:OnTriggerBefore()
    -- self.skill_anim = newObject("PTGBigSkillAnim",GameObject.Find("Canvas/LayerLv3").transform)
    -- local seq = DoTweenSequence.Create()
    -- seq:AppendInterval(2)
    -- seq:AppendCallback(function()
    --     self.skill_anim.transform:Find("guochang_baolichedui").gameObject:SetActive(false)
        
    --     self:OnTriggerMain()
    -- end)
    DriveAnimManager.PlayBigSkillNameFx("com_img_blcd_map3",self.launcher_car:GetCenterPosition(),function()
        -- set_order_in_layer(self.launcher_car.car,2)
        AudioManager.PlayOldBGM()
        self:OnTriggerMain()
    end)
end

function C:OnTriggerMain()
    --调整车辆和赛道的层级
    -- DriveMapManager.map_prefab.bg_img.transform:SetParent(GameObject.Find("Canvas/LayerLv3").transform)
    for seat_num,cars in ipairs(DriveCarManager.cars) do 
        for id ,car in ipairs(cars) do 
            car:SetLayer(3)
        end
    end
    self.obj_datas = self:GetObjs()
    local seq = DoTweenSequence.Create()
    for i,v in ipairs(self.obj_datas) do
        math.randomseed(self.skill_data.process_no .. i)
        --随机初始位置 小于effecter_car的pos
        local rdn_check_func = function() 
            --随机数规则 不能重合在一起
            local target_move_num = 0
            local target_crash_num = math.random(anim_car_crash_range[1],anim_car_crash_range[2])
            local start_pos = self.effecter_car.car_data.pos - target_move_num - target_crash_num --就算是负数也没关系
            local loop_count = 0
            local check_func
            check_func = function()
                loop_count = loop_count + 1
                if loop_count >= DriveMapManager.map_count then return end

                if self.obj_datas and next(self.obj_datas) then
                    for _k,_v in ipairs(self.obj_datas) do
                        if _v.rdn_data then
                            local v_move_end_pos = _v.rdn_data.start_pos + _v.rdn_data.target_move_num
                            if (_v.rdn_data.start_pos - start_pos) % DriveMapManager.map_count == 0 or (start_pos - self.launcher_car.car_data.pos) % DriveMapManager.map_count == 0 then
                                    target_crash_num = target_crash_num - 1
                                    if self.launcher_car.reverse_flag then
                                        start_pos = self.effecter_car.car_data.pos + target_move_num + target_crash_num
                                    else
                                        start_pos = self.effecter_car.car_data.pos - target_move_num - target_crash_num
                                    end
                                    check_func()
                            elseif ((start_pos + target_move_num) - v_move_end_pos) % DriveMapManager.map_count == 0 or ((start_pos + target_move_num) - self.launcher_car.car_data.pos) % DriveMapManager.map_count == 0 then
                                target_crash_num = target_crash_num + 1
                                if self.launcher_car.reverse_flag then
                                    start_pos = self.effecter_car.car_data.pos + target_move_num + target_crash_num
                                else
                                    start_pos = self.effecter_car.car_data.pos - target_move_num - target_crash_num
                                end
                                check_func()
                            end
                        end
                    end
                end
            end
            check_func()
            return target_move_num,target_crash_num,start_pos
        end
        local target_move_num,target_crash_num,start_pos = rdn_check_func()
        v.rdn_data = {
            target_move_num = target_move_num,
            target_crash_num = target_crash_num,
            start_pos = start_pos
        }
    end
    table.sort(self.obj_datas,function(a,b)
        if self.launcher_car.reverse_flag then
            return a.rdn_data.target_crash_num > b.rdn_data.target_crash_num
        else
            return a.rdn_data.target_crash_num < b.rdn_data.target_crash_num
        end
    end)
    --创建特效车辆
    for i,v in ipairs(self.obj_datas) do
        seq:AppendCallback(function()
            local target_move_num = v.rdn_data.target_move_num
            local target_crash_num = v.rdn_data.target_crash_num
            local start_pos = v.rdn_data.start_pos
            --如果这次攻击miss了那么表现就不一样
            local miss_flag = false
            if v.obj_car_modify_property.modify_value == 0 then
                miss_flag = true
            end
            local fx_car_data = basefunc.deepcopy(self.launcher_car.car_data)
            fx_car_data.pos = start_pos
            AudioManager.PlaySound(audio_config.drive.com_main_map_zhaohuan.audio_name)
            local fx_car = DriveCar.Create(fx_car_data)
            if self.launcher_car.reverse_flag then
                fx_car.reverse_flag = self.launcher_car.reverse_flag
                fx_car:RefreshTransform()
            end
            fx_car:SetLayer(3)
            self.fx_car = self.fx_car or {}
            self.fx_car[#self.fx_car+1] = {
                car = fx_car,
                obj_data = v,
                move_num = target_move_num,
                crash_move_num = target_crash_num,
                miss_flag = miss_flag,
                transfer_fx = newObject("ptg_chuansong",fx_car.transform),
                start_pos = start_pos
            }
            
        end)
        seq:AppendInterval(0.5)
    end
    for id,data in ipairs(self.obj_datas) do
        seq:AppendCallback(function()
        --特效车辆大油门移动
        -- for id,v in ipairs(self.fx_car) do
        --     if v.transfer_fx then
        --         destroy(v.transfer_fx)
        --     end
        --     local fx_car = v.car
        --     local move_fx = newObject("ptg_bigchongji",fx_car.car.transform)
        --     v.move_fx = move_fx
        --     local obj_data = v.obj_data
        --     local move_num = v.move_num
        --     local big_youmen_move_data = {
        --         key = "obj_car_move",
        --         obj_car_move = {
        --             move_nums = move_num,
        --             pos = fx_car.car_data.pos,
        --             random_stop_speed_num = 0,
        --             type = "big_youmen"
        --         }
        --     }
        --     local pre_state = 1
        --     local end_cbk = function()
        --         local crash_fx
        --         local end_cbk_seq = DoTweenSequence.Create()
        --         if not v.miss_flag then
        --             crash_fx = newObject("ptg_bigzhuangji",self.effecter_car.car.transform)
        --             end_cbk_seq:AppendCallback(function()
        --                 self:PlayDamageFx(obj_data.obj_car_modify_property)
        --                 self.effecter_car:PlayOnAttack(obj_data.obj_car_modify_property.modify_value)
        --             end)
        --         end
        --         end_cbk_seq:AppendCallback(function()
        --             fx_car:MyExit()
        --             self:PlayObjData(v.obj_data)
        --             self:OnFxCarMoveEnd(id)
        --         end)
        --         if crash_fx and IsEquals(crash_fx) then
        --             end_cbk_seq:AppendInterval(1)
        --             end_cbk_seq:AppendCallback(function()
        --                 destroy(crash_fx)
        --             end)
        --         end
        --     end
        --     fx_car.DriveCarPTG:MoveToPosAnim(nil,big_youmen_move_data,nil,function(data)
        --         --重写本次移动的move_call方法
        --         if pre_state ~= 5 and data.cur_state == 5 then
        --             --在这里直接停止移动
        --             if  fx_car.move_timer then
        --                 fx_car.move_timer:Stop()
        --             end
        --             fx_car.move_timer = nil
        --             if v.miss_flag then
        --                 destroy(v.move_fx)
        --                 local end_seq = DoTweenSequence.Create()
        --                 -- end_seq:Append(fx_car.transform:GetComponent("CanvasGroup"):DOFade(0,2))
        --                 end_seq:AppendInterval(2)
        --                 end_seq:AppendCallback(function()
        --                     if  fx_car.move_timer then
        --                         fx_car.move_timer:Stop()
        --                     end
        --                     fx_car.move_timer = nil
        --                     end_cbk()
        --                 end)
        --             else
        --                 destroy(v.move_fx)
        --                 v.move_fx = nil
        --                 fx_car.DriveCarPTG:PlayBurnOut(function()
        --                     fx_car.DriveCarPTG:CreateShaoTaiPre(true)
        --                 end,function()
        --                     v.move_fx = newObject("ptg_bigchongji",fx_car.car.transform)

        --                     -- local crash_move_data = {
        --                     --     key = "obj_car_move",
        --                     --     obj_car_move = {
        --                     --         move_nums = v.crash_move_num,
        --                     --         pos = fx_car.car_data.pos,
        --                     --         random_stop_speed_num = 0,
        --                     --         type = "ptg_crash",
        --                     --         type_id = 7,
        --                     --     }
        --                     -- }
        --                     -- fx_car.DriveCarPTG:MoveToPosAnim(nil,crash_move_data,function()
        --                     --     destroy(v.move_fx)
        --                     --     if end_cbk then end_cbk() end
        --                     -- end)
        --                     fx_car.car_data.pos = v.start_pos + v.move_num
        --                     fx_car.DriveCarPTG:PlayCrash(self.effecter_car.car_data.pos,function()
        --                         destroy(v.move_fx)
        --                         if end_cbk then end_cbk() end
        --                     end)
                            
        --                 end)
        --             end
        --         end
        --         pre_state = data.cur_state
        --     end)
                    local v = self.fx_car[id]
                    local fx_car = v.car
                    local obj_data = v.obj_data
                    local move_num = v.move_num
                    local end_cbk = function()
                        local crash_fx
                        local end_cbk_seq = DoTweenSequence.Create()
                        if not v.miss_flag then
                            crash_fx = newObject("ZWC_baozha",self.effecter_car.car.transform)
                            end_cbk_seq:AppendCallback(function()
                                self:PlayDamageFx(obj_data.obj_car_modify_property)
                                self.effecter_car:PlayOnAttack(obj_data.obj_car_modify_property.modify_value)
                            end)
                        end
                        end_cbk_seq:AppendCallback(function()
                            fx_car:MyExit()
                            self:PlayObjData(v.obj_data)
                            self:OnFxCarMoveEnd(id)
                        end)
                        if crash_fx and IsEquals(crash_fx) then
                            end_cbk_seq:AppendInterval(1)
                            end_cbk_seq:AppendCallback(function()
                                destroy(crash_fx)
                            end)
                        end
                    end
                    destroy(v.move_fx)
                    v.move_fx = nil
                    fx_car.DriveCarPTG:PlayBurnOut(function()
                        AudioManager.PlaySound(audio_config.drive.com_main_map_zhaohuanzhuangjizhong.audio_name)
                        fx_car.DriveCarPTG:CreateShaoTaiPre(true)
                    end,function()
                        v.move_fx = newObject("ZWC_chongchi",fx_car.car.transform)

                        fx_car.DriveCarPTG:PlayCrash(self.effecter_car.car_data.pos,function()
                            destroy(v.move_fx)
                            AudioManager.PlaySound(audio_config.drive.com_main_map_zhaohuanzhuangji.audio_name)
                            if end_cbk then end_cbk() end
                        end)
                        
                    end)
                end)
            seq:AppendInterval(0.3)
    end
end

function C:OnFxCarMoveEnd(id)
    self.fx_car[id] = nil
    for k,v in pairs(self.fx_car) do
        if v then return end
    end
    self:OnTriggerEnd()
end

function C:OnTriggerEnd()
    if self.skill_anim then
        destroy(self.skill_anim)
    end
    --调整车辆和赛道的层级
    -- DriveMapManager.map_prefab.bg_img.transform:SetParent(DriveMapManager.map_prefab.transform)
    -- DriveMapManager.map_prefab.bg_img.transform:SetSiblingIndex(0)
    for seat_num,cars in ipairs(DriveCarManager.cars) do 
        for id ,car in ipairs(cars) do 
            car:SetLayer(1)
        end
    end
    self:OnActEnd()
end