DriveEffectManager = {}
local M = DriveEffectManager

function M.ScreenRain(data)
    if not data then return end
    if not IsEquals(M.screen_rain) then
        M.screen_rain = GameObject.Find("2DNode/2DCamera"):GetComponent("ScreenRain")
    end
    M.screen_rain.enabled = data.show_or_hide
end

function M.ScreenBroken(data)
    if not data then return end
    if not IsEquals(M.screen_broken) then
        M.screen_broken = GameObject.Find("2DNode/2DCamera"):GetComponent("ScreenBroken")
    end
    M.screen_broken.enabled = data.show_or_hide
    if data.normal_scale and tonumber(data.normal_scale) then
        M.screen_broken.normalScale = data.normal_scale
    end
    if data.select and tonumber(data.select) then
        M.screen_broken.select = data.select
    end
end

function M.GhostEffect2D(data)
    if true then return end
    if not data then return end
    if not IsEquals(data.gameobject) then return end
    local ghost_effect_2d = data.gameobject:GetComponent("GhostEffect2D")
    if not IsEquals(ghost_effect_2d) then
        ghost_effect_2d = data.gameobject:AddComponent("GhostEffect2D")
    end
    -- 静止-加速-最大速度-减速-停止 这个阶段对应 打开残影-0.05-0.02-0.05-0.1-关闭残影
    ghost_effect_2d.enabled = true
    ghost_effect_2d.openGhoseEffect = data.show_or_hide
    if not data.show_or_hide then
        return
    end
    ghost_effect_2d.openGhoseEffect = true
    if data.spawn_timeval then
        ghost_effect_2d.spawnTimeval = data.spawn_timeval
    end
end

function M.GhostEffect2DChange(data)
    if true then return end
    if not data then return end
    if not IsEquals(data.ghost_effect_2d) then return end
    data.ghost_effect_2d.enabled = true
    data.ghost_effect_2d.openGhoseEffect = data.show_or_hide
    if not data.show_or_hide then
        return
    end
    data.ghost_effect_2d.openGhoseEffect = true
    if data.spawn_timeval then
        data.ghost_effect_2d.spawnTimeval = data.spawn_timeval
    end
end


function M.GhostEffect(data)
    if true then return end
    if not data then return end
    if not IsEquals(data.gameobject) then return end
    local ghost_shadow_effect = data.gameobject:GetComponent("GhostShadowEffect")
    if not IsEquals(ghost_shadow_effect) then
        ghost_shadow_effect = data.gameobject:AddComponent("GhostShadowEffect")
    end
    -- 静止-加速-最大速度-减速-停止 这个阶段对应 打开残影-0.05-0.02-0.05-0.1-关闭残影
    ghost_shadow_effect.enabled = true
    ghost_shadow_effect.openGhoseEffect = data.show_or_hide
    if not data.show_or_hide then
        return
    end
    ghost_shadow_effect.openGhoseEffect = true
    if data.interval then
        ghost_shadow_effect.spawnTimeval = data.spawn_timeval
    end
end

function M.GhostEffectChange(data)
    if true then return end
    if not data then return end
    if not IsEquals(data.ghost_shadow_effect) then return end
    data.ghost_shadow_effect.enabled = true
    data.ghost_shadow_effect.openGhoseEffect = data.show_or_hide
    if not data.show_or_hide then
        return
    end
    data.ghost_shadow_effect.openGhoseEffect = true
    if data.interval then
        data.ghost_shadow_effect.interval = data.interval
    end
end

function M.SetLight(data)
    if not data or not next(data) or not data.weather then return end
    local rbm = DriveMapManager.scene_node.transform:GetComponent("ReplaceBakingMap")
    if data.weather == "day" then
        if IsEquals(rbm) then
            rbm:SetDay()
        end
        for i = 0, DriveMapManager.scene_renderer_array.Length - 1 do
            DriveMapManager.scene_renderer_array[i].materials[0].color = Color.white
        end
        UnityEngine.RenderSettings.ambientLight = Color.white
        if IsEquals(DriveMapManager.drectional_light) then
            DriveMapManager.drectional_light.intensity = data.light or 0.1
        end
    elseif data.weather == "night" then
        -- if IsEquals(rbm) then
        --     rbm:SetNight()
        -- end
        for i = 0, DriveMapManager.scene_renderer_array.Length - 1 do
            DriveMapManager.scene_renderer_array[i].materials[0].color = Color.New(0.2,0.2,0.2)
        end
        UnityEngine.RenderSettings.ambientLight = Color.black;
        if IsEquals(DriveMapManager.drectional_light) then
            DriveMapManager.drectional_light.intensity = data.light or 0
        end
    end
end

function M.DrawMeshRoad(start_road_id,end_road_id,style)
    style = style or 1
    local road_points = {}
    local loop_count = end_road_id - start_road_id
    if loop_count < 0 then loop_count = loop_count + DriveMapManager.map_count end
    if loop_count == 0 then
        road_points[1] = start_road_id
    else
        for i = 0,loop_count do
            local road_id =  (start_road_id + i) % DriveMapManager.map_count
            if road_id == 0 then road_id = DriveMapManager.map_count end
            road_points[#road_points + 1] = road_id
        end
    end
    local style_sprite_map = {
        [1] = "RoadRangeRed",
        [2] = "RoadRangeGreen"
    }
    local style_sprite_head = {
        [1] = "RoadRangeRedHead",
        [2] = "RoadRangeGreenHead"
    }
    style = style or 1
    local mat = GetMaterial(style_sprite_map[style])
    local mat1 = GetMaterial(style_sprite_head[style])
    local draw_mesh_obj = DriveMapManager.draw_mesh:CreateRoadRange(road_points,mat,mat1)
    return draw_mesh_obj
end