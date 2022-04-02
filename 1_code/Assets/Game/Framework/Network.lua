local basefunc = require "Game.Common.basefunc"
local sproto = require "Game.Framework.sproto"
local sprotoparser = require "Game.Framework.sprotoparser"
local sproto_core = require "sproto.core"
local net_config = require "Game.Framework.NetConfig"
local network_helper = require "Game.Framework.NetworkHelper"

local host
local request
local session = 0
local response_callbacks = {}
local is_connected = false

NetConfig.NetConfigInit()
Network = {}

local function load_proto(fileName)
	local fn = gameMgr:getLocalPath("localconfig/" .. fileName)
	if File.Exists(fn) then
		local data = File.ReadAllText(fn)
		return basefunc.string.split(data,"\n")
	else
		local data = resMgr:LoadText(fileName, nil)
		return basefunc.string.split(data,"\n")
	end
end

local function parse_proto(data_lines)
	local text = {}

	local id = 1
	local sid = 0
	local l = ""
	local n = 0

	for i,line in ipairs(data_lines) do

		l,n = string.gsub(line, "@", tostring(id))
		if n > 0 then
			id = id + 1
		else

			l,n = string.gsub(line, "%$", tostring(sid))

			if n > 0 then
				sid = sid + 1
			end

		end

		text[#text+1]=l
	end

	return table.concat(text,"\n")
end

function Network.Init()
    Network.Register()
    local s2c = load_proto("whole_proto_s2c.txt")
    local c2s = load_proto("whole_proto_c2s.txt")

    local s2cbin = sprotoparser.parse(parse_proto(s2c));
    local c2sbin = sprotoparser.parse(parse_proto(c2s));

    host = sproto.new(s2cbin):host "package"
    request = host:attach(sproto.new(c2sbin))
end

function Network.Exit()
    Network.Unload()
end

--注册代理
function Network.Register()
    --C#层注册代理
    networkMgr:Init()
    --lua层注册代理
    Event.AddListener(Protocal.Connect, Network.OnConnect);
    Event.AddListener(Protocal.Message, Network.OnMessage);
    Event.AddListener(Protocal.Exception, Network.OnException);
    Event.AddListener(Protocal.Disconnect, Network.OnDisconnect);
end

--卸载网络监听--
function Network.Unload()
    Event.RemoveListener(Protocal.Connect, Network.OnConnect);
    Event.RemoveListener(Protocal.Message, Network.OnMessage);
    Event.RemoveListener(Protocal.Exception, Network.OnException);
    Event.RemoveListener(Protocal.Disconnect, Network.OnDisconnect);
    logWarn('Unload Network...');
end

--Socket消息--
function Network.OnSocket(key, data)
    -- dump({key = key, data = data},"<color=green>socket </color>")
    Event.Brocast(tostring(key),  data);
end

function Network.CheckConnect()
    return is_connected
end

--发起连接
function Network.SendConnect()
    print("<color=yellow>SendConnect</color>")
    networkMgr:SendConnect()
end

--当连接建立时--
function Network.OnConnect()
    print("<color=green>connect server " .. AppConst.SocketAddress .. "succeed !!!</color>")
    is_connected = true
    --连接成功清空消息回调
    response_callbacks = {}
    Event.Brocast("network_connect")
end

--异常断线--
function Network.OnException()
    logError("OnException------->>>>");
    is_connected = false
    Event.Brocast("network_exception")
end

--连接中断，或者被踢掉--
function Network.OnDisconnect()
    logError("OnDisconnect------->>>>");
    is_connected = false
    Event.Brocast("network_disconnect")
end

--主动销毁链接 - 会触发异常断线消息
function Network.DestroyConnect()
    networkMgr:DestroyConnect()
end

--处理网络数据--
function Network.OnMessage(buffer)
    local ok, result_type, arg1, arg2 = xpcall(function ()
        if PROTO_TOKEN and sproto_core then
            buffer = sproto_core.xteadecrypt(buffer,PROTO_TOKEN)
        end
        return host:dispatch(buffer)
    end
    ,function (err)
        print(" Invalid unpack stream decode error")
        print(err)
    end)

    if not ok then
        print(" OnMessage buffer error destroy connect ")
        Network.DestroyConnect()
        return
    end

    if result_type == "REQUEST" then
        Network.OnREQUEST(arg1, arg2)
    else
        Network.OnRESPONSE(arg1, arg2)
    end
end

function Network.OnREQUEST(proto_name, args)
    -- dump({proto_name = proto_name,args = args},"<color=green>REQUEST</color>")
    Event.Brocast(proto_name, proto_name, args)
end

function Network.OnRESPONSE(session_id, args)
    local response_content = response_callbacks[session_id]
    -- dump({session_id = session_id,args = args,response_content = response_content},"<color=green>RESPONSE</color>")

    if response_content == nil then
        print("callback is nil,session_id=", session_id)
        return
    end

    -- 通讯 标识
    if response_content.session_name == "login" and args.proto_token and string.len(args.proto_token) > 5 then
        PROTO_TOKEN = args.proto_token
    end

    local is_cb = response_content.callback and type(response_content.callback) == "function"
    --callback执行
    if is_cb then
        response_content.callback(args)
    end

    --作为事件分发出去
    if response_content.msg_name and (response_content.fix_response or not is_cb) then
        -- dump(args, "RESPONSE event="..response_content.msg_name);
        Event.Brocast(response_content.msg_name, response_content.msg_name, args)
    end

    Event.Brocast("SendRequestResponesSucceed",{name = response_content.session_name})
    response_callbacks[session_id] = nil
end

--如果只提供 参数 callback，则不会出发 msgname_response
--如果提供参数 fix_response == true 会执行callback 也会分发 msgname_response
function Network.SendRequest(name, args, callback,fix_response)
    --都没有连接上就不要发送消息了
    if not is_connected then
        dump(debug.traceback(),"<color=red>!!!!!!!! sever not connect</color>")
        Event.Brocast("network_sendrequest_exception",{name = name})
        return false
    end

    session = session + 1
    response_callbacks[session] =
    {
        session_name = name,
        msg_name = name.."_response",
        callback = callback,
        fix_response = fix_response,
    }
    
    -- print(string.format("send message session id=%d name=%s", session, name), args)
    local code = request(name, args, session)
    if name == "login" then
        PROTO_TOKEN = nil
    end
    if PROTO_TOKEN and sproto_core then
        code = sproto_core.xteaencrypt(code,PROTO_TOKEN)
    end

    networkMgr:SendMessageData(code)
    Event.Brocast("SendRequestSucceed",{name = name})
    return true
end

function Network.SendPostBSDS(bsds, callback)
    local url = "http://md.game3396.com/jyhd/df/GameClientClickTransactor.create.command"
    if AppConst.SocketAddress ~= "120.79.173.253:5201" then
        url = "http://testmd.game3396.com/jyhd/df/GameClientClickTransactor.create.command"
    end

    --开关强制控制
    if GameGlobalOnOff.TestSendPostBSDS then
        url = "http://testmd.game3396.com/jyhd/df/GameClientClickTransactor.create.command"
    end

    print("<color=white>url :</color>",url)
    local t = {}
    t.data = bsds
    
    local data = lua2json(t)
    local authorization = Util.HMACSHA1Encrypt(data, "cymj_yb34a1b64xmf")

    print("<color=white>SendPostBSDS data :</color>",data)

	networkMgr:SendPostRequest(url, data, "application/json", authorization, callback)
end