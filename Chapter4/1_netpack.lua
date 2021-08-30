local skynet = require "skynet"
local socketdriver = require "skynet.socketdriver"
local netpack = require "skynet.netpack"

local queue    -- message queue


--有新连接
function process_connect(fd, addr)
     skynet.error("new conn fd:"..fd.." addr:"..addr)
     socketdriver.start(fd)
end

--关闭连接
function process_close(fd)
     skynet.error("close fd:"..fd)
end

--发生错误
function process_error(fd, error)
     skynet.error("error fd:"..fd.." error:"..error)
end

--发生警告
function process_warning(fd, size)
     skynet.error("warning fd:"..fd.." size:"..size)
end


--处理消息
function process_msg(fd, msg, sz)
     local str = netpack.tostring(msg,sz)
     skynet.error("recv from fd:"..fd .." str:"..str)
End

--收到多于1条消息时
function process_more()
     for fd, msg, sz in netpack.pop, queue do
          skynet.fork(process_msg, fd, msg, sz)
     end
end

--解码底层传来的SOCKET类型消息
function socket_unpack( msg, sz )
     return netpack.filter( queue, msg, sz)
end

--处理底层传来的SOCKET类型消息
function socket_dispatch(_, _, q, type, ...)
     skynet.error("socket_dispatch type:"..(type or "nil"))
     queue = q
     if type == "open" then
          process_connect(...)
     elseif type == "data" then
          process_msg(...)
     elseif type == "more" then
          process_more(...)   
     elseif type == "close" then
          process_close(...)
     elseif type == "error" then
          process_error(...)
     elseif type == "warning" then
          process_warning(...)
     end
end


skynet.start(function()
     --注册SOCKET类型消息
     skynet.register_protocol( {
          name = "socket",
          id = skynet.PTYPE_SOCKET,
          unpack = socket_unpack,
          dispatch = socket_dispatch,
     })
     --注册Lua类型消息（skynet.dispatch 略）
     --开启监听
     local listenfd = socketdriver.listen("0.0.0.0", 8888)
     socketdriver.start(listenfd)
end)