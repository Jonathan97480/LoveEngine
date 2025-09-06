Button component

Usage:
local Button = require("my-librairie.hud.button.button")
local b = Button.new({ x=10, y=10, text = "Click", onClick = function(self) print('clicked') end })
function love.update(dt) b.update(dt) end
function love.draw() b.draw() end
function love.mousepressed(x,y,button) b.onMousePressed(x,y) end

Purpose: basic clickable button for HUD.
