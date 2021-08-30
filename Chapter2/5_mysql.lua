local skynet = require "skynet"
local mysql = require "skynet.db.mysql"

skynet.start(function()
    --连接
    local db=mysql.connect({
        host="39.100.116.101",
        port=3306,
        database="message_board",
        user="root",
        password="7a77-788b889aB",
        max_packet_size = 1024 * 1024,
        on_connect = nil
    })
    --插入
    local res = db:query("insert into msgs (text) values (\'hehe\')")
    --查询
    res = db:query("select * from msgs")
    --打印
    for i,v in pairs(res) do
        print ( i," ",v.id, " ",v.text)
    end
end)