-- 游戏车辆类
local basefunc = require "Game/Common/basefunc"
DriveCarMoveHelper = basefunc.class()
local M = DriveCarMoveHelper
M.name = "DriveCarMoveHelper"

function get_moveDis_in_speedType(dis,cur_v,up_a,down_a,max_v,min_v)
    -- dump({dis = dis,cur_v = cur_v,up_a = up_a,down_a = down_a,max_v = max_v,min_v = min_v},"<color=yellow>不同加速阶段计算</color>")
    local up_dis = 0
    local down_dis = 0
    local uniform_dis = 0
    local up_t = 0
    local down_t = 0
    local uniform_t = 0
    if up_a == 0 and down_a ~= 0 then
        down_dis = (cur_v * cur_v - min_v * min_v) / (2 * down_a)
        if up_dis + down_dis > dis then
            --不能顺利完成减速，全部路程都是减速
            down_dis = dis
        end
        uniform_dis = dis - up_dis - down_dis
        -- 0.5 * -down_a * t * t + cur_v * t - down_dis = 0
        local a = (-down_a) * 0.5
        local b = cur_v
        local c = -down_dis
        down_t = (-b + math.sqrt(b * b - 4 * a * c)) / (2 * a)
        local vt = cur_v + (-down_a) * down_t
        uniform_t = uniform_dis / vt
    elseif up_a == 0 and down_a == 0 then
        uniform_dis = dis - up_dis - down_dis
        uniform_t = uniform_dis / cur_v
    elseif up_a ~= 0 and down_a == 0 then
        up_dis = (max_v * max_v - cur_v * cur_v) / (2 * up_a)
        if up_dis + down_dis  > dis then
            --不能顺利完成加速，全部路程都是加速
            up_dis = dis
        end
        uniform_dis = dis - up_dis - down_dis
        -- 0.5 * up_a * t * t + cur_v * t - up_dis = 0
        local a = up_a * 0.5
        local b = cur_v
        local c = -up_dis
        up_t = (-b + math.sqrt(b * b - 4 * a * c)) / (2 * a)
        local vt = cur_v + up_a * up_t
        uniform_t = uniform_dis / vt
    elseif up_a ~= 0 and down_a ~= 0 then
        up_dis = (max_v * max_v - cur_v * cur_v) / (2 * up_a)
        down_dis = (max_v * max_v - min_v * min_v) / (2 * down_a)
        -- dump({up_dis = up_dis,down_dis = down_dis,dis = dis,cur_v = cur_v,max_v = max_v,min_v = min_v},"<color=white>正常加减速结果</color>")
        local vt = max_v
        if up_dis + down_dis > dis then
            --不能顺利完成加减速
            vt = math.sqrt((dis * 2 * up_a * down_a + down_a * cur_v * cur_v + up_a * min_v * min_v) / (up_a + down_a))
            up_dis = (vt * vt - cur_v * cur_v) / (2 * up_a)
            down_dis = (vt * vt - min_v * min_v) / (2 * down_a)
            -- dump({up_dis = up_dis,down_dis = down_dis,dis = dis,vt = vt,cur_v = cur_v,max_v = max_v,min_v = min_v},"<color=white>不正常加减速结果</color>")
        end
        local a = up_a * 0.5
        local b = cur_v
        local c = -up_dis
        up_t = (-b + math.sqrt(b * b - 4 * a * c)) / (2 * a)

        uniform_dis = dis - up_dis - down_dis
        uniform_t = uniform_dis / vt

        local a = (-down_a) * 0.5
        local b = vt
        local c = -down_dis
        down_t = (-b + math.sqrt(b * b - 4 * a * c)) / (2 * a)
    end
    -- dump({up_dis = up_dis,uniform_dis = uniform_dis,down_dis = down_dis,up_t = up_t,uniform_t = uniform_t,down_t = down_t},"<color=yellow>不同加速阶段计算</color>")
    return up_dis, uniform_dis, down_dis, up_t, uniform_t, down_t
