--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "2x2")
    -- simulator:setProperty("ExampleNumberProperty", 1)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)
        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        -- simulator:setInputBool(31, simulator:getIsClicked(1))     -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        -- simulator:setInputNumber(1, simulator:getSlider(1))       -- set input 31 to the value of slider 1

        -- simulator:setInputBool(32, simulator:getIsToggled(2))     -- make button 2 a toggle, for input.getBool(32)
        -- simulator:setInputNumber(32, simulator:getSlider(2) * 50) -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("Display components.Compass Display")
require("Display components.Transponder Locator")

-- Define initial Values
ticks = 0
zoomLevel = 5

zibY = 0
zobY = 0
buttonSize = 6
buttonMargin = 3

-- Returns true if the point (x, y) is inside the rectangle at (rectX, rectY) with width rectW and height rectH
function isPointInRectangle(x, y, rectX, rectY, rectW, rectH)
    return x > rectX and y > rectY and x < rectX + rectW and y < rectY + rectH
end

function onTick()
    onOff = input.getBool(3)

    if onOff == false and ticks == 0 then
        return
    end

    -- Get the inputs
    posX = input.getNumber(7)
    posY = input.getNumber(8)
    searchRadius = input.getNumber(9)
    searchX = input.getNumber(10)
    searchY = input.getNumber(11)

    TransponderLocator:onTick({ enabled = onOff, position = { x = posX, y = posY }, pulse = input.getBool(4) })



    -- Read the touchscreen data from the script's composite input
    inputX = input.getNumber(3)
    inputY = input.getNumber(4)
    isPressed = input.getBool(1)

    -- Check if the player is pressing the rectangle at (10, 10) with width and height of 20px
    if isPressed and isPointInRectangle(inputX, inputY, 3, zibY, buttonSize, buttonSize) then
        zoomLevel = zoomLevel - zoomLevel * 0.1
    end
    if isPressed and isPointInRectangle(inputX, inputY, 3, zobY, buttonSize, buttonSize) then
        zoomLevel = zoomLevel + zoomLevel * 0.1
    end
end

function onDraw()
    -- If the module is "off" dont draw
    if onOff == false then
        return
    end

    -- Draw Map
    local w = screen.getWidth()
    local h = screen.getHeight()
    screen.drawMap(posX, posY, zoomLevel)

    -- Draw current position indicator
    screen.setColor(123, 28, 255)
    screen.drawRectF(w / 2, h / 2, 2, 2)

    -- Get zoom button positions on screen
    if zibY == 0 then
        zibY = h - buttonSize * 2 - buttonMargin * 2
    end

    if zobY == 0 then
        zobY = h - buttonSize - buttonMargin
    end

    -- Zoom in button
    screen.setColor(155, 155, 155)
    screen.drawRect(3, zibY, buttonSize, buttonSize)
    screen.setColor(55, 55, 55)
    screen.drawLine(5, zibY + buttonSize / 2, 3 + buttonSize - 1, zibY + buttonSize / 2)
    screen.drawLine(3 + buttonSize / 2, zibY + 2, 3 + buttonSize / 2, zibY + buttonSize - 1)

    -- Zoom out button
    screen.setColor(155, 155, 155)
    screen.drawRect(3, zobY, buttonSize, buttonSize)
    screen.setColor(55, 55, 55)
    screen.drawLine(5, zobY + buttonSize / 2, 3 + buttonSize - 1, zobY + buttonSize / 2)

    if transponderPulse == true then
        screen.setColor(255, 0, 0)
        screen.drawRectF(0, 0, 5, 5)
    end

    -- Compass Integration
    compasReading = input.getNumber(12)

    -- Compass component settings
    local compassRadius = property.getNumber("Comapss Size")
    local compassColorR = property.getNumber("Compass Color (R)")
    local compassColorG = property.getNumber("Compass Color (G)")
    local compassColorB = property.getNumber("Compass Color (B)")
    local compassColorA = property.getNumber("Compass Color (A)")

    local compassGap = property.getNumber("Compass Dial Gap")
    local compassDialColorR = property.getNumber("Compass Dial Color (R)")
    local compassDialColorG = property.getNumber("Compass Dial Color (G)")
    local compassDialColorB = property.getNumber("Compass Dial Color (B)")
    local compassDialColorA = property.getNumber("Compass Dial Color (A)")

    local compassOffsetX = property.getNumber("Compass Offset (X)")
    local compassOffsetY = property.getNumber("Compass Offset (Y)")

    -- Compass
    centerCompassElement(compasReading, {
        offset = {
            x = compassOffsetX,
            y = compassOffsetY,
        },
        ringColor = {
            r = compassColorR,
            g = compassColorG,
            b = compassColorB,
            a = compassColorA,
        },
        ringRadius = compassRadius,
        dialColor = {
            r = compassDialColorR,
            g = compassDialColorG,
            b = compassDialColorB,
            a = compassDialColorA,
        },
        dialGap = compassGap,
    })
end
