-- client.lua by yabastar#0000
-- Download a basic client file at my repo "multiPineBaseClient"
-- Licensed under GPL v3.0

local hostname = 0

multi = {}

function multi.setHostID(id)
    hostname = id
end

peripheral.find("modem", rednet.open)
local pine = require("/Pine3D")

function multi.setPinePath(path)
    pine = require(path)
end

function multi.search(hostdata)
    local id, msg = rednet.receive(hostdata.."R")
    local devcount = 0
    for _, v2 in pairs(textutils.unserialize(msg)) do
        if v2 ~= nil then
            devcount = devcount + 1
        end
    end
    serverdata[id] = devcount
    return id,devcount
end

local serverdata = {}

local function localsearch(hostdata)
    while true do
        local id, msg = rednet.receive(hostdata.."R")
        if serverdata[id] == nil then
            local devcount = 0
            for _, v2 in pairs(textutils.unserialize(msg)) do
                if v2 ~= nil then
                    devcount = devcount + 1
                end
            end
            serverdata[id] = devcount
        end
    end
end

function multi.mainUI()
    local PrimeUI = require("/PrimeUI")
    PrimeUI.clear()
    PrimeUI.label(term.current(), 3, 2, "MultiPineUI")
    PrimeUI.horizontalLine(term.current(), 3, 3, #("MultiPineUI") + 2)
    
    local entries2 = {
        "List servers",
        "Connect with ID",
    }
    
    local entries2_descriptions = {
        "List running MultiPine servers",
        "Connect to a MultiPine server via computer ID"
    }
    
    local redraw = PrimeUI.textBox(term.current(), 3, 15, 40, 3, entries2_descriptions[1])
    PrimeUI.borderBox(term.current(), 4, 6, 40, 8)
    
    PrimeUI.selectionBox(term.current(), 4, 6, 40, 8, entries2, "done", function(option) redraw(entries2_descriptions[option]) end)
    
    local _, _, selection = PrimeUI.run()
    
    if selection == "List servers" then
        PrimeUI.clear()
        PrimeUI.label(term.current(), 3, 2, "MultiPineUI")
        PrimeUI.horizontalLine(term.current(), 3, 3, #("MultiPineUI") + 2)
        PrimeUI.label(term.current(), 3, 5, "Enter a server type (e.g. MultiPine)")
        PrimeUI.borderBox(term.current(), 4, 7, 40, 1)
        PrimeUI.inputBox(term.current(), 4, 7, 40, "result")
        _, _, text = PrimeUI.run()
        local function parallelsearch()
            localsearch(text)
        end
    
        local function wait()
            sleep(1)
        end
    
        local inverted = {}
        
        parallel.waitForAny(parallelsearch, wait)
        
        local entries = {}
        local desc = {}
    
        for i, v in pairs(serverdata) do
            table.insert(entries, "Server " .. i .. " (" .. v .. " devices)")
            table.insert(desc,"Join server")
            inverted["Server " .. i .. " (" .. v .. " devices)"] = i
        end
    
        if #entries == 0 then
            table.insert(entries, "Back")
            table.insert(desc, "No servers found")
        end
    
        PrimeUI.clear()
        PrimeUI.label(term.current(), 3, 2, "MultiPineUI")
        PrimeUI.horizontalLine(term.current(), 3, 3, #("MultiPineUI") + 2)
    
        local redrawServer = PrimeUI.textBox(term.current(), 3, 15, 40, 3, desc[1])
        PrimeUI.borderBox(term.current(), 4, 6, 40, 8)
        PrimeUI.selectionBox(term.current(), 4, 6, 40, 8, entries, "done", function(option) redrawServer(desc[option]) end)
    
        local _, _, serverSelection = PrimeUI.run()
        local index = inverted[serverSelection]
        hostname = tonumber(index)
    else
        PrimeUI.clear()
        PrimeUI.label(term.current(), 3, 2, "MultiPineUI")
        PrimeUI.horizontalLine(term.current(), 3, 3, #("MultiPineUI") + 2)
        PrimeUI.label(term.current(), 3, 5, "Enter server ID")
        PrimeUI.borderBox(term.current(), 4, 7, 40, 1)
        PrimeUI.inputBox(term.current(), 4, 7, 40, "result")
        local _, _, text = PrimeUI.run()
        hostname = tonumber(text)
    end
end

function multi.runClientFile(path)
    loadfile(path)()
end

function multi.runClientString(str)
    loadstring(str)()
end

return multi
