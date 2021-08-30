print("run lua init.lua")

function OnInit(id)
    sunnet.NewService("chat")
end

function OnExit()
    print("[lua] main OnExit")
end