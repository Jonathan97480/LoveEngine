-- libreria/tools/inputManager.lua
-- Centralise la capture et helpers d'input (souris/clavier) utilisés dans le projet.
local input = {}

local IM = nil
local lockClick = false

local function _loadInterface()
    if IM then return IM end
    local ok, mod = pcall(require, "libreria/tools/inputInterface")
    if ok and type(mod) == 'table' then IM = mod end
    return IM
end

function input.update(dt)
    local i = _loadInterface()
    if i and i.update then i.update(dt) end
end

function input.hover(x, y, width, height, scale)
    local i = _loadInterface()
    local cursor = i and i.getCursor and i.getCursor() or { x = 0, y = 0 }
    local sx, sy = 1, 1
    if type(scale) == "table" then
        sx = scale.x or scale[1] or 1
        sy = scale.y or scale[2] or 1
    end
    local mx, my = cursor.x or 0, cursor.y or 0
    return (mx >= (x or 0) and mx <= (x or 0) + (width or 0) * sx and my >= (y or 0) and my <= (y or 0) + (height or 0) * sy)
end

function input.click()
    local i = _loadInterface()
    if not i then return nil end
    -- consider action just pressed as click
    if i.justPressedAction and i.justPressedAction() then
        return true
    end
    return nil
end

function input.state()
    local i = _loadInterface()
    if not i then return 'idle' end
    if i.isActionDown and i.isActionDown() and not lockClick then
        lockClick = true
        return 'pressed'
    elseif i.isActionDown and i.isActionDown() and lockClick then
        return 'held'
    elseif not (i.isActionDown and i.isActionDown()) and lockClick then
        lockClick = false
        return 'released'
    else
        return 'idle'
    end
end

function input.justPressed()
    local i = _loadInterface()
    return i and i.justPressedAction and i.justPressedAction() or false
end

function input.justReleased()
    local i = _loadInterface()
    return i and i.justReleasedAction and i.justReleasedAction() or false
end

return input