end

--通过距离获得耗时 并返回末端速度
function get_useTime_by_moveDis(dis, cur_v, up_a, max_v, min_v)
    local t = 0
    if up_a == 0 then
        t = dis / cur_v
        -- dump({dis = dis,cur_v = cur_v, up_a = up_a, max_v = max_v, min_v = min_v,t = t},"<color=green>通过距离获得耗时 并返回末端速度</color>")
        -- dump({t = t,cur_v = cur_v},"<color=white>匀速运动</color>")
        return t, cur_v
    end

    if up_a > 0 then
        t = (max_v - cur_v) / up_a
    elseif up_a < 0 then
        t = (min_v - cur_v) / up_a
    end
    local len = cur_v * t + 0.5 * up_a * t * t
    -- dump({len = len,dis = dis,cur_v = cur_v, up_a = up_a, max_v = max_v, min_v = min_v,t = t},"<color=green>通过距离获得耗时 并返回末端速度</color>")
    if len > dis then
        -- 0.5 * up_a * t * t + cur_v * t - dis = 0
        --匀变速运动
        t = (-cur_v + math.sqrt(cur_v * cur_v - 4 * 0.5 * up_a * (-dis))) / (2 * 0.5 * up_a)
        cur_v = cur_v + up_a * t
        -- dump({t = t,cur_v = cur_v},"<color=white>匀变速运动</color>")
        return t,cur_v
    elseif len == dis then
        cur_v = cur_v + up_a * t
        -- dump({t = t,cur_v = cur_v},"<color=white>匀变速运动2</color>")
        return t, cur_v
    else
        --完成了加减速
        if up_a > 0 then
            t = t + (dis - len) / max_v
            cur_v = max_v
        elseif up_a < 0 then
            t = t + (dis - len) / min_v
            cur_v = min_v
        end
        -- dump({t = t,cur_v = cur_v},"<color=white>非匀变速运动333333333</color>")
        return t, cur_v
    end
end

--通过耗时获得距离  并返回末端速度
function get_moveDis_by_useTime(t, cur_v, up_a, max_v, min_v)
    local dis = 0
    local vt = cur_v
    if up_a == 0 then
        dis = cur_v * t
        -- dump({t = t,cur_v = cur_v,max_v = max_v,min_v = min_v,up_a = up_a,dis = dis,vt = vt,t_s = t_s},"<color=yellow>通过耗时获得距离  并返回末端速度</color>")
        return dis, vt
    end

    local t_s = 0
    if up_a > 0 then
        t_s = (max_v - cur_v) / up_a
    else
        t_s = (min_v - cur_v) / up_a
    end

    if t_s >= t then
        dis = cur_v * t + 0.5 * up_a * t * t
        vt = cur_v + up_a * t
    else
        dis = cur_v * t_s + 0.5 * up_a * t_s * t_s
        if up_a > 0 then
            dis = dis + max_v * (t - t_s)
            vt = max_v
        else
            dis = dis + min_v * (t - t_s)
            vt = min_v
        end
    end
    -- dump({t = t,cur_v = cur_v,max_v = max_v,min_v = min_v,up_a = up_a,dis = dis,vt = vt,t_s = t_s},"<color=yellow>通过耗时获得距离  并返回末端速度</color>")
    return dis, vt
end

local map_point = {}
local map_cfg = {}
--一圈的总距离
local map_all_length = 0
local cur_location = {}
local cur_xianduan = nil
local shun_or_ni = nil
local cur_time = nil

function get_map_length()
    return map_all_length
end

