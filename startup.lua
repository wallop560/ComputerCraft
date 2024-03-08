turtle = require("turtle")

-- Startup Process (Setting up 0,0,0)
local PreviousChest
for i = 1,4 do
    turtle.forward()
    local IsBlock,Chest = turtle.inspectDown()
    if Chest.name == 'minecraft:chest' then
        if previousChest then
            turtle.turnLeft()
            turtle.forward(true)
            turtle.down(true)
            break
        end
        previousChest = true
    else
        if previousChest then
            turtle.back()
            turtle.turnLeft()
            turtle.forward(true)

            turtle.turnLeft()
            turtle.forward(true)
            turtle.down(true)
            break
        end
        previousChest = false
    end
    turtle.back()
    turtle.turnRight()
end
if not previousChest then
    print('failed to find chests... exiting.')
    return
end

turtle.recentre()

turtle.x = 54
turtle.y = 7
turtle.z = -95
turtle.facing = 'x'
turtle.facingDir =  -1
os.sleep(1)
turtle.gotoRel(5,0,0)
--turtle.excavate(3,3,4)