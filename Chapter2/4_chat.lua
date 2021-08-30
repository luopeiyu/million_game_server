local skynet = require "skynet"
local socket = require "skynet.socket"

local clients = {}

function connect(fd, addr)
    --启用连接
    print(fd.." connected addr:"..addr)
    socket.start(fd)
    clients[fd] = {}
    --消息处理
    while true do
        local readdata = socket.read(fd)
        --正常接收
        if readdata ~= nil then
            print(fd.." recv "..readdata)
            for i, _ in pairs(clients) do --广播
                socket.write(i, readdata)
            end
        --断开连接
        else
            print(fd.." close ")
            socket.close(fd)
            clients[fd] = nil
        end
    end
end
    
skynet.start(function()
    local listenfd = socket.listen("0.0.0.0", 8888)
    socket.start(listenfd ,connect)
end)