DeepLinkHelper = {}
local M = DeepLinkHelper
deeplink_appkey_cfg = require "Game.Common.deeplink_appkey"
deeplink_appkey_cfg = deeplink_appkey_cfg.info
function DeepLinkHelper.GetDeepLinkAppkey()
    local dp_appkey = "x8opi6"
    if table_is_null(deeplink_appkey_cfg) then
        return dp_appkey
    end
    local mc = gameMgr:getMarketChannel()
    for i,v in ipairs(deeplink_appkey_cfg) do
        if mc == v.market_channel then
            dp_appkey = v.deeplink_appkey
        end
    end
    return dp_appkey
end

local deeplink_keyword = "jingyu://www.jyhd919.cn"
-- 获取平台
function M.GetPTDeeplinkKeyword()
    return deeplink_keyword
end

local function ParseDeepLink(url)
	if not url or url == "" then return false end

	local segs = basefunc.string.split(url, "?")
	if #segs ~= 2 then
		print("<color=red>[DeepLink] ParseDeepLink invalid url: " .. url .. "</color>")
		return false
	end

	if segs[1] ~= M.GetPTDeeplinkKeyword() then
		print("<color=red>[DeepLink] ParseDeepLink invalid keyword: " .. url .. "</color>")
		return false
	end

	return true, segs[2]
end

function M.OpenDeepLink()
	local deeplink = sdkMgr:GetDeeplink()
	dump(deeplink,"<color=red>deeplink : </color>")
	if not deeplink or deeplink == "" then
		return
	end

	M.OpenURL(deeplink)
end

function M.OpenURL(url)
	dump(url,"<color=red>url : </color>")
	if not url or url == "" then return end
	local result, seg = ParseDeepLink(url)
	if not result then
		print("<color=red>[DeepLink] HandleOpenURL ParseDeepLink failed: url: " .. url .. "</color>")
		return
	end

	local context = seg
	local kv = basefunc.string.split(context, "/")
	if #kv == 2 then
		print("[DeepLink] key: " .. kv[1] .. ", value: " .. kv[2])

		Event.Brocast("deeplink_notify_msg", kv)
	else
		print("<color=red>[DeepLink] invalid params: " .. context .. "</color>")
	end
end