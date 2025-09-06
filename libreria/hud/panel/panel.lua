-- libreria/hud/panel/panel.lua
-- Simple Panel component for HUD
local Panel = {}
local draw = require("libreria.hud.draw")

--[[
Description: Crée un panneau (container) pour le HUD.
@param position table|nil Position {x,y} ou {x=..., y=...}. Si nil, {0,0}.
@param w number|nil Largeur (defaut 200)
@param h number|nil Hauteur (defaut 100)
@param bg table|nil Couleur de fond {r,g,b,a} (defaut {0,0,0,0.6})
@param children table|nil Table d'enfants (defaut {})
@return table instance: methodes -> draw(), setPosition(x,y), setSize(w,h), add(child)
]]
function Panel.new(position, w, h, bg, children)
    local x, y = 0, 0
    if type(position) == 'table' then
        x = position.x or position[1] or 0
        y = position.y or position[2] or 0
    elseif type(position) == 'number' then
        x = position
        y = 0
    end

    local panel = {
        x = x,
        y = y,
        w = w or 200,
        h = h or 100,
        bg = bg or { 0, 0, 0, 0.6 },
        children = children or {},
    }

    function panel.draw()
        -- save current color and restore later
        local r, g, b, a = draw.getColor()

        -- apply background color (support table or individual values)
        local bgc = panel.bg or { 1, 1, 1, 1 }
        if type(bgc) == 'table' then
            draw.setColor(bgc[1] or 1, bgc[2] or 1, bgc[3] or 1, bgc[4] or 1)
        else
            draw.setColor(bgc)
        end

        draw.rectangle("fill", panel.x, panel.y, panel.w, panel.h)

        -- restore color for children drawing
        draw.setColor(r, g, b, a)

        for _, c in ipairs(panel.children) do
            if type(c.draw) == 'function' then c.draw() end
        end
    end

    function panel.setPosition(x, y)
        panel.x = x; panel.y = y
    end

    function panel.setSize(w, h)
        panel.w = w; panel.h = h
    end

    function panel.add(child) table.insert(panel.children, child) end

    return panel
end

return Panel
