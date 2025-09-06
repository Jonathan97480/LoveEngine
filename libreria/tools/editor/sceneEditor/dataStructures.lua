-- dataStructures.lua
-- Structures de données pour l'éditeur de scènes

local dataStructures = {}
local config = require("libreria.tools.editor.sceneEditor.config")

-- Structure d'une scène
function dataStructures.createNewScene(name)
    return {
        name = name or "Nouvelle Scene",
        width = config.EDITOR_CONFIG.DEFAULT_SCENE_SIZE.width,
        height = config.EDITOR_CONFIG.DEFAULT_SCENE_SIZE.height,
        layers = {
            {
                id = 1,
                name = "Background",
                visible = true,
                locked = false,
                elements = {}
            }
        },
        metadata = {
            created = os.date("%Y-%m-%d %H:%M:%S"),
            modified = os.date("%Y-%m-%d %H:%M:%S"),
            version = "1.0"
        }
    }
end

-- Structure d'un élément
function dataStructures.createElement(type, x, y)
    local element = {
        id = love.math.random(1000000),
        type = type,
        x = x or 0,
        y = y or 0,
        width = config.EDITOR_CONFIG.ELEMENT_SIZE,
        height = config.EDITOR_CONFIG.ELEMENT_SIZE,
        rotation = 0,
        scaleX = 1.0,
        scaleY = 1.0,
        visible = true,
        properties = {}
    }

    -- Propriétés spécifiques selon le type
    if type == config.ELEMENT_TYPES.BACKGROUND then
        element.properties = {
            image = nil,
            color = { 1, 1, 1, 1 },
            stretch = true
        }
    elseif type == config.ELEMENT_TYPES.SPRITE then
        element.properties = {
            image = nil,
            color = { 1, 1, 1, 1 }
        }
    elseif type == config.ELEMENT_TYPES.TEXT then
        element.properties = {
            text = "Nouveau texte",
            font = "default",
            fontSize = 16,
            color = { 1, 1, 1, 1 },
            align = "left"
        }
    elseif type == config.ELEMENT_TYPES.BUTTON then
        element.properties = {
            text = "Bouton",
            normalColor = { 0.5, 0.5, 0.5, 1 },
            hoverColor = { 0.7, 0.7, 0.7, 1 },
            pressedColor = { 0.3, 0.3, 0.3, 1 },
            callback = nil
        }
    elseif type == config.ELEMENT_TYPES.PANEL then
        element.properties = {
            backgroundColor = { 0.2, 0.2, 0.2, 0.8 },
            borderColor = { 0.5, 0.5, 0.5, 1 },
            borderWidth = 2
        }
    end

    return element
end

return dataStructures
