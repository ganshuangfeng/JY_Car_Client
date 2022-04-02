-- 创建时间:2020-11-20

DriveAnimManager = {}

function DriveAnimManager.PlayHpChangeFx(parent,change_value,position,scale_size,color,start_value)
    local fx_pre
    local is_critical = false
    if change_value < 0 then
        if change_value < -500 then
            fx_pre = newObject("CriticalFx",parent)
            is_critical = true
        else
            fx_pre = newObject("DamageFx",parent)
        end
    else
        fx_pre = newObject("GetHpFx",parent)
    end
    local start_y = fx_pre.transform.position.y + 200
    if position then
        fx_pre.transform.position = position
        start_y = position.y
    end
    local progress_bg = fx_pre.transform:Find("progress_bg")
    local timer
    if progress_bg then
        if start_value then
            start_value = start_value > 1000 and 1000 or start_value
        end
        local rect_transform = progress_bg.transform:Find("hp_progress_bar"):GetComponent("RectTransform")
        local start_size = {
            x = (start_value / 1000) * 303,
            y = 22,
        }
        local interval = 0.5
        local end_size = {
            x = ((start_value + change_value) / 1000) * 303,
            y = 22,
        }
        rect_transform.sizeDelta = start_size
        local update_spac = 1/30
        local total_frame = interval/update_spac
        local update_delta_size = {
            x = (end_size.x - start_size.x)/total_frame,
            y = (end_size.y - start_size.y)/total_frame
        }
        timer = Timer.New(function()
            rect_transform.sizeDelta = {
                x = rect_transform.sizeDelta.x + update_delta_size.x,
                y = rect_transform.sizeDelta.y + update_delta_size.y
            }
        end,update_spac,total_frame)
    end
    local move_y = 160
    if position and position.y > 100 then
        move_y = - move_y
    end
    local damage_txt = fx_pre.transform:Find("damage_txt")
    if change_value then
        damage_txt:GetComponent("Text").text = change_value > 0 and "+" .. change_value or change_value
    end
    if scale_size and not is_critical then
        fx_pre.transform.localScale = Vector3.New(scale_size,scale_size,1)
    end
    if color then
        damage_txt:GetComponent("Text").color = color
    end
    local seq = DoTweenSequence.Create()
    local fade_time = 0.9
    if not is_critical then
        seq:Append(damage_txt.transform:DOLocalMoveY(move_y,fade_time))
    else
        fx_pre.transform.localPosition = Vector3.New(fx_pre.transform.localPosition.x,fx_pre.transform.localPosition.y + 70,0)
        seq:AppendInterval(0.8)
        seq:Append(fx_pre.transform:DOScale(Vector3.New(1.3,1.3,1),0.1):SetEase(Enum.Ease.Linear))
    end
    if timer then
        seq:AppendCallback(function()
            timer:Start()
        end)
    end
    if not is_critical then
        seq:AppendInterval(1)
    else
        seq:AppendInterval(0.4)
    end
    seq:Append(fx_pre.transform:GetComponent("CanvasGroup"):DOFade(0,0.5))
    seq:OnForceKill(function()
        destroy(fx_pre.gameObject)
        if timer then
            timer:Stop()
        end
    end)
end

function DriveAnimManager.PlayChooseSkillFx(parent,over_time,position,callback)
    local fx_pre = newObject("ChooseSkillFx",parent)
    if position then
        fx_pre.transform.localPosition = position
    end
    local move_y = 80
    if position.y > 0 then
        move_y = -move_y
    end
    fx_pre.transform.localPosition = Vector3.New(fx_pre.transform.localPosition.x,fx_pre.transform.localPosition.y + move_y,0)
    local over_time_txt = fx_pre.transform:Find("over_time_txt"):GetComponent("Text")
    over_time_txt.text = over_time
    local timer 
    local end_func

    end_func = function ()
        destroy(fx_pre)
        timer:Stop()
        Event.RemoveListener("model_notify_player_status_msg",end_func)
        Event.RemoveListener("model_on_req_choose_skill_response",end_func)
    end
    timer = Timer.New(function()
        over_time = over_time - 1
        if over_time < 0 then
            end_func()
        end
        over_time_txt.text = over_time
    end,1,-1)
    timer:Start()

    Event.AddListener("model_notify_player_status_msg",end_func,true)
    Event.AddListener("model_on_req_choose_skill_response",end_func,true)
end

