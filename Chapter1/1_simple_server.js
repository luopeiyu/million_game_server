var net = require('net');

var server = net.createServer(function(socket){
    console.log('connected, port:' + socket.remotePort);

    //接收到数据
    socket.on('data', function(data){
        console.log('client send:' + data);
        var ret = "嗯嗯," + data;
        socket.write(ret);
    });

    //断开连接
    socket.on('close',function(){
        console.log('closed, port:' + socket.remotePort);
    });
});
server.listen(8001);