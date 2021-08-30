local skynet = require "skynet"
local s = require "service"

s.client = {}
s.gate = nil

require "scene"


s.resp.client = function(source, cmd, msg)
    s.gate = source
    if s.client[cmd] then
		local ret_msg = s.client[cmd]( msg, source)
		if ret_msg then
			skynet.send(source, "lua", "send", s.id, ret_msg)
		end
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

s.client.work = function(msg)
	s.data.coin = s.data.coin + 1
	return {"work", s.data.coin}
end

s.resp.kick = function(source)
	s.leave_scene()
	--在此处保存角色数据
	skynet.sleep(200)
end

s.resp.exit = function(source)
	skynet.exit()
end

s.resp.send = function(source, msg)
	skynet.send(s.gate, "lua", "send", s.id, msg)
end

--每天第一次登陆调用
function first_login_day()
	skynet.error("first_login_day")
end

s.init = function( )
	--playerid = s.id
	--在此处加载角色数据
	skynet.sleep(200)
	s.data = {
		coin = 100,
		hp = 200,
	}


end

s.start(...)