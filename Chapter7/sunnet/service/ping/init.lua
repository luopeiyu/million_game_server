local serviceId

function OnInit(id)
    print("[lua] ping OnInit id:"..id)
    serviceId = id
end


function OnServiceMsg(source, buff)
    local n1 = 0
    local n2 = 0
    --解码
    if buff ~= "start" then
        n1, n2 = string.unpack("i4 i4", buff)
    end
    --处理
    print("[lua] ping OnServiceMsg n1:"..n1.." n2:"..n2)
    n1 = n1 + 1
    n2 = n2 + 2
    --编码
    buff = string.pack("i4 i4", n1, n2)
    sunnet.Send(serviceId, source, buff)
end

function OnExit()
    print("[lua] ping OnExit")
end