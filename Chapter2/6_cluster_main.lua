local skynet = require "skynet"
local cluster = require "skynet.cluster"
require "skynet.manager"
 
skynet.start(function()
    cluster.reload({
        node1 = "127.0.0.1:7001",
        node2 = "127.0.0.1:7002"
    })
    local mynode = skynet.getenv("node")

    if mynode == "node1" then
        cluster.open("node1")
        local ping1 = skynet.newservice("ping")
        local ping2 = skynet.newservice("ping")
        skynet.send(ping1, "lua", "start", "node2", "pong")
        skynet.send(ping2, "lua", "start", "node2", "pong")
    elseif mynode == "node2" then
        cluster.open("node2")
        local ping3 = skynet.newservice("ping")
        skynet.name("pong", ping3)
    end
end)