function get_map_all_length(map_cfg)
    local l=0
    for idx,p in ipairs(map_cfg) do
        if idx==1 then
            l=l+Vec2DLength(Vec2DSub(p, map_cfg[#map_cfg]))
        else
            l=l+Vec2DLength(Vec2DSub(p, map_cfg[idx-1]))
        end
    end
    return l
end
function get_curMapIdx_by_point(cur_p)
    for idx,p in ipairs(map_cfg) do
        if Vec2DLength(Vec2DSub(cur_p, p))<0.1 then
            return idx
        end
    end

    local min_idx = 1
    local min_dis = 1000000
    local cur_dis = 0
    for idx,p in ipairs(map_cfg) do
        cur_dis = Vec2DLength(Vec2DSub(cur_p, p))
        if min_dis > cur_dis then
            min_dis = cur_dis
            min_idx = idx
        end
    end
    return min_idx
    -- return nil
end

function get_curMapXianduanIdx(p_idx)
    return p_idx
end
--获得运动方向的下一个点
function get_nextMapIdx(xianduan, shun_or_ni)
    if shun_or_ni then
        if xianduan == #map_cfg then
            return 1
        end
        return xianduan + 1
    else
        return xianduan
    end
end
--获得运动方向的下一个线段
function get_nextMapXianduanIdx(xianduan, shun_or_ni)
    if shun_or_ni then
        if xianduan == #map_cfg  then
            return 1
        end
        return xianduan + 1
    else
        if xianduan - 1 == 0 then
            return #map_cfg
        end
        return xianduan - 1
    end
end
function get_curAngle_by_xianduan(xianduan, shun_or_ni)
    local p1=map_cfg[xianduan]
    local p2
    if xianduan==#map_cfg then
        p2=map_cfg[1]
    else
        p2=map_cfg[xianduan+1]
    end
    if shun_or_ni then
        return Vec2DAngle(Vec2DSub(p2, p1))
    else
        return Vec2DAngle(Vec2DSub(p1, p2))
    end
end
function get_location(shun_or_ni, cur_location, cur_xianduan, len)
    len = len % map_all_length
    --当前所处的线段长度
    local start_loc = cur_location
    while true do
        local next_point = map_cfg[get_nextMapIdx(cur_xianduan, shun_or_ni)]
        local line_length = Vec2DLength(Vec2DSub(next_point, start_loc))
        if line_length >= len then
            return get_xianduanPoint_by_length(start_loc, next_point, len), cur_xianduan,get_curAngle_by_xianduan(cur_xianduan, shun_or_ni)
        else
            len = len - line_length
            start_loc = next_point
            cur_xianduan = get_nextMapXianduanIdx(cur_xianduan, shun_or_ni)
        end
    end
end

function get_xianduanPoint_by_length(p1, p2, len)
    local v1 = Vec2DSub(p2, p1)
    v1 = Vec2DNormalize(v1)
    return Vec2DAdd(p1, Vec2DMultNum(v1, len))
end

function init_drive_car_map_cfg(map_prefab,_map_cfg,path_points)
    map_cfg = {}
    map_point = {}
    local max_x1 = 4.6
    local max_x2 = -4.6
    local max_y1 = 7.4
    local max_y2 = -5.7
    local center_pos = Vector3.zero
    local upVector = Vector3.New(0,0,1)
    local function get_angle(fromVector,toVector)
        local angle = Vector3.Angle (fromVector, toVector); --求出两向量之间的夹角  
        local normal = Vector3.Cross (fromVector,toVector);--叉乘求出法线向量  
        angle = angle * Mathf.Sign (Vector3.Dot(normal,upVector));  --求法线向量与物体上方向向量点乘，结果为1或-1，修正旋转方向  
        return angle
    end

    local function keepTwoDecimalPlaces(decimal)
        decimal = math.floor((decimal * 100)+0.5)*0.01        
        return  decimal 
    end

    local function keepTwoDecimalPlacesVec(v)
        v.x = keepTwoDecimalPlaces(v.x)
        v.y = keepTwoDecimalPlaces(v.y)
        v.z = keepTwoDecimalPlaces(v.z)

        if v.x > max_x1 then
            v.x = max_x1
        end

        if v.x < max_x2 then
            v.x = max_x2
        end

        if v.y > max_y1 then
            v.y = max_y1
        end

        if v.y < max_y2 then
            v.y = max_y2
        end

        return v
    end

    local map_path_points = {}
    for i=0,path_points.Length - 1 do
        -- path_points[i].x = math.
        table.insert(map_path_points,path_points[i])
    end

    for i,v in ipairs(map_path_points) do
        v = keepTwoDecimalPlacesVec(v)
    end
    local main_index = 1
    local main_pos = map_prefab["road_node_" .. main_index].transform.position
    main_pos = keepTwoDecimalPlacesVec(main_pos)
    local path_pos
    local main_point_index = {}
    local cur_angle
    local points = {}
    local add_point 
    local cur_dis
    add_point = function (i)
        if main_index > DriveMapManager.map_count then
            --main_pos 取完
            table.insert(points,basefunc.deepcopy(path_pos))
            return 
        end

        cur_dis = Vec2DLength(Vec2DSub(path_pos, main_pos))
        if cur_dis == 0 then
            table.insert(points,basefunc.deepcopy(main_pos))
            main_point_index[#points] = main_index
            main_index = main_index + 1
            if main_index > DriveMapManager.map_count then return end
            main_pos = map_prefab["road_node_" .. main_index].transform.position
            main_pos = keepTwoDecimalPlacesVec(main_pos)
            return
        end
        cur_angle = get_angle(path_pos,main_pos)
        if cur_angle < 0 then
            --main_pos 在前面
            table.insert(points,basefunc.deepcopy(main_pos))
            main_point_index[#points] = main_index
            main_index = main_index + 1
            if main_index > DriveMapManager.map_count then return end
            main_pos = map_prefab["road_node_" .. main_index].transform.position
            main_pos = keepTwoDecimalPlacesVec(main_pos)
            add_point(i)
        else
            --main_pos 在后面
            table.insert(points,basefunc.deepcopy(path_pos))
        end
    end
    for i,v in ipairs(map_path_points) do
        path_pos = v
        add_point(i)
    end


    for i,v in ipairs(points) do
        map_cfg[i] = v
        if main_point_index[i] then
            map_point[i] = {type = "main",pos = main_point_index[i], vec = v}
        else
            map_point[i] = {type = "rotation", vec = v}
        end
    end

    map_all_length = get_map_all_length(map_cfg)

    dump(map_cfg,"<color=yellow>初始化移动地图配置 map_cfg </color>")
    dump(map_point,"<color=yellow>初始化移动地图配置 map_point </color>")
    dump(map_all_length,"<color=yellow>每一圈地图长度 map_all_length </color>")
    -- local parent = GameObject.Find("node_root").transform
    -- for i,v in ipairs(map_point) do
    --     dump({i = i, v = v},"<color=white>地图点 ：</color>")
    --     local car = newObject("car",parent)
    --     car.transform.position = v.vec
    --     if v.type == "main" then
    --         car.gameObject.name = v.type .."_" .. v.pos
    --     else
    --         car.gameObject.name = v.type .."_" .. i
    --     end
    -- end

    -- for i=1,DriveMapManager.map_count do
    --     local parent = GameObject.Find("road_node" .. i).transform
    --     local car = newObject("car",parent)
    --     car.transform.position = parent.position
    -- end
end

function get_map_point_angle(vec,shun_or_ni)
    local cur_xianduan = get_curMapXianduanIdx(get_curMapIdx_by_point(vec))
    shun_or_ni = true
    local location,xianduan,angle = get_location(shun_or_ni,vec,cur_xianduan,0)
    return angle
end

function get_map_line_length(map_cfg)
    local l=0
    local next_idx
    for idx,p in ipairs(map_cfg) do
        next_idx = idx + 1
        if next_idx > #map_cfg then
            break
        end

        l=l+Vec2DLength(Vec2DSub(p, map_cfg[next_idx]))
    end
    return l
end

function get_move_all_len(pos,move_nums)
    -- dump({pos = pos,move_nums = move_nums},"<color=white>长度计算</color>")
    if math.abs(move_nums) == 0 then return 0 end
    if move_nums % DriveMapManager.map_count == 0 then
        return  math.abs(move_nums / DriveMapManager.map_count * map_all_length)
    end

    local f = move_nums / math.abs(move_nums)
    local pos_s
    local main_index = {}
    for i=f,move_nums,f do
        pos_s = (pos + i) % DriveMapManager.map_count
        if pos_s == 0 then 
            pos_s = DriveMapManager.map_count
        end
        for index,v in ipairs(map_point) do
            if v.type == "main" then
                local v_pos = (v.pos - DriveMapManager.first_id + 1 + DriveMapManager.map_count) % DriveMapManager.map_count
                if v_pos == 0 then v_pos = DriveMapManager.map_count end 
                if pos_s == v_pos then
                    table.insert(main_index,index)
                end
            end
        end
    end
    -- dump(main_index,"<color=white>经过的main节点</color>")
    local move_point = {}
    local next_index
    for i,index in ipairs(main_index) do 
        if f > 0 then
            if i == #main_index then
                table.insert(move_point,map_point[index].vec)
                break
            end
            next_index = main_index[i + 1]
            if next_index < index then
                for j=index,#map_point do
                    table.insert(move_point,map_point[j].vec)
                end
                for j=1,next_index - 1 do
                    table.insert(move_point,map_point[j].vec)
                end
            else
                for j=index,next_index - 1 do
                    table.insert(move_point,map_point[j].vec)
                end
            end
        elseif f < 0 then
            if i == #main_index then
                table.insert(move_point,map_point[index].vec)
                break
            end
            next_index = main_index[i + 1]
            if next_index > index then
                for j=index,1,-1 do
                    table.insert(move_point,map_point[j].vec)
                end
                
                for j=#map_point,next_index + 1,-1 do
                    table.insert(move_point,map_point[j].vec)
                end
            else
                for j = index, next_index + 1, -1 do
                    table.insert(move_point,map_point[j].vec)
                end
            end
        end
    end
    local all_len = get_map_line_length(move_point)
    -- dump({main_index = main_index,move_point = move_point,pos = pos,move_nums = move_nums,all_len = all_len},"<color=yellow>移动长度计算</color>")
    return all_len,move_point
end

function get_curMapPoint_by_point(cur_p)
    for idx,p in ipairs(map_point) do
        if Vec2DLength(Vec2DSub(cur_p, p.vec))<0.1 then
            return p
        end
    end

    local min_idx = 1
    local min_dis = 1000000
    local cur_dis = 0
    for idx,p in ipairs(map_point) do
        cur_dis = Vec2DLength(Vec2DSub(cur_p, p.vec))
        if min_dis > cur_dis then
            min_dis = cur_dis
            min_idx = idx
        end
    end
    return map_point[min_idx]
    -- return nil
end

function get_curMainMapPoint_by_point(cur_p,cur_main,cur_state)
    local offset_dis = 0
    for idx,p in ipairs(map_point) do
        if p.type == "main" then
            offset_dis = Vec2DLength(Vec2DSub(cur_p, p.vec))
            if offset_dis < 0.001 then
                return p,offset_dis
            end
        end
    end

    local min_idx = 1
    local min_dis = 1000000
    for idx,p in ipairs(map_point) do
        if p.type == "main" then
            offset_dis = Vec2DLength(Vec2DSub(cur_p, p.vec))
            if min_dis > offset_dis then
                min_dis = offset_dis
                min_idx = idx
            end
        end
    end

    if not cur_main then
        return map_point[min_idx],min_dis
    end

    if cur_state == 4 and min_dis > 0.08 then
        return cur_main,min_dis
    else
        return map_point[min_idx],min_dis
    end
    -- return nil
end

function get_curMainMapPoint_progress_value(cur_p,cur_main)
    local min_idx = 1
    local min_dis = 1000000
    local offset_dis
    for idx,p in ipairs(map_point) do
        if p.type == "main" then
            offset_dis = Vec2DLength(Vec2DSub(cur_p, p.vec))
            if min_dis > offset_dis then
                min_dis = offset_dis
                min_idx = idx
            end
        end
    end
end

--通过时间或距离计算当前状态情况
function compute_state_data_by_time_or_dis(cur_state,cur_v,delta_ori_val,cur_val,up_val,uniform_val,down_val,stop_val,all_val,func,up_a,down_a,max_v,min_v)
    -- dump({cur_state = cur_state,cur_v = cur_v,delta_ori_val = delta_ori_val,cur_val = cur_val,up_val = up_val,uniform_val = uniform_val,down_val = down_val,stop_val = stop_val,all_val = all_val,func = func,up_a = up_a,down_a = down_a,max_v = max_v,min_v = min_v})

    local delta_tar_val = 0
    if cur_state == 1 then
        if cur_val <= up_val then
            -- print("<color=green>加速</color>")
            delta_tar_val,cur_v= func(delta_ori_val, cur_v, up_a, max_v, min_v)
        elseif cur_val > up_val and cur_val <= up_val + uniform_val then
            -- print("<color=green>加速 + 匀速</color>")
            local delta_ori_uniform = cur_val - up_val
            local delta_ori_up = delta_ori_val - delta_ori_uniform
            --加速
            local delta_tar_up = 0
            delta_tar_up,cur_v = func(delta_ori_up, cur_v, up_a, max_v, min_v)
            --匀速
            local delta_tar_uniform = 0
            delta_tar_uniform,cur_v = func(delta_ori_uniform, cur_v, 0, max_v, min_v)
            delta_tar_val = delta_tar_up + delta_tar_uniform
            cur_state = 2
        elseif cur_val > up_val + uniform_val and cur_val <= up_val + uniform_val + down_val then
            -- print("<color=green>加速 + 匀速 + 减速</color>")
            local delta_ori_down = cur_val - up_val - uniform_val
            local delta_ori_uniform = uniform_val
            local delta_ori_up = delta_ori_val - delta_ori_uniform - delta_ori_down
            --加速
            local delta_tar_up = 0
            delta_tar_up,cur_v = func(delta_ori_up, cur_v, up_a, max_v, min_v)
            --匀速
            local delta_tar_uniform = 0
            delta_tar_uniform,cur_v = func(delta_ori_uniform, cur_v, 0, max_v, min_v)
            --减速
            local delta_tar_down = 0
            delta_tar_down,cur_v = func(delta_ori_down, cur_v, -down_a, max_v, min_v)
            delta_tar_val = delta_tar_up + delta_tar_uniform + delta_tar_down
            cur_state = 3
        elseif cur_val > up_val + uniform_val + down_val and cur_val <= all_val then
            -- print("<color=green>加速 + 匀速 + 减速 + 滑行</color>")
            local delta_ori_stop = cur_val - up_val - uniform_val - down_val
            local delta_ori_down = down_val
            local delta_ori_uniform = uniform_val
            local delta_ori_up = delta_ori_val - delta_ori_uniform - delta_ori_down - delta_ori_stop
            --加速
            local delta_tar_up = 0
            delta_tar_up,cur_v = func(delta_ori_up, cur_v, up_a, max_v, min_v)
            --匀速
            local delta_tar_uniform = 0
            delta_tar_uniform,cur_v = func(delta_ori_uniform, cur_v, 0, max_v, min_v)
            --减速
            local delta_tar_down = 0
            delta_tar_down,cur_v = func(delta_ori_down, cur_v, -down_a, max_v, min_v)
            --滑行
            local delta_tar_stop = 0
            delta_tar_stop,cur_v = func(delta_ori_stop, cur_v, 0, max_v, min_v)
            delta_tar_val = delta_tar_up + delta_tar_uniform + delta_tar_down + delta_tar_stop
            cur_state = 4
            if cur_val == all_val then
                cur_state =  5
            end
        end
    elseif cur_state == 2 then
        if cur_val <= up_val + uniform_val then
            -- print("<color=green>匀速</color>")
            delta_tar_val,cur_v= func(delta_ori_val, cur_v, 0, max_v, min_v)
        elseif cur_val > up_val + uniform_val and cur_val <= up_val + uniform_val + down_val then
            -- print("<color=green>匀速 + 减速</color>")
            local delta_ori_down = cur_val - up_val - uniform_val
            local delta_ori_uniform = delta_ori_val - delta_ori_down
            --匀速
            local delta_tar_uniform = 0
            delta_tar_uniform,cur_v = func(delta_ori_uniform, cur_v, 0, max_v, min_v)
            --减速
            local delta_tar_down = 0
            delta_tar_down,cur_v = func(delta_ori_down, cur_v, -down_a, max_v, min_v)
            delta_tar_val = delta_tar_uniform + delta_tar_down
            cur_state = 3
        elseif cur_val > up_val + uniform_val + down_val and cur_val <= all_val then
            -- print("<color=green>匀速 + 减速 + 滑行</color>")
            local delta_ori_stop = cur_val - up_val - uniform_val - down_val
            local delta_ori_down = down_val
            local delta_ori_uniform = delta_ori_val - delta_ori_down - delta_ori_stop
            --匀速
            local delta_tar_uniform = 0
            delta_tar_uniform ,cur_v = func(delta_ori_uniform, cur_v, 0, max_v, min_v)
            --减速
            local delta_tar_down = 0
            delta_tar_down,cur_v = func(delta_ori_down, cur_v, -down_a, max_v, min_v)
            --滑行
            local delta_tar_stop = 0
            delta_tar_stop,cur_v = func(delta_ori_stop, cur_v, 0, max_v, min_v)
            delta_tar_val = delta_tar_uniform + delta_tar_down + delta_tar_stop
            cur_state = 4
            if cur_val == all_val then
                cur_state =  5
            end
        end
    elseif cur_state == 3 then
        if cur_val <= up_val + uniform_val + down_val then
            -- print("<color=green>减速</color>")
            delta_tar_val,cur_v= func(delta_ori_val, cur_v, -down_a, max_v, min_v)
        elseif cur_val > up_val + uniform_val + down_val and cur_val <= all_val then
            -- print("<color=green>减速 + 滑行</color>")
            local delta_ori_stop = cur_val - up_val - uniform_val - down_val
            local delta_ori_down = delta_ori_val - delta_ori_stop
            --减速
            local delta_tar_down = 0
            delta_tar_down,cur_v = func(delta_ori_down, cur_v, -down_a, max_v, min_v)
            --滑行
            local delta_tar_stop = 0
            delta_tar_stop,cur_v = func(delta_ori_stop, cur_v, 0, max_v, min_v)
            delta_tar_val = delta_tar_down + delta_tar_stop
            cur_state = 4
            if cur_val == all_val then
                cur_state =  5
            end
        end
    elseif cur_state == 4 then
        -- print("<color=green>滑行</color>")
        delta_tar_val,cur_v= func(delta_ori_val, cur_v, 0, max_v, min_v)
        if cur_val >= all_val then
            cur_state =  5
        end
    elseif cur_state == 5 then
        -- print("<color=green>滑行完成</color>")
        
    end

    if cur_val >= all_val then
        cur_state =  5
    end

    return cur_state,cur_v,delta_tar_val
end