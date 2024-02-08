local tickSpeed = 10

rednet.open("top")
rednet.host("GS", "server"..tostring(os.getComputerID()))
local idlist = {}
local pos = {}
local received = {}
local temprec = {}
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
        sleep(0.3)
        for id, isReceived in pairs(received) do
            if not isReceived then
                table.remove(pos,id)
            end
        end
        for id, _ in pairs(received) do
            received[id] = false
        end
    end
end

parallel.waitForAny(getData, gameTick, bootConnection)
