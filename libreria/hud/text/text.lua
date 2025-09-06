-- libreria/hud/text/text.lua
-- Small text helper component
local Text = {}
local draw = require("libreria.hud.draw")

--[[
Description: Small helper to render text.
@param position table|nil Position {x,y} or {x=..., y=...}. If nil, {0,0}.
@param text string|nil Text to display
@param fontSize number|nil Font size (default 14)
@param color table|nil Color {r,g,b,a} (default {1,1,1,1})
@return table instance: methods -> setText(t), draw()
]]
function Text.new(position, text, fontSize, color)
    local x, y = 0, 0
    if type(position) == 'table' then
        x = position.x or position[1] or 0
        y = position.y or position[2] or 0
    elseif type(position) == 'number' then
        x = position
        y = 0
    end

    local textObj = {
        x = x,
        y = y,
        text = text or "",
        fontSize = fontSize or 14,
        color = color or { 1, 1, 1, 1 }
    }

    function textObj.setText(t) textObj.text = tostring(t) end

    function textObj.draw()
        local r, g, b, a = draw.getColor()
        draw.setColor(textObj.color[1] or 1, textObj.color[2] or 1, textObj.color[3] or 1, textObj.color[4] or 1)
        local f = require("libreria/tools/resource_cache").font(textObj.fontSize)
        if love and love.graphics and love.graphics.setFont then love.graphics.setFont(f) end
        draw.print(textObj.text, textObj.x, textObj.y)
        draw.setColor(r, g, b, a)
    end

    return textObj
end

return Text