function DriveAnimManager.PlayBuffRaiseFx(parent,position,pre_name,change_value,remain_round_count,callback)
    local fx_pre = newObject(pre_name,parent)
    local seq = DoTweenSequence.Create()
    local fx_desc_txt = fx_pre.transform:Find("fx_desc_txt")
    local start_y = fx_pre.transform.localPosition.y
    if position then
        fx_pre.transform.localPosition = position
        start_y = position.y
    end
    if fx_desc_txt then
        fx_desc_txt = fx_desc_txt.transform:GetComponent("Text")
        fx_desc_txt.text = string.format(fx_desc_txt.text,change_value,remain_round_count)
    end
    local move_y = 100
    if position and position.y > 100 then
        move_y = - move_y
    end
    seq:Append(fx_pre.transform:DOLocalMoveY(start_y + move_y,1))
    seq:AppendInterval(1)
    if fx_pre.transform:GetComponent("CanvasGroup") then
        seq:Append(fx_pre.transform:GetComponent("CanvasGroup"):DOFade(0,1))
    end
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then
            callback()
        end
    end)
end

function DriveAnimManager.PlayViolentCarsFx(parent,initial_rotation,initial_position,target_position,item_count,attack_callback,callback,fx_name)
    for i = 1,item_count do
        local fx_pre
        if fx_name then
            fx_pre = newObject(fx_name,parent)
        else
            fx_pre = newObject("skill_violent_attack_fx",parent)
        end
        fx_pre.transform.localPosition = initial_position
        fx_pre.transform.localRotation = Quaternion:SetEuler(0,0,initial_rotation or 0)
        local seq = DoTweenSequence.Create()
        seq:AppendInterval((i - 1) * 0.4)
        seq:Append(fx_pre.transform:DOLocalMove(target_position,0.5))
        seq:OnForceKill(function()
            destroy(fx_pre)
            if attack_callback then
                attack_callback()
            end
            if callback and i == item_count then
                callback()
            end
        end)
    end
end

function DriveAnimManager.PlayCrash(parent,launcher_object,launcher_pos,target_position,callback)
    local fx_pre = GameObject.Instantiate(launcher_object,parent)
    fx_pre.transform.position = launcher_pos
    launcher_object.gameObject:SetActive(false)
    local seq = DoTweenSequence.Create()
    seq:Append(fx_pre.transform:DOLocalMove(target_position,0.5))
    seq:OnForceKill(function()
        DriveAnimManager.PlayBoomFx(parent,target_position,1)
        if callback then
            callback()
        end
        destroy(fx_pre.gameObject)
        launcher_object.gameObject:SetActive(true)
    end)
end

function DriveAnimManager.PlayShakeScreen(object,shake_time,shake_vec,callback)
    object = object or DrivePanel.Instance().transform
    local seq = DoTweenSequence.Create()
    local default_shake_time = 1.5
    seq:Append(object.transform:DOShakePosition(shake_time or default_shake_time,shake_vec or Vector3.New(0.2,0.2,0)))
    seq:OnForceKill(function ()
        if callback then
            callback()
        end
    end)
end

function DriveAnimManager.PlayRoundChangeAnim(parent,callback)
    local fx_pre = newObject("round_change_anim_fx",parent)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1.6)
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then
            callback()
        end
    end)
end

function DriveAnimManager.PlaySkillNameFx(parent,position,name,callback)
    local fx_pre = newObject("SkillNameFx",parent)
    if position then
        fx_pre.transform.position = position
    end
    local text = fx_pre.transform:GetComponent("Text")
    text.text = ""
    local seq = DoTweenSequence.Create()
    local total_interval = 0.9
    local spac_interval = total_interval / math.floor(string.len(name)/3)
    for i = 1,string.len(name),3 do
        seq:AppendInterval(spac_interval)
        seq:AppendCallback(function()
            text.text = text.text .. string.sub(name,i,i + 2)
        end)
    end
    seq:AppendInterval(1)
    seq:OnForceKill(function()
        if callback then
            callback()
        end
        destroy(fx_pre)
    end)
end

function DriveAnimManager.PlayCircleChangeFx(parent,position,remain_circle)
    local fx_pre
    local last_circle = 10
    if remain_circle > last_circle then
        fx_pre = newObject("CircleChangeFx",parent)
    else
        fx_pre = newObject("LastCircleChangeFx",parent)
    end
    local move_y = 200
    if position then
        fx_pre.transform.localPosition = Vector3.New(position.x,position.y + 100,0)
    end
    if remain_circle then
        local txt = fx_pre.transform:Find("fx_desc_txt"):GetComponent("Text")
        txt.text = string.format(txt.text,remain_circle)
    end
    local seq = DoTweenSequence.Create()
    if remain_circle > last_circle then
        seq:Append(fx_pre.transform:DOLocalMoveY(fx_pre.transform.localPosition.y + move_y,1.6))
    else
        seq:Append(fx_pre.transform:DOScale(Vector3.New(1.5,1.5,1),0.2))
    end
    seq:Join(fx_pre.transform:GetComponent("CanvasGroup"):DOFade(0,2))
    seq:OnForceKill(function()
        destroy(fx_pre)
    end)
