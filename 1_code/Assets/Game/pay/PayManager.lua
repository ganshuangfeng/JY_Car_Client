PayManager = {}
PayType = {
    alipay = "支付宝",
    weixin = "微信",
    UnionPay = "银联",
}
local M = PayManager
local this
local listener
local function MakeListener()
    listener = {}
end

local function AddListener()
    for msg, cbk in pairs(listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if listener then
        for msg, cbk in pairs(listener) do
            Event.RemoveListener(msg, cbk)
        end
    end
    listener = nil
end

function M.Init()
    if not this then
        this = PayManager
        M.Exit()
        MakeListener()
        AddListener()
        M.InitConfig()
        M.Refresh()
    end
end

function M.Exit()
    if this then
        RemoveLister()
    end
    this = nil
end
--alipay : 支付宝
--weixin : 微信
--UnionPay : 银联
function M.SendPayRequest(parm)
   local request = {}
   request.goods_id = parm.goods_id
   request.channel_type = parm.channel_type
   request.geturl = parm.geturl
   request.convert = parm.convert

    local create_order = function()
        Network.SendRequest(
            "create_pay_order",
            request, "创建订单",
            function(_data)
                dump(_data, "<color=green>返回订单号</color>")
                if _data.result == 0 then
                    local dplink = ""
                    local url = string.gsub(_data.pay_url, "@(%g-)@", {
                        order_id = _data.order_id,
                        child_channel = self.pay_channel_map[channel_type].child_channel,
                    })
                    url = url .. "&dplink=" .. dplink
                    dump(url,"<color=green>url</color>")
                    UnityEngine.Application.OpenURL(url)
                else
                    HintPanel.ErrorMsg(_data.result)
                end
            end
        )
    end

    local get_pay_type = function()
        Network.SendRequest("get_pay_types",{goods_id = parm.goods_id},"",function(data)
            if data.types and #data.types > 0 then
                for k,v in ipairs(data.types) do
                    self.pay_channel_map[v.channel] = v
                end
            else

            end
        end)
    end
end

function M.GetCanPayType(goods_id)
    local can_list = {}
    local check_goods_limit = function(goods_id)
        return true
    end
    for k,v in pairs(PayType) do
        if check_goods_limit(goods_id) and v then
            can_list[#can_list + 1] = k
        end
    end
    return can_list
end