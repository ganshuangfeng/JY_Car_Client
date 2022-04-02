ObjHelper = {}
local M = ObjHelper

local this
local listener

local function MakeListener()
    listener = {}
    listener["play_process_obj_car_move"] = this.on_play_process_obj_car_move --车的移动
    listener["play_process_obj_car_stop"] = this.on_play_process_obj_car_stop --车停止
    listener["play_process_obj_car_transfer"] = this.on_play_process_obj_car_transfer --车传送
    listener["play_process_obj_car_exchange_pos"] = this.on_play_process_obj_car_exchange_pos --车 交换位置
    listener["play_process_obj_car_modify_property"] = this.on_play_process_obj_car_modify_property --车修改属性
    listener["play_process_obj_player_modify_property"] = this.on_play_process_obj_player_modify_property --玩家的 属性修改
end

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

function M.Init()
    if not this then
        M.Exit()
        this = ObjHelper
        MakeListener()
        AddListener()
    end
end

function M.Exit()
    if this then
        RemoveLister()
    end
end

function M.CheckIsObj(process_data)
    local key = process_data.key
    if not key then return end
    if string.sub(key,1,4) == "obj_" then
        return true
    end
end

--车辆移动
function M.on_play_process_obj_car_move(data,funcs)
    dump(data,"<color=red>车辆移动</color>")
    if not data.obj_car_move then return end
    local obj_car_move = data[data.key]
    if obj_car_move.type == "big_youmen" or obj_car_move.type == "small_youmen" then
        --油门
        Event.Brocast("play_process_obj_car_move_helper_youmen",data,funcs)
    else
        --冲刺
        Event.Brocast("play_process_obj_car_move_helper_sprint",data,funcs)
    end
end

--车停止
function M.on_play_process_obj_car_stop(data)
    dump(data,"<color=red>车停止</color>")
    Event.Brocast("play_process_obj_car_stop_helper",data)
end

--车传送
function M.on_play_process_obj_car_transfer(data)
    dump(data,"<color=red>车传送</color>")
    --通用的传送效果
    local effecter_car = DriveCarManager.GetCarByNo(data[data.key].car_no)
    local target_pos = DriveMapManager.ServerPosConversionMapVector(data[data.key].end_pos)
    local fx_pre_1 = newObject("chuansong",GameObject.Find("Canvas/LayerLv3").transform)
    local fx_pre_2 = newObject("chuansong",GameObject.Find("Canvas/LayerLv3").transform)
    fx_pre_1.transform.position = effecter_car:GetUICenterPosition()
    fx_pre_2.transform.position = DriveModel.Get3DTo2DPoint(target_pos)
    fx_pre_2.transform.localRotation = Quaternion:SetEuler(0,0,180)
    AudioManager.PlaySound(audio_config.drive.com_main_map_chuansong.audio_name)
    local seq = DoTweenSequence.Create()
    seq:Append(effecter_car.transform:GetComponent("CanvasGroup"):DOFade(0,0.8):OnStart(
        function ()
            DOFadeSpriteRender(effecter_car.transform,0,0.8)
        end
    ))
    seq:AppendCallback(function() 
        effecter_car:TransferPosition(data[data.key].end_pos)
    end)
    seq:Append(effecter_car.transform:GetComponent("CanvasGroup"):DOFade(1,1):OnStart(
        function (  )
            DOFadeSpriteRender(effecter_car.transform,1,1)
        end
    ))
    seq:AppendCallback(function() 
        destroy(fx_pre_1)
        destroy(fx_pre_2)
        DriveLogicProcess.set_process_data_use(data.process_no)
        Event.Brocast("process_play_next")
    end)
end

--车交换位置
function M.on_play_process_obj_car_exchange_pos(data)
    dump(data,"<color=red>车交换位置</color>")
    -- local launcher_car = DriveCarManager.GetCarByNo(data.obj_car_exchange_pos.launcher_car_no)
    -- local effecter_car = DriveCarManager.GetCarByNo(data.obj_car_exchange_pos.exchange_car_no)
    -- launcher_car:TransferPosition(data.obj_car_exchange_pos.car_no)
    -- effecter_car:TransferPosition(data.obj_car_exchange_pos.exchange_car_no)
end

--车改变属性
function M.on_play_process_obj_car_modify_property(data,funcs,other_data)
    dump(data,"<color=red>车属性改变</color>")
	local obj_data = data[data.key]
    Event.Brocast("notify_show_attribute_change",obj_data)
    if false and other_data and (other_data.show == nil or other_data.show == true) then
        --obj通用表现
        local modify_value = obj_data.modify_value or 0
        local skill_item = other_data.skill_item
        if obj_data.modify_key_name == "hp" then
            if obj_data.modify_value < 0 then
                skill_item:PlayDamageFx(obj_data)
                skill_item.effecter_car:PlayOnAttack()    
            else
                DriveAnimManager.PlayNewAttributeChangeFx("hp_change_fx","com_img_jsm","+" .. modify_value,true,skill_item.launcher_car:GetCenterPosition(),function()
                    if funcs and funcs.callback then
                        funcs.callback()
                    end
                end)
            end
        elseif obj_data.modify_key_name == "hd" then
            if obj_data.modify_value < 0  then
                skill_item:PlayDamageFx(obj_data)
                skill_item.effecter_car:PlayOnAttack()
            else
                DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx","com_img_gzc_fhd","",true,skill_item.launcher_car:GetCenterPosition(),function()
                    if funcs and funcs.callback then
                        funcs.callback()
                    end
                end,true)
            end
        elseif obj_data.modify_key_name == "at" then
            if obj_data.modify_value >= 0 then
                DriveAnimManager.PlayNewAttributeChangeFx(nil,"com_img_gj","+" .. modify_value,true,skill_item.launcher_car:GetCenterPosition(),function()
                    if funcs and funcs.callback then
                        funcs.callback()
                    end
                end)
            else
            end
        elseif obj_data.modify_key_name == "sp" then
            if obj_data.modify_value >= 0 then
                DriveAnimManager.PlayNewAttributeChangeFx("speed_change_fx_new","com_img_jqs","+" .. modify_value,true,skill_item.launcher_car:GetCenterPosition(),function()
                    if funcs and funcs.callback then
                        funcs.callback()
                    end
                end)
            else
                
            end
        end
    end
end

--玩家改变属性
function M.on_play_process_obj_player_modify_property(data,funcs,other_data)
    dump(data,"<color=red>玩家属性改变</color>")
    local obj_data = data[data.key]
    Event.Brocast("notify_show_attribute_change",obj_data)
    if false and other_data and (other_data.show == nil or other_data.show == true) then
        --obj通用表现
        if obj_data.modify_key_name == "money" then
            local modify_value = obj_data.modify_value or 0
            local mv = modify_value >=0 and "+" or ""
            local car = modify_value >=0 and  other_data.skill_item.launcher_car or  other_data.skill_item.effecter_car
            DriveAnimManager.PlayAttributeChangeFx(nil,"zd_icon_jb_1",mv .. modify_value,modify_value >= 0,car:GetCenterPosition(),function()
                if modify_value > 0 then
                    AudioManager.PlaySound(audio_config.drive.com_main_map_addlosegold.audio_name)
                end
            end)
            if funcs and funcs.callback then
                funcs.callback()
            end
        end
    end
end