end

function DriveAnimManager.PlaySmallStartFx(parent,position,max_value,cur_value,callback)
    local fx_pre = newObject("small_start_fx",parent)
    fx_pre.transform.localPosition = position
    local tbl = basefunc.GeneratingVar(fx_pre.transform)
    local road_height = 100
    local road_spac = 10
    local start_y = -25
    local value_list = {}
    local value_item_list = {}
    for i = 1,max_value + cur_value do
        value_list[#value_list+1] = (i % max_value) == 0 and max_value or (i % max_value)
    end

    for k,v in ipairs(value_list) do
        local obj = GameObject.Instantiate(tbl.skill_item.gameObject,tbl.content)
        obj.gameObject:SetActive(true)
        local obj_tbl = basefunc.GeneratingVar(obj.transform)
        obj_tbl.skill_item_txt.text = v .. ""
        value_item_list[#value_item_list+1] = obj
    end
    local seq = DoTweenSequence.Create()
    local total_move_y = start_y + (#value_item_list - 1) * (road_height + road_spac)
    seq:Append(tbl.content.transform:DOLocalMoveY(tbl.content.localPosition.y + total_move_y,2))
    seq:AppendInterval(1)
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then
            callback()
        end
    end)
end

function DriveAnimManager.PlaySkillAgainAnim(parent,position,target_position,callback)
    local fx_pre = newObject("skill_again_fx",parent)
    fx_pre.transform.position = DriveModel.Get3DTo2DPoint(position)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.5)
    seq:Append(fx_pre.transform:DOLocalMove(target_position,2))
    seq:AppendCallback(function()
        if callback then callback() end
        destroy(fx_pre)
    end)
end

function DriveAnimManager.PlaySkillUpgradeFx(parent,position,name,callback)
    local fx_pre = newObject("skill_upgrade_fx",parent)
    fx_pre.transform.localPosition = position
    local tbl = basefunc.GeneratingVar(fx_pre.transform)
    tbl.skill_name_txt.text = name
    local cg_1 = tbl.upgrade_node.transform:GetComponent("CanvasGroup")
    local cg_2 = tbl.upgrade_skill.transform:GetComponent("CanvasGroup")
    cg_1.alpha = 1
    cg_2.alpha = 0
    local seq_1 = DoTweenSequence.Create()
    local seq_2 = DoTweenSequence.Create()
    for i = 1,3 do
        seq_1:Append(cg_1:DOFade(0,0.1))
        seq_1:Append(cg_1:DOFade(1,0.1))
    end
    seq_2:AppendInterval(0.6)
    seq_2:Append(cg_2:DOFade(1,1))
    seq_2:Append(tbl.upgrade_skill.transform:DOLocalMoveY(100,1))
    seq_2:OnForceKill(function()
        destroy(fx_pre)
        if callback then callback() end
    end)
end

function DriveAnimManager.PlayBigSkillFx(callback)
    local fx_pre = newObject("big_skill_fx",GameObject.Find("Canvas/LayerLv3").transform)
    local seq = DoTweenSequence.Create()
    seq:Append(fx_pre.transform:DOScale(Vector3.New(2,2,1),1.2))
    seq:Append(fx_pre.transform:GetComponent("CanvasGroup"):DOFade(0,0.1))
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then callback() end
    end)
end

--------------------------新的效果动画
function DriveAnimManager.PlayProcessFirstPlayerFx(callback)
    local fx_pre = newObject("ProcessFirstPlayerFx",GameObject.Find("Canvas/LayerLv3").transform)
    local canvas_group =  fx_pre.transform:GetComponent("CanvasGroup")
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1)
    seq:Append(canvas_group:DOFade(0,0.5))
    seq:OnForceKill(function()
        if callback then
            callback()
        end
    end)
end

function DriveAnimManager.PlayGetSkillFx(skill_icon,start_pos,target_pos,callback)
    local fx_pre = newObject("get_skill_fx_pre",GameObject.Find("Canvas/LayerLv3").transform)
    fx_pre.transform.position = start_pos
    fx_pre.transform:Find("skill_icon"):GetComponent("Image").sprite = GetTexture(DriveMapManager.GetMapAssets(skill_icon))
    local seq = DoTweenSequence.Create()
    seq:Append(fx_pre.transform:DOMoveBezier(target_pos,50,0.5))
    seq:Append(fx_pre.transform:GetComponent("CanvasGroup"):DOFade(0,0.5))
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then
            callback()
        end
    end)
end

