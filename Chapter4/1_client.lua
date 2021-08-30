package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;examples/?.lua"
local socket = require "client.socket"

local fd = socket.connect("127.0.0.1", 8888)
socket.usleep(1*1000000)
--测试1 发送完整消息
local bytes = string.pack(">Hc13", 13, "login,101,134")
socket.send(fd, bytes)
--关闭
socket.usleep(1*1000000)
socket.close(fd)

--[[
--测试2 发送不完整
local bytes = string.pack(">Hc10", 10, "login,101,")
socket.send(fd, bytes)
socket.usleep(1*1000000)
local bytes = string.pack(">c3", "134")
socket.send(fd, bytes)
--]]


--[[
--测试3 过剩发送
local bytes = string.pack(">Hc13Hc4Hc2", 13, "login,101,134", 4, "work", 4,"wo")
socket.send(fd, bytes)
socket.usleep(1*100000)
local bytes = string.pack(">c2", "rk")
socket.send(fd, bytes)
--]]