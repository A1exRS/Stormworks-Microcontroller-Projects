-- Author: AlexRS
-- GitHub: https://github.com/A1exRS/Stormworks-Microcontroller-Projects
-- Workshop: https://steamcommunity.com/id/alexrs_
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

TransponderLocator = {}

TransponderLocator.ticks = 0
TransponderLocator.sameBeep = true
TransponderLocator.lastDist = {}
TransponderLocator.enabled = false
--- @type { x: number, y: number } | nil
TransponderLocator.position = nil

TransponderLocator.colorGradient = {
    { 79,  255, 73 }, -- Green
    { 90,  244, 74 },
    { 101, 234, 76 },
    { 113, 223, 77 },
    { 124, 212, 79 },
    { 135, 202, 80 },
    { 146, 191, 82 },
    { 157, 180, 83 },
    { 169, 170, 85 },
    { 180, 159, 86 },
    { 191, 148, 88 },
    { 202, 138, 89 },
    { 213, 127, 91 },
    { 225, 116, 92 },
    { 236, 106, 94 },
    { 247, 95,  95 }, -- Red
}

function TransponderLocator:getTransponderDistance(beepTicks)
    local marginForError = 3 -- Ticks
    -- Approximately every 20 ticks is 1KM
    local beepDistance = ((beepTicks + marginForError) / 20) * 1000
    return beepDistance
end

function TransponderLocator:getColorByDistance(distance)
    if distance >= 16000 then
        return self.colorGradient[16]
    end
    if distance <= 1000 then
        return TransponderLocator.colorGradient[1]
    end

    distanceLevel = distance / 1000
    return TransponderLocator.colorGradient[math.floor(distanceLevel)]
end

--- @class TransponderLocatorTickParameters: table
--- @field enabled boolean
--- @field position { x: number, y: number }
--- @field pulse boolean

---@param parameters TransponderLocatorTickParameters
function TransponderLocator:onTick(parameters)
    self.enabled = parameters.enabled
    self.position = parameters.position

    -- If the module is "off" reset the values
    if self.enabled == false and ticks > 0 then
        self.ticks = 0
        self.sameBeep = true
        self.lastDist = {}
        return
    end

    -- Count the ticks
    self.ticks = self.ticks + 1

    -- Record the beeps (Make sure we dont record the same beep multiple times)
    if parameters.pulse and not self.sameBeep then
        self.sameBeep = true
        -- Get the distance of the beep and store it in lastDist if the distance is smaller than the previous beep (These values will be used for drawing circles on the map)
        if self.lastDist[1] == nil or self.ticks < self.lastDist[1][3] then
            -- Shift the values (We only want the last 3 distances)
            self.lastDist[3] = self.lastDist[2]
            self.lastDist[2] = self.lastDist[1]

            -- Store the beep ticks and position
            self.lastDist[1] = { self.position.x, self.position.y,
                self.ticks }
        end
        self.ticks = 0
    end

    if not parameters.pulse and self.sameBeep then
        self.sameBeep = false
    end
end

--- @class TransponderLocatorDrawParameters: table
--- @field map { x: number, y: number, scale: number }

---@param parameters TransponderLocatorDrawParameters
function TransponderLocator:onDraw(parameters)
    if (self.enabled ~= true or self.position == nil) then
        return
    end

    -- Draw the distance circles around the current position
    for i = 1, #self.lastDist do
        local beep = self.lastDist[i]
        local beepDistance = self:getTransponderDistance(beep[3])

        local x, y = map.mapToScreen(parameters.map.x, parameters.map.y, parameters.map.scale, w, h, beep[1], beep[2])
        -- TODO REFACTOR
        local dx, dy = map.mapToScreen(parameters.map.x, parameters.map.y, parameters.map.scale, w, h,
            beep[1] + beepDistance, beep[2])

        local beepColor = self:getColorByDistance(beepDistance)

        screen.setColor(beepColor[1], beepColor[2], beepColor[3])
        screen.drawCircle(x, y, x - dx)
    end

    -- Get search radius
    local srchRad = 5000
    if not (searchRadius == 0) then
        srchRad = searchRadius * 1000 -- km to m
    end

    -- Draw search circle
    if not (searchX == 0) and not (searchY == 0) then
        screen.setColor(40, 83, 255) -- Blue
        local scX, scY = map.mapToScreen(posX, posY, zoomLevel, w, h, searchX, searchY)
        -- TODO REFACTOR
        local scdX, scdY = map.mapToScreen(posX, posY, zoomLevel, w, h, searchX + srchRad, searchY)
        screen.drawCircle(scX, scY, scX - scdX)
    end
end