-- 图标上升
function DriveAnimManager.PlayAttributeChangeFx(pre_name,attr_icon,change_desc,is_add_attr,position,callback)
    local fx_pre
    if pre_name then
        fx_pre = newObject(pre_name,GameObject.Find("Canvas/LayerLv3").transform)
    else
        fx_pre = newObject("attribute_change_fx",GameObject.Find("Canvas/LayerLv3").transform)
    end

    local tbl = basefunc.GeneratingVar(fx_pre.transform)
    local move_y = 100
    if position then
        fx_pre.transform.position = DriveModel.Get3DTo2DPoint(position)
    end
    if change_desc then
        if is_add_attr then
            tbl.add_desc_txt.text = change_desc
            tbl.dec_desc_txt.gameObject:SetActive(false)
        elseif not is_add_attr then
            tbl.dec_desc_txt.text = change_desc
            tbl.add_desc_txt.gameObject:SetActive(false)
            -- fx_pre.transform.localPosition = Vector3.New(fx_pre.transform.localPosition.x,fx_pre.transform.localPosition.y + 100,0)
            move_y = -100
        end
    else
        tbl.add_desc_txt.gameObject:SetActive(false)
        tbl.dec_desc_txt.gameObject:SetActive(false)
    end
    if attr_icon then
        tbl.icon_img.sprite = GetTexture(attr_icon)
    else
        tbl.icon_img.gameObject:SetActive(false)
    end
    local seq = DoTweenSequence.Create()
    seq:Append(fx_pre.transform:DOLocalMoveY(fx_pre.transform.localPosition.y + move_y,1.5))
    seq:Insert(1,fx_pre:GetComponent("CanvasGroup"):DOFade(0,0.5))
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then callback() end
    end)
end

function DriveAnimManager.PlayNewAttributeChangeFx(pre_name,attr_icon,change_desc,is_add_attr,position,callback,set_natve_size,close,speed)
    local fx_pre
    if pre_name then
        fx_pre = newObject(pre_name,GameObject.Find("Canvas/LayerLv3").transform)
    else
        fx_pre = newObject("attack_change_fx",GameObject.Find("Canvas/LayerLv3").transform)
    end

    local tbl = basefunc.GeneratingVar(fx_pre.transform)
    local move_y = 100
    speed = speed or 2
    if position then
        fx_pre.transform.position = DriveModel.Get3DTo2DPoint(Vector3.New(position.x,position.y - 0.3,0))
    end
    -- dump(fx_pre,"<color>||||||||||||||||||||||||||||||||||||||</color>")
    -- dump(tbl.add_desc_txt.spriteAsset)
    local add_sprAsset = tbl.add_desc_txt.spriteAsset
    local dec_sprAsset = tbl.dec_desc_txt.spriteAsset
    if change_desc then
        if is_add_attr then
            tbl.add_desc_txt.text = add_sprAsset and TMPNormalStringConvertTMPSpriteStr(tostring(change_desc)) or change_desc
            tbl.dec_desc_txt.gameObject:SetActive(false)
        elseif not is_add_attr then
            tbl.dec_desc_txt.text = dec_sprAsset and TMPNormalStringConvertTMPSpriteStr(tostring(change_desc)) or change_desc
            tbl.add_desc_txt.gameObject:SetActive(false)
            -- fx_pre.transform.localPosition = Vector3.New(fx_pre.transform.localPosition.x,fx_pre.transform.localPosition.y + 100,0)
            move_y = -100
        end
    else
        tbl.add_desc_txt.gameObject:SetActive(false)
        tbl.dec_desc_txt.gameObject:SetActive(false)
    end
    if attr_icon then
        tbl.icon_img.sprite = GetTexture(attr_icon)
        if set_natve_size then
            tbl.icon_img:SetNativeSize()
        end
    else
        tbl.icon_img.gameObject:SetActive(false)
    end
    local seq = DoTweenSequence.Create()
    fx_pre.transform:GetComponent("CanvasGroup").alpha = 0
    fx_pre.transform.localScale = Vector3.New(3,3,1)
    seq:Append(fx_pre.transform:DOScale(Vector3.New(0.4,0.4,1),0.2/speed))
    seq:Join(fx_pre:GetComponent("CanvasGroup"):DOFade(1,0.2/speed))
    seq:Append(fx_pre.transform:DOScale(Vector3.New(0.8,0.8,1),0.1/speed))
    seq:Append(fx_pre.transform:DOLocalMoveY(fx_pre.transform.localPosition.y + move_y,2.5/speed))
    if not close then
        seq:Insert(1.7,fx_pre:GetComponent("CanvasGroup"):DOFade(0,1/speed))
    end
    seq:OnForceKill(function()
        if not close then
            destroy(fx_pre)
        end
        if callback then callback() end
    end)
    return fx_pre
end

