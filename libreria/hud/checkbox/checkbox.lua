-- libreria/hud/checkbox/checkbox.lua
-- Simple checkbox component
local Checkbox = {}
local draw = require("libreria.hud.draw")

--[[
Description: Crée une checkbox pour le HUD.
@param position table|nil Position sous la forme {x,y} ou {x=..., y=...}. Si nil, position = {0,0}.
@param size number|nil Taille du carré en pixels (défaut 20)
@param checked boolean|nil Etat initial (false par défaut)
@param onChange function|nil Callback appelé quand l'état change: onChange(checked)
@return table instance: méthodes -> toggle(), draw(), mousepressed(mx,my)
]]
function Checkbox.new(position, size, checked, onChange)
    -- supporte position comme table {x,y} ou {x=..., y=...}
    local x, y = 0, 0
    if type(position) == 'table' then
        x = position.x or position[1] or 0
        y = position.y or position[2] or 0
    elseif type(position) == 'number' then
        -- si un nombre est passé accidentellement, on l'utilise comme x
        x = position
        y = 0
    end

    local checkbox = {
        x = x,
        y = y,
        size = size or 20,
        checked = checked or false,
        onChange = onChange,
    }

    function checkbox.toggle()
        checkbox.checked = not checkbox.checked
        if type(checkbox.onChange) == 'function' then checkbox.onChange(checkbox.checked) end
    end

    function checkbox.draw()
        local r, g, b, a = draw.getColor()
        draw.setColor(1, 1, 1, 1)
        draw.rectangle('line', checkbox.x, checkbox.y, checkbox.size, checkbox.size)
        if checkbox.checked then
            draw.line(checkbox.x, checkbox.y, checkbox.x + checkbox.size, checkbox.y + checkbox.size)
            draw.line(checkbox.x + checkbox.size, checkbox.y, checkbox.x, checkbox.y + checkbox.size)
        end
        draw.setColor(r, g, b, a)
    end

    function checkbox.mousepressed(mx, my)
        if mx >= checkbox.x and mx <= checkbox.x + checkbox.size and my >= checkbox.y and my <= checkbox.y + checkbox.size then
            checkbox.toggle()
        end
    end

    return checkbox
end

return Checkbox
