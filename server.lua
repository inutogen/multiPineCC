local tickSpeed = 10

rednet.open("top")
rednet.host("GS", "server"..tostring(os.getComputerID()))
local idlist = {}
local pos = {}
local received = {}
local function getData()
    while true do
        local id,msg,prot = rednet.receive()
        if msg == "received" then
            received[id] = true
        else
            pos[id] = msg
        end
    end
end

local function gameTick()
    while true do
        sleep(1/tickSpeed)
        print(textutils.serialise(pos))
        rednet.broadcast(textutils.serialise(pos),"GS")
    end
end

local function bootConnection()
    while true do
        sleep(0.1)
        for i,v in ipairs(received) do
            print(i,v)
        end
    end
end
parallel.waitForAny(getData, gameTick, bootConnection)