-- 冲刺效果
function DriveAnimManager.PlayDashFx(icon_name,position,callback)
    local fx_pre = newObject("skill_dash_fx",GameObject.Find("Canvas/LayerLv3").transform)
    
    local tbl = basefunc.GeneratingVar(fx_pre.transform)
    if icon_name then
        tbl.icon_img.sprite = GetTexture(icon_name)
    end
    if position then
        fx_pre.transform.localPosition = position
    end

    local seq = DoTweenSequence.Create()
    seq:Append(fx_pre.transform:DOLocalMoveY(fx_pre.transform.localPosition.y + 100,1.5))
    seq:Insert(1,fx_pre:GetComponent("CanvasGroup"):DOFade(0,0.5))
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then callback() end
    end)
end

-- 车辆升级效果
function DriveAnimManager.PlayCarSkillUpFx(desc,position,callback)
    local fx_pre = newObject("skill_up_fx",GameObject.Find("Canvas/LayerLv3").transform)
    
    local tbl = basefunc.GeneratingVar(fx_pre.transform)
    if desc then
        tbl.desc_txt.text = desc
    end
    if position then
        fx_pre.transform.position = position
    end

    local seq = DoTweenSequence.Create()
    seq:Append(fx_pre.transform:DOLocalMoveY(fx_pre.transform.localPosition.y + 100,1.5))
    seq:Insert(1,fx_pre:GetComponent("CanvasGroup"):DOFade(0,0.5))
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then callback() end
    end)
end


-- 车辆升级效果
function DriveAnimManager.PlaySkillAgainFx(position,callback)
    local fx_pre = newObject("skill_again_fx",GameObject.Find("Canvas/LayerLv3").transform)
    
    local tbl = basefunc.GeneratingVar(fx_pre.transform)
    if position then
        fx_pre.transform.position = DriveModel.Get3DTo2DPoint(position)
    end

    local seq = DoTweenSequence.Create()
    seq:Append(fx_pre.transform:DOLocalMoveY(fx_pre.transform.localPosition.y + 100,1.5))
    seq:Insert(1,fx_pre:GetComponent("CanvasGroup"):DOFade(0,0.5))
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then callback() end
    end)
end


-- 选择路障-放置中效果
function DriveAnimManager.PlaySelectBarrierIconFx(icon_name,position,callback)
    local fx_pre = newObject("skill_select_barrier_fx",GameObject.Find("Canvas/LayerLv3").transform)
    
    local tbl = basefunc.GeneratingVar(fx_pre.transform)
    if icon_name then
        tbl.icon_img.sprite = GetTexture(icon_name)
    end
    if position then
        fx_pre.transform.position = Vector3.New(position.x,position.y + 50,0)
    end

    local seq = DoTweenSequence.Create()
    -- seq:Append(fx_pre.transform:DOLocalMoveY(fx_pre.transform.localPosition.y + 100,1.5))
    -- seq:Insert(1,fx_pre:GetComponent("CanvasGroup"):DOFade(0,0.5))
    seq:OnForceKill(function()
        if callback then callback() end
    end)
    return fx_pre
end

--颜色光特效
--[[
    {
        lvse,
        hongse,
        qingse,
        jinse,
    }
]]
function DriveAnimManager.PlayColorGlowFx(parent,color_name,color_level,callback)
    local fx_pre = newObject("yanseguang",parent)
    if color_name then
        fx_pre.transform:Find(color_name).gameObject:SetActive(true)
        --#现在暂时先用二级效果
        color_level = 2
        fx_pre.transform:Find(color_name):Find(color_level .. "").gameObject:SetActive(true)
    end
    
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(2)
    seq:AppendCallback(function()
        if callback then callback() end
    end)
    seq:AppendInterval(0.5)
    seq:OnForceKill(function()
        destroy(fx_pre)
    end)
end


function DriveAnimManager.PlayBoomFx(parent,position,scale_size,boom_level,callback)
    local fx_pre = newObject("zhadan",parent)
    if position then
        fx_pre.transform.position = position
    end

    if scale_size then
        fx_pre.transform.localScale = Vector3.New(scale_size,scale_size,1)
    end
    boom_level = boom_level or 1
    fx_pre.transform:Find(boom_level.. "").gameObject:SetActive(true)
    local seq = DoTweenSequence.Create()
    local end_time = 5
    seq:AppendInterval(end_time)
    seq:OnForceKill(function()
        if callback then
            callback()
        end
        destroy(fx_pre.gameObject)
    end)
end

