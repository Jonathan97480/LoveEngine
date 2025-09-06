-- libreria/hud/slider/slider.lua
-- Simple horizontal slider component
local Slider = {}
local draw = require("libreria.hud.draw")

--[[
Description: Crée un slider horizontal.
@param position table|nil Position {x,y} ou {x=..., y=...}. Si nil, {0,0}.
@param w number|nil Largeur (défaut 200)
@param h number|nil Hauteur (défaut 16)
@param min number|nil Valeur minimale (défaut 0)
@param max number|nil Valeur maximale (défaut 1)
@param value number|nil Valeur initiale (défaut 0)
@param onChange function|nil Callback appelé lors du changement: onChange(value)
@return table instance: méthodes -> update(dt), draw(), mousepressed(mx,my), mousereleased(mx,my), setValue(v), getRatio()
]]
function Slider.new(position, w, h, min, max, value, onChange)
    local x, y = 0, 0
    if type(position) == 'table' then
        x = position.x or position[1] or 0
        y = position.y or position[2] or 0
    elseif type(position) == 'number' then
        x = position
        y = 0
    end

    local slider = {
        x = x,
        y = y,
        w = w or 200,
        h = h or 16,
        min = (min ~= nil) and min or 0,
        max = (max ~= nil) and max or 1,
        value = (value ~= nil) and value or 0,
        onChange = onChange,
        _dragging = false,
    }

    local function clamp(v) return math.max(slider.min, math.min(slider.max, v)) end

    function slider.getRatio()
        return (slider.value - slider.min) / (slider.max - slider.min)
    end

    function slider.setValue(v)
        local nv = clamp(v)
        if nv ~= slider.value then
            slider.value = nv
            if type(slider.onChange) == 'function' then slider.onChange(slider.value) end
        end
    end

    function slider.update(dt)
        if slider._dragging then
            local mx = love.mouse.getX()
            local r = (mx - slider.x) / slider.w
            slider.setValue(slider.min + r * (slider.max - slider.min))
        end
    end

    function slider.draw()
        local r, g, b, a = draw.getColor()
        draw.setColor(0.2, 0.2, 0.2, 1)
        draw.rectangle('fill', slider.x, slider.y + slider.h / 4, slider.w, slider.h / 2)
        local rx = slider.x + slider.getRatio() * slider.w
        draw.setColor(0.8, 0.8, 0.8, 1)
        draw.circle('fill', rx, slider.y + slider.h / 2, slider.h)
        draw.setColor(r, g, b, a)
    end

    function slider.mousepressed(mx, my)
        if mx >= slider.x and mx <= slider.x + slider.w and my >= slider.y and my <= slider.y + slider.h then
            slider._dragging = true
        end
    end

    function slider.mousereleased(mx, my)
        slider._dragging = false
    end

    return slider
end

return Slider
