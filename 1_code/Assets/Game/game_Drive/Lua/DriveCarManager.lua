-- 创建时间:2020-10-19
DriveCarManager = {}
local M = DriveCarManager
ext_require("Game.game_Drive.Lua.DriveCar")
ext_require("Game.game_Drive.Lua.DriveCarTank")
ext_require("Game.game_Drive.Lua.DriveCarFaleli")
ext_require("Game.game_Drive.Lua.DriveCarPTG")
ext_require("Game.game_Drive.Lua.DriveCarLandmine")

M.dotween_key = "DriveCarManager"
local this
local listener

local function AddListener()
    for msg,cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if listener then
        for msg,cbk in pairs(listener) do
            Event.RemoveListener(msg, cbk)
        end
    end
    listener=nil
end
local function MakeListener()
    listener = {}
    listener["play_process_obj_car_move_helper_youmen"] = this.on_play_process_obj_car_move_by_youmen
    listener["play_process_obj_car_move_helper_sprint"] = this.on_play_process_obj_car_move_by_sprint
    listener["play_process_obj_car_stop_helper"] = this.on_play_process_obj_car_stop_helper
    listener["car_move_end"] = this.on_car_move_end
end

function M.Init()
    if not this then
        M.Exit()

        this = DriveCarManager

        this.m_data = {}
        this.cars = {}
        MakeListener()
        AddListener()
        M.InitUIConfig()
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

function M.Exit()
    DOTweenManager.KillAndRemoveTween(M.dotween_key)
    if this then
        this.ClearCar()
    end
    RemoveLister()
    this = nil
end

function M.RefreshCarData(car_data)
    if not car_data or not next(car_data) then return end
    for k_,v_ in pairs(car_data)do
        for k,v in pairs(v_) do
            if this.cars and this.cars[v.seat_num] and this.cars[v.seat_num][v.car_id] then
                this.cars[v.seat_num][v.car_id]:RefreshData(v)
            end
        end
    end
end

function M.RefreshCar()
    if not DriveModel.data or not next(DriveModel.data) then return end
    local car_data = DriveModel.data.car_data
    if not car_data or not next(car_data) then return end
    for k_,v_ in pairs(car_data)do
        for k,v in pairs(v_) do
            if this.cars and this.cars[v.seat_num] and this.cars[v.seat_num][v.car_id] then
                this.cars[v.seat_num][v.car_id]:Refresh(v)
            else
                M.AddCar(v)
            end
        end
    end

    M.SetEnemyMe()
end

function M.CreateCar(car_data)
    for k,v in pairs(car_data or {}) do
        for k1,v1 in pairs(v) do
            this.AddCar(v1)
        end
    end

    M.SetEnemyMe()
end

function M.AddCar(car_data)
    this.cars[car_data.seat_num] = this.cars[car_data.seat_num] or {}  
    this.cars[car_data.seat_num][car_data.car_id] = DriveCar.Create(car_data)
    return this.cars[car_data.seat_num][car_data.car_id]
end

function M.RemoveCar(car_data)
    local car = M.GetCar(car_data)
    if not car then return end
    local seat_num = car.car_data.seat_num
    local car_id = car.car_data.car_id
    car:MyExit()
    this.cars[seat_num][car_id] = nil
    car = nil
    seat_num = nil
    car_id = nil
end

function M.ClearCar()
    if this.cars and next(this.cars) then
        for k_,v_ in pairs(this.cars)do
            for k,v in pairs(v_) do
                v:MyExit()
            end
        end
    end
    this.cars = {}
end

function M.GetAllCar()
    return this.cars
end

function M.GetCar(data)
    if data.car_no then
        local car = M.GetCarByNo(data.car_no)
        return car
    end

    if data.seat_num and data.car_id then
        local car = M.GetCarBySeatNumAndCarID(data.seat_num,data.car_id)
        return car
    end
end

function M.GetCarData(data)
    if data.car_no then
        local car = M.GetCarByNo(data.car_no)
        if car then
            return car.car_data
        end
    end

    if data.seat_num and data.car_id then
        local car = M.GetCarBySeatNumAndCarID(data.seat_num,data.car_id)
        if car then
            return car.car_data
        end
    end
end

function M.GetCarByNo(no)
    for seat_num,v in pairs(this.cars) do
        for car_id,car in pairs(v) do
            if car.car_data.car_no == no then
                return car
            end    
        end
    end
end

function M.GetCarBySeatNumAndCarID(seat_num,car_id)
    if this.cars and this.cars[seat_num] and this.cars[seat_num][car_id] then
        return this.cars[seat_num][car_id]
    end
end

function M.GetCarBySeat(seat_num)    
    if seat_num and this.cars and this.cars[seat_num] then
        return this.cars[seat_num]
    end
