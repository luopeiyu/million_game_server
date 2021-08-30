var net = require('net');

var scenes = new Map();

var server = net.createServer(function(socket){
    scenes.set(socket, true) //新连接

    socket.on('data', function(data) { //收到数据
        for (let s of scenes.keys()) {
            s.write(data);
        }
    });
});

server.listen(8010);