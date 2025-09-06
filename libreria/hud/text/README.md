Text component

Usage:
local Text = require("my-librairie.hud.text.text")
local t = Text.new({ x=10, y=10, text = "Hello", fontSize = 18 })
function love.draw() t.draw() end

Purpose: small helper to render text with an own font size.
