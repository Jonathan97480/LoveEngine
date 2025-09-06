-- libreria/hud/draw.lua
-- Small wrapper around love.graphics to centralize calls and make testing/linting easier.
local M = {}

function M.setColor(r, g, b, a)
    if love and love.graphics and love.graphics.setColor then
        love.graphics.setColor(r, g, b, a)
    end
end

function M.getColor()
    if love and love.graphics and love.graphics.getColor then
        return love.graphics.getColor()
    end
    return 1, 1, 1, 1
end

function M.rectangle(mode, x, y, w, h)
    if love and love.graphics and love.graphics.rectangle then
        love.graphics.rectangle(mode, x, y, w, h)
    end
end

function M.print(text, x, y)
    if love and love.graphics and love.graphics.print then
        love.graphics.print(text, x, y)
    end
end

function M.circle(mode, x, y, r)
    if love and love.graphics and love.graphics.circle then
        love.graphics.circle(mode, x, y, r)
    end
end

function M.line(...) if love and love.graphics and love.graphics.line then love.graphics.line(...) end end

return M
