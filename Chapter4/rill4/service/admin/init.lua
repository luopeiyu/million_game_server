local skynet = require "skynet"
local socket = require "skynet.socket"
local s = require "service"
local runconfig = require "runconfig"
require "skynet.manager"

function shutdown_gate()
    for node, _ in pairs(runconfig.cluster) do
        local nodecfg = runconfig[node] 
        for i, v in pairs(nodecfg.gateway or {}) do
            local name = "gateway"..i
            s.call(node, name, "shutdown")
        end
    end
end

function shutdown_agent()
    local anode = runconfig.agentmgr.node
    while true do
        local online_num = s.call(anode, "agentmgr", "shutdown", 1)
        if online_num <= 0 then
            break
        end
        skynet.sleep(100)
    end
end

function stop()
    shutdown_agent()
    --...
	skynet.abort()
	return "ok"
end

function connect(fd, addr)
    socket.start(fd)
    socket.write(fd, "Please enter cmd\r\n")
    local cmd = socket.readline(fd, "\r\n")
    if cmd == "stop" then
        stop()
    else
        --......
    end
end

s.init = function()
	local listenfd = socket.listen("127.0.0.1", 8888)
	socket.start(listenfd , connect)
end


s.start(...)