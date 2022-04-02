MathExtend = {}
Deg2Rad = (3.1415926 * 2) / 360

MathExtend.ParseInt = function (val)
    return math.floor(val + 0.000001)
end

MathExtend.Pow = function (v, n)
    if (n == 1) then return v end
    local val = 1
    for i = 1, n, 1 do
        val = val * v
    end
    return val
end


MathExtend.Decimal = function (v, num)
    if (num == nil) then num = 0 end
    v = ParseInt(v * Pow(10, num))
    v = v / Pow(10, num)
    return v
end

MathExtend.SortList = function (list, order, isUp)
    isUp = isUp or false -- 默认降序
    for i = 1, #list - 1 do
        local k = i
        for j = i + 1, #list do
            if isUp then
                if (order and list[k][order] > list[j][order]) or (not order and list[k] > list[j]) then
                    k = j
                end
            else
                if (order and list[k][order] < list[j][order]) or (not order and list[k] < list[j]) then
                    k = j
                end
            end            
        end
        if k ~= i then
            list[i],list[k] = list[k],list[i]
        end
    end
    return list
end

MathExtend.SortListCom = function (list, call)
    for i = 1, #list - 1 do
        local k = i
        for j = i + 1, #list do
            if call(list[k], list[j]) then
                k = j
            end
        end
        if k ~= i then
            list[i],list[k] = list[k],list[i]
        end
    end
    return list
end

MathExtend.isTimeValidity = function (beginT, endT)
    local curT=os.time()
    if beginT and beginT >= 0 and curT < beginT then
        return false
    end
    if endT and endT >= 0 and curT > endT then
        return false
    end
    return true
end

MathExtend.RandomGroup = function (num)
    local data = {}
    for i = 1, num do
        data[#data + 1] = i
    end
    local num1 = num
    while num1 > 1 do
        local i = math.random(1, num1)
        if i ~= num1 then
            data[i],data[num1] = data[num1],data[i]
        end
        num1 = num1 - 1
    end
    return data
end