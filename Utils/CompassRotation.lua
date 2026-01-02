-- Author: AlexRS
-- GitHub: https://github.com/A1exRS/Stormworks-Microcontroller-Projects
-- Workshop: https://steamcommunity.com/id/alexrs_
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

---Takes the compass weird output and converts it to rads
---
--- North = π
---
--- South = 0 or 2π
---
--- West = 1½π
---
--- East = π/2
---
---@param compassInput number
---@return number
function getCompassRads(compassInput)
    return (0.5 - compassInput) * 2 * math.pi
end

--- Takes the compass weird output and converts it to degrees
---
--- North = 180
---
--- South = 0/360
---
--- West = 270
---
--- East = 90
---
---@param compassInput number
---@---@param offset number default 90
---@return number
function getCompassDegrees(compassInput)
    return (0.5 - compassInput) * 360
end
