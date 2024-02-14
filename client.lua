local hostname = 0

peripheral.find("modem", rednet.open)
pine = require("/Pine3D")
PrimeUI = require("/PrimeUI")
PrimeUI.clear()
PrimeUI.label(term.current(), 3, 2, "MultiPine")
PrimeUI.horizontalLine(term.current(), 3, 3, #("MultiPine") + 2)

local serverdata = {}

local function search()
    while true do
        local id, msg = rednet.receive("MultiPineR")
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
    local function parallelsearch()
        while true do
            search()
        end
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
    PrimeUI.label(term.current(), 3, 2, "MultiPine")
    PrimeUI.horizontalLine(term.current(), 3, 3, #("MultiPine") + 2)

    local redrawServer = PrimeUI.textBox(term.current(), 3, 15, 40, 3, desc[1])
    PrimeUI.borderBox(term.current(), 4, 6, 40, 8)
    PrimeUI.selectionBox(term.current(), 4, 6, 40, 8, entries, "done", function(option) redrawServer(desc[option]) end)

    local _, _, serverSelection = PrimeUI.run()
    local index = inverted[serverSelection]
    hostname = tonumber(index)
else
    PrimeUI.clear()
    PrimeUI.label(term.current(), 3, 2, "MultiPine")
    PrimeUI.horizontalLine(term.current(), 3, 3, #("MultiPine") + 2)
    PrimeUI.label(term.current(), 3, 5, "Enter server ID")
    PrimeUI.borderBox(term.current(), 4, 7, 40, 1)
    PrimeUI.inputBox(term.current(), 4, 7, 40, "result")
    local _, _, text = PrimeUI.run()
    hostname = tonumber(text)
end
    
local frame = pine.newFrame()
frame:setCamera(0, 6, 0, 0, 0, -90)

local x, y, z = 0, 0, 0

local function runControls()
    while true do
        local event, key, _, _ = os.pullEvent()
        if key == keys.w then
            x = x + 0.25
        elseif key == keys.s then
            x = x - 0.25
        elseif key == keys.d then
            z = z + 0.25
        elseif key == keys.a then
            z = z - 0.25
        elseif key == keys.e then
            y = y + 0.25
        elseif key == keys.q then
            y = y - 0.25
        end
        rednet.send(hostname, { x, y, z },"MultiPine")
    end
end

local objects = {}

local function display()
    while true do
        local id, res = rednet.receive("MultiPineR")
        if id == hostname then
            rednet.send(hostname, "received")
            res = textutils.unserialize(res)

            for i, v in pairs(res) do
                local existingObject = objects[i]

                if existingObject then
                    existingObject:setPos(v[1], v[2], v[3])
                else
                    local newObject = frame:newObject("models/box", v[1], v[2], v[3])
                    objects[i] = newObject
                end
            end
            local allObj = {}

            local count = 1
            for k,v in pairs(objects) do
                allObj[count] = v
                count = count + 1
            end
            
            frame:drawObjects(allObj)
            frame:drawBuffer()
        end
    end
end

parallel.waitForAny(runControls, display)