--炸弹技能飞炸弹
function DriveAnimManager.PlayMoveTargetFx(parent,launcher_pos,effecter_pos,pre_name,move_time,use_bezier,scale_size,icon_img,callback)
    local fx_pre
    if pre_name then
        fx_pre = newObject(pre_name,parent)
    else
        fx_pre = newObject("AttackFx",parent)
    end
    fx_pre.transform.position = launcher_pos
    if scale_size then
        fx_pre.transform.localScale = Vector3.New(scale_size,scale_size,1)
    end
    if icon_img then
        fx_pre.transform:GetComponent("Image").sprite = GetTexture(icon_img)
    end
    local seq = DoTweenSequence.Create()
    if not use_bezier then
        seq:Append(fx_pre.transform:DOLocalMove(effecter_pos,move_time))
    else
        seq:Append(fx_pre.transform:DOMoveLocalBezier(effecter_pos,200,move_time))
    end
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then
            callback()
        end
    end)
end

function DriveAnimManager.PlayBigSkillNameFx(image_name,launcher_pos,callback)
    local fx_pre = newObject("RoadAwardMapBig_ui",GameObject.Find("Canvas/LayerLv3").transform)
    fx_pre.transform.position = DriveModel.Get3DTo2DPoint(Vector3.New(launcher_pos.x,launcher_pos.y + 1,0))
    if image_name then
        fx_pre.transform:Find("@icon_node/@icon_img (6)").transform:GetComponent("Image").sprite = GetTexture(image_name)
    end
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(2.5)
    seq:OnForceKill(function()
        destroy(fx_pre)
        if callback then callback() end
    end)
end

local damage_move_speed = 0.5

function DriveAnimManager.PlayDamageFx(damage_count,position,before_hp,after_hp,total_hp,callback,modify_key_name)
    local fx_pre = newObject("damage_fx",GameObject.Find("Canvas/LayerLv3").transform)
    fx_pre.transform.position = DriveModel.Get3DTo2DPoint(position)
    local progress_img = fx_pre.transform:Find("progress/@progress_img"):GetComponent("Image")
    local progress_white_img = fx_pre.transform:Find("progress/@progress_white_img"):GetComponent("Image")
    local damage_txt = fx_pre.transform:Find("@damage_txt"):GetComponent("TMP_Text")
    local hd_damage_txt = fx_pre.transform:Find("@hd_damage_txt"):GetComponent("TMP_Text")
    if modify_key_name == "hd" then
        local progress_bg_img = fx_pre.transform:Find("progress"):GetComponent("Image")
        progress_bg_img.sprite = GetTexture("com_img_fh1")
        progress_img.sprite = GetTexture("com_img_fh2")
        --damage_txt.font = GetFont("df_font_jianxue")
    end
    damage_txt.gameObject:SetActive(not (modify_key_name == "hd"))
    hd_damage_txt.gameObject:SetActive(modify_key_name == "hd")

    damage_txt.text = TMPNormalStringConvertTMPSpriteStr(damage_count)
    hd_damage_txt.text = TMPNormalStringConvertTMPSpriteStr(damage_count)

    local start_v = before_hp / total_hp
    local end_v = after_hp / total_hp
    local seq = DoTweenSequence.Create()
    local cur_v = start_v
    local duration = 1
    progress_white_img.fillAmount = start_v
	local DOTProcesse = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
			function(value)
				cur_v = start_v
				progress_img.fillAmount = cur_v
                return cur_v
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				cur_v = value
				progress_img.fillAmount = cur_v
            end
        ),
        end_v,
		duration
	)
	DOTProcesse:SetEase(Enum.Ease.Linear)
    seq:Append(damage_txt.transform:DOLocalMoveY(damage_txt.transform.localPosition.y + 50,damage_move_speed))
    seq:InsertCallback(duration,function()
        local DOTProcesse = DG.Tweening.DOTween.To(
            DG.Tweening.Core.DOGetter_float(
                function(value)
                    cur_v = start_v
                    progress_white_img.fillAmount = cur_v
                    return cur_v
                end
            ),
            DG.Tweening.Core.DOSetter_float(
                function(value)
                    cur_v = value
                    if IsEquals(progress_white_img) then
                        progress_white_img.fillAmount = cur_v
                    end
                end
            ),
            end_v,
            duration
        )
        DOTProcesse:SetEase(Enum.Ease.Linear)
    end)
    seq:Insert(damage_move_speed / 2,damage_txt.transform:GetComponent("CanvasGroup"):DOFade(0,0.5))
    seq:AppendInterval(duration)
    seq:Append(fx_pre.transform:GetComponent("CanvasGroup"):DOFade(0,1))
    seq:AppendCallback(function()
        if callback then callback() end
        destroy(fx_pre)
    end)
    return fx_pre
end

