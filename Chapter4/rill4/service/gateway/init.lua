local skynet = require "skynet"
local socket = require "skynet.socket"
local s = require "service"
local runconfig = require "runconfig"

conns = {} --[socket_id] = conn
players = {} --[playerid] = gateplayer

local closing = false
--不再接收新连接
s.resp.shutdown = function()
    skynet.error(s.name..s.id.." shutdown")
    closing = true
end

--连接类
function conn()
    local m = {
        fd = nil,
        playerid = nil,
    }
    return m
end

--玩家类
function gateplayer()
    local m = {
        playerid = nil,
        agent = nil,
        conn = nil,
        key = 675475980 ,--math.random( 1, 999999999),
        lost_conn_time = nil,
        msgcache = {}, --未发送的消息缓存
    }
    return m
end

local str_pack = function(cmd, msg)
    return table.concat( msg, ",").."\r\n"
end

local str_unpack = function(msgstr)
    local msg = {}

    while true do
        local arg, rest = string.match( msgstr, "(.-),(.*)")
        if arg then
            msgstr = rest
            table.insert(msg, arg)
        else
            table.insert(msg, msgstr)
            break
        end
    end

    return msg[1], msg
end

s.resp.send_by_fd = function(source, fd, msg)
    if not conns[fd] then
        return
    end

    local buff = str_pack(msg[1], msg)
    skynet.error("send "..fd.." ["..msg[1].."] {"..table.concat( msg, ",").."}")
	socket.write(fd, buff)
end

s.resp.send = function(source, playerid, msg)
	local gplayer = players[playerid]
    if gplayer == nil then
		return
    end
    local c = gplayer.conn
    if c == nil then
        --return 之前是直接return
        --掉线，缓存处理。
        --注意：此缓存系统对应的是客户端主动掉线、锁屏等情况导致的掉线，而不是链路不通的情况。缓存数据只有掉线后的一段，不包含前socket发送失败的
        table.insert( gplayer.msgcache, msg )
        local len = #gplayer.msgcache
        if len > 500 then
            skynet.call("agentmgr", "lua", "reqkick", playerid, "gate消息缓存过多")
        end
        return
    end
    
    s.resp.send_by_fd(nil, c.fd, msg)
end

s.resp.sure_agent = function(source, fd, playerid, agent)

	local conn = conns[fd]
	if not conn then --登陆过程中已经下线
		skynet.call("agentmgr", "lua", "reqkick", playerid, "未完成登陆即下线")
		return false
	end
	
	conn.playerid = playerid
	
    local gplayer = gateplayer()
    skynet.error("sure_agent key:"..gplayer.key)
    gplayer.playerid = playerid
    gplayer.agent = agent
	gplayer.conn = conn
    players[playerid] = gplayer
    
	return true
end




local disconnect = function(fd)
    local c = conns[fd]
    if not c then
        return
    end

    local playerid = c.playerid
    --还没完成登录
    if not playerid then
        return
    --已在游戏中
    else
        local gplayer = players[playerid]
        gplayer.conn = nil --  players[playerid] = nil
        skynet.timeout(30*100, function()
            if gplayer.conn ~= nil then
                return
            end
            local reason = "断线超时"
            skynet.call("agentmgr", "lua", "reqkick", playerid, reason)
        end)
        
    end
end

s.resp.kick = function(source, playerid)
    local gplayer = players[playerid]
    if not gplayer then
        return
    end

    local c = gplayer.conn
    players[playerid] = nil

    if not c then
        return
    end
    conns[c.fd] = nil

    disconnect(c.fd)
    socket.close(c.fd)
end





local process_reconnect = function(fd, msg)
    local playerid = tonumber(msg[2])
    local key = tonumber(msg[3])
    --conn
    local conn = conns[fd]
    if not conn then
        skynet.error("reconnect fail, conn not exist")
        return
    end   
    --gplayer
    local gplayer = players[playerid]
    if not gplayer then
        skynet.error("reconnect fail, player not exist")
        return
    end
    if gplayer.conn then
        skynet.error("reconnect fail, conn not break")
        return
    end
    if gplayer.key ~= key then
        skynet.error("reconnect fail, key error")
        return
    end
    --绑定
    gplayer.conn = conn
    conn.playerid = playerid
    --回应
    s.resp.send_by_fd(nil, fd, {"reconnect", 0})
    --发送缓存消息
    for i, cmsg in ipairs(gplayer.msgcache) do
        s.resp.send_by_fd(nil, fd, cmsg)
    end
    gplayer.msgcache = {}
end


local process_msg = function(fd, msgstr)
    local cmd, msg = str_unpack(msgstr)
    skynet.error("recv "..fd.." ["..cmd.."] {"..table.concat( msg, ",").."}")

    local conn = conns[fd]
    local playerid = conn.playerid
    --特殊断线重连
    if cmd == "reconnect" then
        process_reconnect(fd, msg)
        return
    end
    --尚未完成登录流程
    if not playerid then
        local node = skynet.getenv("node")
        local nodecfg = runconfig[node]
        local loginid = math.random(1, #nodecfg.login)
        local login = "login"..loginid
		skynet.send(login, "lua", "client", fd, cmd, msg)
    --完成登录流程
    else
        local gplayer = players[playerid]
        local agent = gplayer.agent
		skynet.send(agent, "lua", "client", cmd, msg)
    end
end


local process_buff = function(fd, readbuff)
    while true do
        local msgstr, rest = string.match( readbuff, "(.-)\r\n(.*)")
        if msgstr then
            readbuff = rest
            process_msg(fd, msgstr)
        else
            return readbuff
        end
    end
end

--每一条连接接收数据处理
--协议格式 cmd,arg1,arg2,...#
local recv_loop = function(fd)
    socket.start(fd)
    skynet.error("socket connected " ..fd)
    local readbuff = ""
    while true do
        local recvstr = socket.read(fd)
        if recvstr then
            readbuff = readbuff..recvstr
            readbuff = process_buff(fd, readbuff)
        else
            skynet.error("socket close " ..fd)
			disconnect(fd)
            socket.close(fd)
            return
        end
    end
end

--有新连接时
local connect = function(fd, addr)
    if closing then
        return
    end
    print("connect from " .. addr .. " " .. fd)
	local c = conn()
    conns[fd] = c
    c.fd = fd
    skynet.fork(recv_loop, fd)
end

function s.init()
    local node = skynet.getenv("node")
    local nodecfg = runconfig[node]
    local port = nodecfg.gateway[s.id].port

    local listenfd = socket.listen("0.0.0.0", port)
    skynet.error("Listen socket :", "0.0.0.0", port)
    socket.start(listenfd , connect)
end


s.start(...)
