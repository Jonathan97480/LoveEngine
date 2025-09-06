-- libreria/tools/inputInterface.lua
-- Interface unifiée pour les entrées : souris ou manette
local I = {}

local joystick = nil
local prevAction = false
local prevMouse = false
local cursor = { x = 0, y = 0 }
local activeSource = 'mouse'
local deadzone = 0.3
local sensitivity = 800 -- pixels per second for full axis

local function clamp(v, a, b)
    if v < a then return a end
    if v > b then return b end
    return v
end

function I.init()
    -- initialize cursor from screen mouse or love mouse
    if rawget(_G, "screen") and screen.mouse and screen.mouse.X then
        cursor.x, cursor.y = screen.mouse.X, screen.mouse.Y
    else
        local mx, my
        if rawget(_G, "love") and love.mouse and love.mouse.getPosition then
            mx, my = love.mouse.getPosition()
        end
        if mx then
            -- convert window coords to game-space if screen.ratioScreen is available
            if rawget(_G, "screen") and screen.ratioScreen and screen.ratioScreen.width and screen.ratioScreen.height then
                cursor.x = mx / screen.ratioScreen.width
                cursor.y = my / screen.ratioScreen.height
            else
                cursor.x, cursor.y = mx, my
            end
        end
    end
end

function I.update(dt)
    -- detect joystick
    local joysticks = {}
    local list
    if rawget(_G, "love") and love.joystick and love.joystick.getJoysticks then
        list = love.joystick.getJoysticks()
    end
    if type(list) == 'table' and #list > 0 then
        joystick = list[1]
    else
        joystick = nil
    end

    -- read axes if joystick
    local ax, ay = 0, 0
    if joystick then
        if joystick.getAxes then
            local axes = { joystick:getAxes() }
            if type(axes) == 'table' and #axes >= 2 then
                ax, ay = axes[1] or 0, axes[2] or 0
            else
                ax, ay = 0, 0
            end
        else
            ax, ay = 0, 0
        end
    end

    -- if joystick moved beyond deadzone, switch to gamepad and move cursor
    if math.abs(ax) > deadzone or math.abs(ay) > deadzone then
        activeSource = 'gamepad'
        cursor.x = cursor.x + ax * sensitivity * (dt or 0.016)
        cursor.y = cursor.y + ay * sensitivity * (dt or 0.016)
    else
        -- fallback to mouse position (convert to game-space)
        local mx, my
        if rawget(_G, "love") and love.mouse and love.mouse.getPosition then
            mx, my = love.mouse.getPosition()
        end
        if mx then
            local gx, gy = mx, my
            if rawget(_G, "screen") and screen.ratioScreen and screen.ratioScreen.width and screen.ratioScreen.height then
                gx = mx / screen.ratioScreen.width
                gy = my / screen.ratioScreen.height
            end
            -- if mouse moved significantly, switch source
            if gx ~= cursor.x or gy ~= cursor.y then
                activeSource = 'mouse'
            end
            cursor.x, cursor.y = gx, gy
        end
    end

    -- clamp to game resolution if available
    if rawget(_G, "screen") and screen.gameReso then
        cursor.x = clamp(cursor.x, 0, screen.gameReso.width)
        cursor.y = clamp(cursor.y, 0, screen.gameReso.height)
    end

    -- action button state
    local actionDown = false
    -- mouse primary
    if rawget(_G, "love") and love.mouse and love.mouse.isDown then
        local mdown = love.mouse.isDown(1)
        if mdown then actionDown = actionDown or mdown end
    end
    -- gamepad A (if available)
    if joystick then
        local pressed = false
        if joystick.isGamepad and joystick:isGamepad() and joystick.isGamepadDown then
            pressed = joystick:isGamepadDown('a')
        end
        if pressed then actionDown = actionDown or pressed end
    end

    prevAction = prevAction or false
    I._lastAction = I._lastAction or false
    I._justPressed = (actionDown and not I._lastAction)
    I._justReleased = (not actionDown and I._lastAction)
    I._lastAction = actionDown
end

function I.getCursor()
    return { x = cursor.x, y = cursor.y, source = activeSource }
end

function I.isActionDown()
    return I._lastAction or false
end

function I.justPressedAction()
    return I._justPressed or false
end

function I.justReleasedAction()
    return I._justReleased or false
end

function I.getActiveSource()
    return activeSource
end

function I.GetKeyPressed()
    return love.keyboard.getKeyPressed()
end

I.init()
return I
