local skynet = require "skynet"
local cluster = require "skynet.cluster"
local mynode = skynet.getenv("node")

local CMD = {}

function CMD.ping(source, source_node, source_srv, count)
    local id = skynet.self()
    skynet.error("["..id.."] recv ping count="..count)
    skynet.sleep(100)
    cluster.send(source_node, source_srv, "ping", mynode, skynet.self(), count+1)
end

function CMD.start(source, target_node, target)
    cluster.send(target_node, target, "ping", mynode, skynet.self(), 1)
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
      local f = assert(CMD[cmd])
      f(source,...)
    end)
end)