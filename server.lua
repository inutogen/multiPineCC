--configurable variables
local tickSpeed = 10 -- updates per second
local serverName = "server"..tostring(os.getComputerID())

local hostdata = "MultiPine"

peripheral.find("modem", rednet.open)
rednet.host(hostdata, serverName)
local idlist = {}
local pos = {}
local received = {}
local temprec = {}
local function getData()
    while true do
        local id,msg,prot = rednet.receive()
        if msg == "received" then
            received[id] = true
        elseif prot == "find" then
            if msg == hostname then
                rednet.send(id,"host")
            else
                rednet.send(id,"nonhost")
            end
        else
            if prot == "MultiPine" then
                pos[id] = msg
            end
        end
    end
end

local function gameTick()
    while true do
        sleep(1/tickSpeed)
        print(textutils.serialise(pos))
        rednet.broadcast(textutils.serialise(pos),(hostdata.."R"))
    end
end

local function bootConnection()
    while true do
        sleep(0.3)
        for id, isReceived in pairs(received) do
            if not isReceived then
                pos[id] = nil
                break
            end
        end
        for id, _ in pairs(received) do
            received[id] = false
        end
    end
end

local function official_host()
    while true do
        
    end
end

parallel.waitForAny(getData, gameTick, bootConnection)