function DriveAnimManager.PlayCritDamageFx(damage_count,position,before_hp,after_hp,total_hp,callback,modify_key_name)
    local fx_pre = newObject("damage_crit_fx",GameObject.Find("Canvas/LayerLv3").transform)
    
    local image = fx_pre.transform:Find("Image") 
    fx_pre.transform.position = DriveModel.Get3DTo2DPoint(position)
    local progress_img = fx_pre.transform:Find("progress/@progress_img"):GetComponent("Image")
    local damage_txt = fx_pre.transform:Find("Image/@damage_txt"):GetComponent("TMP_Text")

    damage_txt.text = TMPNormalStringConvertTMPSpriteStr(tostring(damage_count))

    if modify_key_name == "hd" then
        local progress_bg_img = fx_pre.transform:Find("progress"):GetComponent("Image")
        progress_bg_img.sprite = GetTexture("com_img_fh1")
        progress_img.sprite = GetTexture("com_img_fh2")
        --damage_txt.font = GetFont("df_font_jianxue")
    end

    local start_v = before_hp / total_hp
    local end_v = after_hp / total_hp
    local seq = DoTweenSequence.Create()
    seq:Append(damage_txt.transform:DOLocalMoveY(damage_txt.transform.localPosition.y + 50,damage_move_speed))
    local cur_v = start_v
    local duration = 1
	local DOTProcesse = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
			function(value)
				cur_v = start_v
				progress_img.fillAmount = cur_v
                return cur_v
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				cur_v = value
				progress_img.fillAmount = cur_v
            end
        ),
        end_v,
		duration
	)
	DOTProcesse:SetEase(Enum.Ease.Linear)
    seq:Insert(damage_move_speed / 2,damage_txt.transform:GetComponent("CanvasGroup"):DOFade(0,0.5))
    seq:AppendInterval(duration)
    seq:Append(fx_pre.transform:GetComponent("CanvasGroup"):DOFade(0,1))
    seq:AppendCallback(function()
        if callback then callback() end
        destroy(fx_pre)
    end)
    return fx_pre
end

function DriveAnimManager.FlyingToTarget(node, targetPoint, targetScale, interval,direction, callback, forcecallback, delay,hight)
	if not IsEquals(node) then
		if callback then callback() end
		return
	end

	local seq = DoTweenSequence.Create()
	delay = delay or 0
	if delay > 0 then		
		seq:AppendInterval(delay)
	end
    direction = direction or math.random(0,1)
    hight = hight or 300
	seq:Append(node.transform:DOMoveBezier(targetPoint, hight, interval,direction))

	targetScale = targetScale or 1
	if targetScale ~= 1 then
		seq:Join(node.transform:DOScale(targetScale, interval))
	end

	seq:OnKill(function ()
		if callback then callback() end
	end)
	seq:OnForceKill(function ()
		if forcecallback then
			forcecallback()
		end
	end)
end

