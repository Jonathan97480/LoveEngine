-- libreria/hud/button/button.lua
-- Simple Button component
local Button = {}
local draw = require("libreria.hud.draw")

--[[
Description: Crée un bouton cliquable pour le HUD.
@param position table|nil Position {x,y} ou {x=..., y=...}. Si nil, {0,0}.
@param w number|nil Largeur (défaut 100)
@param h number|nil Hauteur (défaut 40)
@param text string|nil Texte du bouton
@param onClick function|nil Callback appelé lors du clic: onClick(button)
@param opts table|nil Options optionnelles { bg = {...}, hoverBg = {...} }
@return table instance: méthodes -> update(dt), draw(), onMousePressed(mx,my), isInside(mx,my)
]]
function Button.new(position, w, h, text, onClick, opts)
    opts = opts or {}
    local x, y = 0, 0
    if type(position) == 'table' then
        x = position.x or position[1] or 0
        y = position.y or position[2] or 0
    elseif type(position) == 'number' then
        x = position
        y = 0
    end

    local button = {
        x = x,
        y = y,
        w = w or 100,
        h = h or 40,
        text = text or "",
        onClick = onClick,
        bg = opts.bg or { 0.2, 0.2, 0.2, 1 },
        hoverBg = opts.hoverBg or { 0.3, 0.3, 0.3, 1 },
        _hover = false,
    }

    function button.isInside(mx, my)
        return mx >= button.x and my >= button.y and mx <= button.x + button.w and my <= button.y + button.h
    end

    function button.update(dt)
        local mx, my = love.mouse.getPosition()
        button._hover = button.isInside(mx, my)
    end

    function button.draw()
        local r, g, b, a = draw.getColor()
        draw.setColor(button._hover and button.hoverBg or button.bg)
        draw.rectangle('fill', button.x, button.y, button.w, button.h)
        draw.setColor(r, g, b, a)
        draw.print(button.text, button.x + 8, button.y + 8)
    end

    function button.onMousePressed(mx, my)
        if button.isInside(mx, my) and type(button.onClick) == 'function' then button.onClick(button) end
    end

    return button
end

return Button
