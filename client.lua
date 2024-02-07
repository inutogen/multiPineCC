rednet.open("top")
local hostname = 0
pine = require("/Pine3D")
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



local function display()
while true do
    local _,res = rednet.receive("GS")
    rednet.send(hostname,"received")
    res = textutils.unserialise(res)
    local objects = {}
    for i,v in ipairs(res) do
        objects[#objects+1] = frame:newObject("models/box",v[1],v[2],v[3])
    end
    frame:drawObjects(objects)
    frame:drawBuffer()
end
end

parallel.waitForAny(runControls, display)