function DriveAnimManager.PlayGetToolsAwardFx(tools_id,fx_pos)
    local random_award_id_cfg = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4,
        [5] = 5,
        [6] = 6,
        [7] = 8,
        [8] = 10,
        [9] = 11,
        [10] = 15,
        [11] = 37,
        [12] = 61,
        [13] = 63,
        [14] = 71,
    }
    local rdn_count = 16
    local random_award_list = {}
    math.randomseed(os.time())
    for i = 1,rdn_count do
        local random_tool = {}
        if i == rdn_count - 1 then
            random_tool.id = tools_id
        else
            random_tool.id = random_award_id_cfg[math.random(1,#random_award_id_cfg)]
        end
        random_tool.icon = ToolsManager.GetToolsCfgById(random_tool.id).icon
        random_award_list[i] = random_tool
    end
    local fx_pre = newObject("tools_award_fx",GameObject.Find("Canvas/LayerLv3").transform)
    local fx_tbl = basefunc.GeneratingVar(fx_pre.transform)
    fx_pre.transform.localPosition = fx_pos or Vector3.zero
    for k,random_tool in ipairs(random_award_list) do
        local pre = GameObject.Instantiate(fx_tbl.award_icon_img.gameObject,fx_tbl.parent)
        pre.transform:GetComponent("Image").sprite =  GetTexture(DriveMapManager.GetMapAssets(random_tool.icon))
        pre.gameObject:SetActive(true)
        random_tool.pre = pre
    end
    local seq = DoTweenSequence.Create()
    local width = 140.4
    local left_padding = 4
    local spac = 2
    local total_width = left_padding + rdn_count * (width + spac) - spac
    fx_tbl.parent.transform.localPosition = Vector3.New(total_width/2 - (width + spac) * 1.5,0,0)
    local move_x = - (rdn_count - 3) * (width + spac)
    local move_time = 3
    seq:AppendInterval(0.2)
    seq:Append(fx_tbl.parent.transform:DOLocalMoveX(fx_tbl.parent.transform.localPosition.x + move_x,move_time))
    seq:AppendInterval(0.5)
    for i = 1,5 do
        seq:AppendCallback(function()
            fx_tbl.award_bg.gameObject:SetActive(true)
        end)
        seq:AppendInterval(0.1)
        seq:AppendCallback(function()
            fx_tbl.award_bg.gameObject:SetActive(false)
        end)
        seq:AppendInterval(0.1)
    end
    seq:AppendCallback(function()
        destroy(fx_pre)
    end)
end

function DriveAnimManager.PlayCrashFly(car,target_pos,callback,use_time_factor)
    local z = -0.01499993
    target_pos = Vector3.New(target_pos.x,target_pos.y,z)
    local transform = car.transform
    local temp_ui = {}
    LuaHelper.GeneratingVar(transform,temp_ui)
    local last_active = {}
    for k,v in pairs(temp_ui) do
        last_active[v] = v.gameObject.activeSelf
        v.gameObject:SetActive(k == "model" or k == "car")
    end
    local ptg_ptzhuangji = temp_ui.car.transform:Find("ptg_ptzhuangji")
    local old_parent
    if ptg_ptzhuangji then
        old_parent = ptg_ptzhuangji.transform
        ptg_ptzhuangji.transform.parent = transform.parent
    end
    local seq = DoTweenSequence.Create()
    local curr_pos = transform.position
    local dis = tls.pGetDistance(curr_pos,target_pos)
    local use_time = dis * 0.08 < 0.2 and 0.2 or  dis * 0.08
    if use_time_factor then
        use_time = use_time * use_time_factor
    end
    seq:Append(
        transform:DORotate(Vector3.New(math.random(170,190),180,math.random(170,190)),use_time/3,Enum.RotateMode.WorldAxisAdd):SetEase(Enum.Ease.Linear)
    )
    seq:Append(
        transform:DORotate(Vector3.New(0,360 * 2,0),use_time/3,Enum.RotateMode.WorldAxisAdd):SetEase(Enum.Ease.Linear)
    )
    seq:Append(
        transform:DORotate(Vector3.New(0,360,0),use_time/3,Enum.RotateMode.WorldAxisAdd):SetEase(Enum.Ease.Linear)
    )
    seq:Append(
        transform:DORotate(Vector3.New(0,12,0),0.1,Enum.RotateMode.Fast):SetEase(Enum.Ease.Linear)
    )
    seq:Append(
        transform:DORotate(Vector3.New(0,-12,0),0.1,Enum.RotateMode.Fast):SetEase(Enum.Ease.Linear)
    )
    seq:Append(
        transform:DORotate(Vector3.New(0,0,0),0.1,Enum.RotateMode.Fast):SetEase(Enum.Ease.Linear)
    )
    seq:Insert(
        0,transform:DOMoveX(target_pos.x,use_time):SetEase(Enum.Ease.Linear)
    )
    seq:Insert(
        0,transform:DOMoveY(target_pos.y,use_time):SetEase(Enum.Ease.Linear)
    )
    seq:Insert(
        0,temp_ui.car.transform:DOLocalRotate(car:GetCarRotation(),use_time,Enum.RotateMode.Fast):SetEase(Enum.Ease.Linear)
    )
    seq:Insert(
        0,transform:DOLocalMoveZ(-2,use_time/2):SetEase(Enum.Ease.InCirc) 
    )
    seq:Insert(
        use_time/2,transform:DOLocalMoveZ(z,use_time/2):SetEase(Enum.Ease.OutCirc)
    )
    seq:AppendCallback(
        function()
            if ptg_ptzhuangji then
                ptg_ptzhuangji.transform.parent = old_parent
            end
            for k, v in pairs(last_active) do
                k.gameObject:SetActive(v)
            end
            if callback then callback() end
        end
    )
end

function DriveAnimManager.PlayBoomMove(car,target_pos,callback)
    local z = -0.01499993
    local transform = car.transform
    local seq = DoTweenSequence.Create()
    local use_time = 1.5
    seq:AppendInterval(use_time)
    seq:Join(
        transform:DOMoveX(target_pos.x,use_time):SetEase(Enum.Ease.Linear)
    )
    seq:Join(
        transform:DOMoveY(target_pos.y,use_time):SetEase(Enum.Ease.Linear)
    )
    seq:Insert(
        0,transform:DOMoveZ(-3,use_time * 4/5):SetEase(Enum.Ease.Linear)
    )
    seq:Insert(
        use_time * 4/5,transform:DOMoveZ(z,use_time/5):SetEase(Enum.Ease.Linear)
    )
    seq:AppendCallback(
        function()
            if callback then callback() end
        end
    )
end