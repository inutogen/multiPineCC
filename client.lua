local hostname = 0


peripheral.find("modem", rednet.open)
pine = require("/Pine3D")
prime = require("/PrimeUI")
PrimeUI.clear()
PrimeUI.label(term.current(), 3, 2, "Sample Text")
PrimeUI.horizontalLine(term.current(), 3, 3, #("Sample Text") + 2)
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
    PrimeUI.label(term.current(), 3, 2, "Accepting MultiPine broadcasts...")
    local serverdata = {}
    local function search()
        local id,msg = rednet.receive("MultiPine")
        if serverdata == {} then
            local devcount = 0
            for _,v2 in pairs(textutils.serialise(msg)) do
                if not v2 == nil then
                    devcount = devcount + 1
                end    
            end
            serverdata[id] = devcount
        else
            for i,_ in ipairs(serverdata) do
                if i ~= id then
                    local devcount2 = 0
                    for _,v2 in pairs(textutils.serialise(msg)) do
                        if not v2 == nil then
                            devcount2 = devcount2 + 1
                        end    
                    end
                    serverdata[id] = devcount2
                end
            end
        end
    end
    local entries = {}
    local desc = {}
    for _,v in pairs(serverdata) do
        table.insert(entries,v)
    end
    for i=1,#entries do
        table.insert(desc, "Connect to server")
    end
    PrimeUI.clear()
    PrimeUI.label(term.current(), 3, 2, "Sample Text")
    PrimeUI.horizontalLine(term.current(), 3, 3, #("Sample Text") + 2)
    local redraw = PrimeUI.textBox(term.current(), 3, 15, 40, 3, desc[1])
    PrimeUI.borderBox(term.current(), 4, 6, 40, 8)
    PrimeUI.selectionBox(term.current(), 4, 6, 40, 8, entries, "done", function(option) redraw(desc[option]) end)
    local _, _, selection = PrimeUI.run()
    print(selection)
end
sleep(5)
local frame = pine.newFrame()
frame:setCamera(0, 6, 0, 0, 0, -90)
local x,y,z = 0,0,0
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
        rednet.send(hostname,{x,y,z})
    end
end

local objects = {}

local function display()
    while true do
        local id, res = rednet.receive("MultiPine")
        if id == hostname then
            rednet.send(hostname, "received")
            res = textutils.unserialize(res)
    
            for i, v in pairs(res) do
                -- Check if the object already exists in the objects table
                local existingObject = objects[i]
    
                if existingObject then
                    existingObject:setPos(v[1], v[2], v[3])  -- Update position
                else
                    local newObject = frame:newObject("models/box", v[1], v[2], v[3])
                    objects[i] = newObject
                end
            end
    
            frame:drawObjects(objects)
            frame:drawBuffer()
        end
    end
end

parallel.waitForAny(runControls, display)