end

function M.MoveCar(data,funcs)
    dump(data,"<color=yellow>车辆开始移动</color>")
    local car = M.GetCar(data.obj_car_move)
    if car then
        return car:drive_car_move(data,funcs)
    end
end

function M.StopCar(data)
    dump(data,"<color=yellow>车辆开始停止</color>")
    local car = M.GetCar(data)
    if car then
        return car:drive_car_stop(data.pos)
    end
end

function M.GetMoveCarTime(data)
    dump(data,"<color=yellow>车辆移动计算</color>")
    local car = M.GetCar(data.obj_car_move)
    if car then
        return car:get_drive_car_move_point_time(data)
    end
end

function M.GetCarMoveTime(process_data)
    local process_data = process_data or DriveModel.data.process_data
    local t = 0
    for i,v in ipairs(process_data) do
        if v.obj_car_move then
            local time_point = M.GetMoveCarTime(v)
            t = t + time_point[#time_point].time
        end
    end
    return t
end

local small_acc_num = 5
local small_acc_delta_t = 0.14
local small_acc_tail = 0.5
local big_acc_tail = 0.5

function M.GetAccTime(data)
    if not data.obj_car_move then return 0 end
    local t = 0
    if data.obj_car_move.type == "small_youmen" then
        t = small_acc_num * small_acc_delta_t + small_acc_tail
    elseif data.obj_car_move.type == "big_youmen" then
        t = big_acc_tail
    end
    return t
end

function M.on_play_process_obj_car_move_by_youmen(data,funcs)
    local obj_car_move = data[data.key]
    local car = M.GetCar(obj_car_move)
    if not car then 
        dump(data,"<color=red>车辆获取失败，数据错误</color>")
        return 
    end

    if not (obj_car_move.type == "small_youmen" or obj_car_move.type == "big_youmen" or obj_car_move.type == "ptg_big_youmen" or obj_car_move.type == "ptg_attack" or obj_car_move.type == "dlc_anzhuang_move") then
        return
    end

    local seq = DoTweenSequence.Create({dotweenLayerKey = M.dotween_key})
    if obj_car_move.type == "small_youmen" then
        --效果
		AudioManager.PlaySound(audio_config.drive.com_main_map_shifangxiaoyoumen.audio_name)
        local road_id = DriveMapManager.ServerPosConversionMapPos(DriveMapManager.ServerPosConversionRoadId(obj_car_move.pos))
        local is_reverse = this.GetCarByNo(obj_car_move.car_no).reverse_flag
        if DriveMapManager.small_acc_rang_node_map and next(DriveMapManager.small_acc_rang_node_map) then
            for k,v in pairs(DriveMapManager.small_acc_rang_node_map) do 
                destroy(v.gameObject)
            end
            DriveMapManager.small_acc_rang_node_map = nil
        end
        if is_reverse then
            DriveMapManager.small_acc_rang_node_map = DriveMapManager.ShowMapRangNode(road_id - small_acc_num,road_id - 1,2)
        else
            DriveMapManager.small_acc_rang_node_map = DriveMapManager.ShowMapRangNode(road_id + 1,road_id + small_acc_num,2)
        end
        -- for k,v in pairs(DriveMapManager.small_acc_rang_node_map) do 
        --     v.gameObject:SetActive(false)
        -- end
        for i=1,small_acc_num do
            seq:AppendCallback(function()
                -- local cur_road_id = DriveMapManager.ServerPosConversionRoadId(road_id + (is_reverse and -i or i))
                -- DriveMapManager.small_acc_rang_node_map[cur_road_id].gameObject:SetActive(true)
                Event.Brocast("small_youmen_small_acc_create",{car_no = car.car_data.car_no})
            end)
            seq:AppendInterval(small_acc_delta_t)
        end
        seq:AppendCallback(function()
            car:ActiveAccTail(obj_car_move.type,obj_car_move.move_nums,true)
        end)
        seq:AppendInterval(small_acc_tail)
    elseif obj_car_move.type == "big_youmen" then
		AudioManager.PlaySound(audio_config.drive.com_main_map_shifangdayoumen.audio_name)
        seq:AppendCallback(function()
            car:ActiveAccTail(obj_car_move.type,obj_car_move.move_nums,true)
        end)
        seq:AppendInterval(big_acc_tail)
    end

    seq:AppendCallback(function()
        if obj_car_move.type == "small_youmen" or obj_car_move.type == "big_youmen" or obj_car_move.type == "ptg_big_youmen" or obj_car_move.type == "ptg_attack" or obj_car_move_type == "dlc_anzhuang_move" then
            M.MoveCar(data,funcs)
            Event.Brocast("process_play_next")
        end
    end)
end

function M.on_play_process_obj_car_move_by_sprint(data,funcs)
    M.MoveCar(data,funcs)
end

function M.on_play_process_obj_car_stop_helper(data)
    DriveCarManager.StopCar(data)
end

function M.on_car_move_end(data)
    local car = M.GetCar(data)
    local obj_car_move = data.obj_car_move
    if obj_car_move.type == "small_youmen" then
        --效果
        local end_pos = obj_car_move.pos + obj_car_move.move_nums
        -- DriveMapManager.ActiveAllSmallAcc(false)
        -- DriveMapManager.ActiveSmallAcc(end_pos,true)
        if DriveMapManager.small_acc_rang_node_map and next(DriveMapManager.small_acc_rang_node_map) then
            for k,v in pairs(DriveMapManager.small_acc_rang_node_map) do 
                destroy(v.gameObject)
            end
            DriveMapManager.small_acc_rang_node_map = nil
        end

        local seq = DoTweenSequence.Create({dotweenLayerKey = M.dotween_key})
        seq:AppendInterval(2)
        seq:AppendCallback(function()
            -- DriveMapManager.ActiveSmallAcc(end_pos,false)
        end)
    elseif obj_car_move.type == "big_youmen" then
        -- seq:AppendCallback(function()
            
        -- end)
        -- seq:AppendInterval(2)
    end
end

function M.GetVirtualCircle(data)
    local virtual_circle = 0
    local _data = {}
    if data and data.is_start then
        _data = DriveModel.data.start_data
    else
        _data = DriveModel.data.end_data
    end

    -- if not _data then
    --     _data = DriveModel.data.end_data
    -- end

    if not data then
        for k,v in pairs(_data.car_data) do
            if v.seat_num == DriveModel.data.seat_num then
                virtual_circle = v.virtual_circle
                return virtual_circle
            end
        end
    end

    if data.car_no then
        for k,v in pairs(_data.car_data) do
            if v.car_no == data.car_no then
                virtual_circle = v.virtual_circle
                return virtual_circle
            end
        end

    end

    if data.seat_num and data.car_id then
        for k,v in pairs(_data.car_data) do
            if v.seat_num == data.seat_num and v.car_id == data.car_id then
                virtual_circle = v.virtual_circle
                return virtual_circle
            end
        end
    end

    if data.seat_num and not data.car_id then
        for k,v in pairs(_data.car_data) do
            if v.seat_num == data.seat_num then
                virtual_circle = v.virtual_circle
                return virtual_circle
            end
        end
    end

    if not data.seat_num then
        for k,v in pairs(_data.car_data) do
            if v.seat_num == DriveModel.data.seat_num then
                virtual_circle = v.virtual_circle
                return virtual_circle
            end
        end
    end
    return virtual_circle
end

function M.ClearCarArrow()
    if this.cars and next(this.cars) then
        for k_,v_ in pairs(this.cars)do
            for k,v in pairs(v_) do
                v:CloseRoundArrow()
            end
        end
    end
end


function M.SetEnemyMe()
    --同一辆车有多少辆
    local car2num = {}
    if not this.cars or not next(this.cars) then return end
    for seat_num,v_ in pairs(this.cars)do
        for k,v in pairs(v_) do
            car2num[v.car_data.id] = car2num[v.car_data.id] or {}
            car2num[v.car_data.id].num = car2num[v.car_data.id].num or 0
            car2num[v.car_data.id].num = car2num[v.car_data.id].num + 1
            car2num[v.car_data.id].data =  car2num[v.car_data.id].data or {}
            car2num[v.car_data.id].data[#car2num[v.car_data.id].data + 1] = v
        end
    end
    local my_id = DriveModel.data.seat_num
    local set_func = function(B,Color)
        for i = 0,B.Length - 1 do
            --if  B[i].material.sha
            for j = 0,B[i].materials.Length - 1 do
                if B[i].materials[j].shader.name == "MyUnlit/CartoonShading" then
                    B[i].materials[j]:SetFloat("_Outline",0.009)
                    B[i].materials[j]:SetColor("_OutlineColor",Color)
                end
            end
        end
    end
    for k,v in pairs(car2num) do
        if v.num >= 2 then
            for k1,v1 in pairs(v.data) do
                if v1.car_data.seat_num == my_id then
                    local gameobject = v1.gameObject
                    local Renderer_Commonpent = gameobject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
                    set_func(Renderer_Commonpent,Color.New(0,255,0,255))
                else
                    local gameobject = v1.gameObject
                    local Renderer_Commonpent = gameobject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
                    set_func(Renderer_Commonpent,Color.New(255,0,0,255))
                end
            end
        end
    end
end