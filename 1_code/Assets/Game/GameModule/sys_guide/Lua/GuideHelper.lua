local basefunc = require "Game.Common.basefunc"
GuideHelper = {}
local M = GuideHelper

local target_sl = {}
function M.ChangeTargetLayer(target)
    dump(target,"<color=yellow>ChangeTargetLayer</color>")
    if not IsEquals(target) then return end
    local tn = target.gameObject.name
    local sl = {}
    local my_sl = target.gameObject:GetComponent(typeof(UnityEngine.Renderer))
    if not IsEquals(my_sl) then
        my_sl = target.gameObject:GetComponent("Canvas")
    end

    if not IsEquals(my_sl) then
        sl.add_canvas = 1
        dump(sl,"<color=yellow>sl??????????????????????????????</color>")
        target.gameObject:AddComponent(typeof(UnityEngine.Canvas))
        target.gameObject:AddComponent(typeof(UnityEngine.UI.GraphicRaycaster))
        my_sl = target.gameObject:GetComponent("Canvas")
        my_sl.enabled = true
        my_sl.overrideSorting = true
    end

    dump(my_sl,"<color=white>my_sl?????</color>")
    if IsEquals(my_sl) then
        sl.my_sl = my_sl.sortingLayerID
        sl.my_so = my_sl.sortingOrder
        my_sl.sortingLayerID = UnityEngine.SortingLayer.NameToID("2DFront_front")
        my_sl.sortingOrder = 99
    end

    local objs = target.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    for i = 0, objs.Length - 1 do
        sl[objs[i].gameObject.name] = objs[i].sortingLayerID
    end

    set_sorting_layer(target,"2DFront_front")
    change_order_in_layer(target,99,true)
    dump(sl,"<color=yellow>sl??????????????????????????????222222222</color>")
    target_sl[tn] = target_sl[tn] or sl
end

function M.ResetTargetLayer(target)
    dump(target,"<color=yellow>ResetTargetLayer</color>")
    if not IsEquals(target) then return end
    local tn = target.gameObject.name
    local sl = target_sl[tn]
    dump(sl,"<color=yellow>sl???????????????????</color>")
    if not sl or not next(sl) then return end

    local my_sl = target.gameObject:GetComponent(typeof(UnityEngine.Renderer))
    if not IsEquals(my_sl) then
        my_sl = target.gameObject:GetComponent("Canvas")
    end
    if IsEquals(my_sl) then
        if sl.add_canvas == 1 then
            local gr = target.gameObject:GetComponent("GraphicRaycaster")
            dump(gr,"<color=red>gr???????????????????????????????</color>")
            if IsEquals(gr) then
                destroy(gr)
            end
            destroy(my_sl)
        else
            my_sl.sortingLayerID = sl.my_sl
            my_sl.sortingOrder = sl.my_so
        end
    end

    local objs = target.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    for i = 0, objs.Length - 1 do
        objs[i].sortingLayerID = sl[objs[i].gameObject.name]
    end

    change_order_in_layer(target,99,false)

    target_sl[tn] = nil
end