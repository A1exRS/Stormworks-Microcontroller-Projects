-- Author: AlexRS
-- GitHub: https://github.com/A1exRS/Stormworks-Microcontroller-Projects
-- Workshop: https://steamcommunity.com/id/alexrs_
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("Utils.CompassRotation")

--- @class CenterCompassElementSettings: table
--- @field offset { x: number, y: number } | nil
--- @field ringRadius number | nil
--- @field ringColor { r: number, g: number, b: number, a: number } | nil
--- @field dialGap number | nil
--- @field dialColor { r: number, g: number, b: number, a: number } | nil

--- Displays a compass element in middle of the screen
---
---@param compassInput number
---@param settings CenterCompassElementSettings | nil
function centerCompassElement(compassInput, settings)
    -- compassInput is value between -0.5 and 0.5 (0 = North, 0.5/-0.5 = South, -0.25 = West, 0.25 = East)

    -- Setup defaults
    settings = {
        offset = settings.offset or { x = 0, y = 0 },
        ringRadius = settings.ringRadius or 20,
        ringColor = settings.ringColor or { r = 69, g = 69, b = 69, a = 255},
        dialGap = settings.dialGap or 5,
        dialColor = settings.dialColor or { r = 69, g = 69, b = 200, a = 255}
    }

    -- Display Properties
    local ringRadius = settings.ringRadius or 20
    screen.setColor(
        settings.ringColor.r or 69,
        settings.ringColor.g or 69,
        settings.ringColor.b or 69,
        settings.ringColor.a or 255
    )

    -- Draw the compass circle in the middle of the screen
    screen.drawCircle(
        (screen.getHeight() / 2) + (settings.offset.x or 0),
        (screen.getHeight() / 2) + (settings.offset.y or 0),
        ringRadius
    )

    -- Draw the compass dial
    local compassRotationRads = getCompassRads(compassInput) + math.pi / 2

    local dialX = (ringRadius - (settings.dialGap or 5)) * math.cos(compassRotationRads) + (screen.getWidth() / 2)
    local dialY = (ringRadius - (settings.dialGap or 5)) * math.sin(compassRotationRads) + (screen.getHeight() / 2)

    screen.setColor(
        settings.dialColor.r or 69,
        settings.dialColor.g or 69,
        settings.dialColor.b or 200,
        settings.dialColor.a or 255
    )

    screen.drawLine(
        (screen.getWidth() / 2) + (settings.offset.x or 0),
        (screen.getHeight() / 2) + (settings.offset.y or 0),
        dialX + (settings.offset.x or 0),
        dialY + (settings.offset.y or 0)
    )
end
