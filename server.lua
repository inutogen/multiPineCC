local tickSpeed = 10

rednet.open("top")
rednet.host("GS", "server"..tostring(os.getComputerID()))
local idlist = {}
local pos = {}
local function getData()
    while true do
        local id,msg,prot = rednet.receive()
        pos[id] = msg
    end
end

local function gameTick()
    while true do
        sleep(1/tickSpeed)
        print(textutils.serialise(pos))
        rednet.broadcast(textutils.serialise(pos),"GS")
    end
end

parallel.waitForAny(getData, gameTick)
