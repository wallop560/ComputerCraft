local OT = turtle
local turtle = setmetatable({},{__index=OT})

local SeedIndex = {
wheat = 'wheat_seeds' -- add more shit
}

--[[turtle.directionIndex = {
    'z',
    '-x',
    '-z',
    'x'
}]]

turtle.x,turtle.y,turtle.z = 0,0,0
turtle.facing = 'z'
turtle.facingDir = 1

function tableFind(Table,Value)
    for i,v in pairs(Table) do
        if v == Value then return i end
    end
end

function turtle.recentre()
    turtle.x,turtle.y,turtle.z = 0,0,0
    turtle.facing = 'z'
    turtle.facingDir = 1
end

function turtle.forward(Dig)
    Dig = Dig or false

    local IsBlock,BlockDown = turtle.inspect()
    dig = dig and IsBlock

    repeat IsBlock,BlockDown = turtle.inspect() os.sleep(.1) until not (IsBlock and BlockDown.name:find('turtle'))

    if Dig then turtle.dig() end

    turtle[turtle.facing] = turtle[turtle.facing] + 1*turtle.facingDir
    OT.forward()
end

function turtle.turnRight()
    turtle.facingDir = turtle.facingDir * (turtle.facing == 'z' and -1 or 1)
    turtle.facing = turtle.facing == 'z' and 'x' or 'z'
    OT.turnRight()
end

function turtle.turnLeft()
    turtle.facingDir = turtle.facingDir * (turtle.facing == 'x' and -1 or 1)
    turtle.facing = turtle.facing == 'z' and 'x' or 'z'
    OT.turnLeft()
end

function turtle.turnAround()
    turtle.turnLeft()
    turtle.turnLeft()
end

function turtle.digUpDown()
    turtle.digUp()
    turtle.digDown()
end

function turtle.gotoRel(x,y,z)
    print(x,y,z)
    x,z = (turtle.facing == 'z' and x or z)*turtle.facingDir,(turtle.facing == 'z' and z or x)*turtle.facingDir
    print(x,y,z)
    x,y,z = turtle.x+x,turtle.y+y,turtle.z+z
    turtle.goto(x,y,z)
end

function turtle.back()
    turtle[turtle.facing] = turtle[turtle.facing] + -1*turtle.facingDir
    OT.back()
end

function turtle.up(dig)
    dig = dig or false

    local IsBlock,BlockDown = turtle.inspectUp()
    dig = dig and IsBlock

    repeat IsBlock,BlockDown = turtle.inspectUp() os.sleep(.1) until not (IsBlock and BlockDown.name:find('turtle'))

    if dig then turtle.digUp() end

    turtle.y = turtle.y + 1
    OT.up()
end

function turtle.down(dig)
    dig = dig or false

    local IsBlock,BlockDown = turtle.inspectDown()
    dig = dig and IsBlock

    repeat IsBlock,BlockDown = turtle.inspectDown() os.sleep(.1) until not (IsBlock and BlockDown.name:find('turtle'))

    if dig then turtle.digDown() end

    turtle.y = turtle.y - 1
    OT.down()
end

function turtle.faceDirection(Dimention,Direction)
    if turtle.facingDir == Direction and turtle.facing == Dimention then return end
    if (turtle.facingDir * (turtle.facing == 'z' and -1 or 1)) == Direction and (turtle.facing == 'z' and 'x' or 'z') == Dimention then return turtle.turnRight() end
    repeat turtle.turnLeft() until turtle.facing == Dimention and turtle.facingDir == Direction
end

function turtle.goto(x,y,z,Axis,Dir)
    x = x or 0
    y = y or 0
    z = z or 0
    Axis = Axis or turtle.facing
    Dir = Dir or turtle.facingDir
    -- go to correct Y dim
    if turtle.y ~= y then
        repeat turtle[y > turtle.y and 'up' or 'down'](true) until turtle.y == y
    end
    
    if x ~= turtle.x then
        -- face the correct X dim
        turtle.faceDirection('x', turtle.x < x and 1 or -1)

        -- go to correct X dim
        repeat turtle.forward(true) until turtle.x == x
    end

    if z ~= turtle.z then
        -- face the correct Z dim
        turtle.faceDirection('z', turtle.z < z and 1 or -1)

        -- go to correct Z dim
        repeat turtle.forward(true) until turtle.z == z
    end
    turtle.faceDirection(Axis, Dir)
end

function turtle.deposit(Whitelist)

end

function turtle.excavate(XSize,ZSize,Layers)
    local OtherLayer = 0
    for Layer = 1,Layers do
        for Row = 1,XSize do
            for Cell = 1,ZSize do
                turtle.digUp()
                turtle.digDown()
                if Cell == ZSize then break end
                turtle.forward(true)
            end
            if Row == XSize then break end
            local Direction = Row%2 == OtherLayer and 'turnLeft' or 'turnRight'
            turtle[Direction]()
            turtle.forward(true)
            turtle[Direction]()
        end
        if Layer == Layers then break end
        turtle.down(true)
        turtle.down(true)
        turtle.down(true)
        turtle.turnAround()
    end
end

function turtle.plant(Crop)
    for CropN,Seed in pairs(SeedIndex) do
        if CropN == Crop then
            Crop = Seed
        end
    end
    local Slot = turtle.findItem('minecraft:'..Crop)
    if not Slot then return end
    turtle.select(Slot)
    turtle.placeDown()
end

function turtle.harvest()
    local IsBlock,Block = turtle.inspectDown()
    if not IsBlock then return false end
    if Block.state.age ~= 7 then return false end
    do
        local Category,BlockName = 'minecraft', Block.name:sub(11,#Block.name)
        
        for Crop,Seed in pairs(SeedIndex) do
            if BlockName == Crop then
                Block.name = Category..':'..Seed
            end
        end
    end
    turtle.digDown()
    local Slot = turtle.findItem(Block.name)[1]
    
    turtle.select(Slot)
    turtle.placeDown()
    return true
end

function turtle.findRefuel()
    for Slot = 1,16 do
        turtle.select(Slot)
        if turtle.refuel() then
            return true
        end
    end
    return false
end

function turtle.findItem(Name)
    local FoundItems = {}
    for Slot = 1,16 do
        local ItemDetail = turtle.getItemDetail(Slot)
        if ItemDetail then    
            if type(Name) == 'table' then
                if tableFind(Name,ItemDetail.name) then
                    table.insert(FoundItems,Slot)
                end
            else
                if ItemDetail.name == Name then
                    table.insert(FoundItems,Slot)
                end
            end
        end
    end
    return FoundItems
end

return turtle
