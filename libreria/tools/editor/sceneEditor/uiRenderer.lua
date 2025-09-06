-- uiRenderer.lua
-- Rendu de l'interface utilisateur pour l'éditeur de scènes

local uiRenderer = {}
local config = require("libreria.tools.editor.sceneEditor.config")
local utils = require("libreria.tools.editor.sceneEditor.utils")
local resizeSystem = require("libreria.tools.editor.sceneEditor.resizeSystem")

-- Variables d'état (seront définies depuis le module principal)
local currentScene = nil
local selectedLayer = 1
local selectedElement = nil
local showLayerPanel = false
local showElementPanel = false

-- Dessin de la barre d'outils
function uiRenderer.drawToolbar()
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), config.EDITOR_CONFIG.TOOLBAR_HEIGHT)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Éditeur de Scène - " .. (currentScene and currentScene.name or "Aucune scène"), 10, 10)

    -- Boutons d'outils
    local buttonY = 5
    local buttonWidth = 60
    local buttonHeight = 30

    -- Bouton Nouveau
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("fill", 300, buttonY, buttonWidth, buttonHeight)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Nouveau", 305, buttonY + 8)

    -- Bouton Sauvegarder
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("fill", 370, buttonY, buttonWidth, buttonHeight)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Save", 385, buttonY + 8)

    -- Bouton Charger
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("fill", 440, buttonY, buttonWidth, buttonHeight)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Load", 455, buttonY + 8)
end

-- Dessin de la grille
function uiRenderer.drawGrid()
    if not config.editorState.gridVisible then return end

    love.graphics.setColor(0.2, 0.2, 0.2, 0.3)
    local gridSize = config.EDITOR_CONFIG.SNAP_GRID * config.editorState.zoom

    -- Lignes verticales (décalées sous la barre d'outils)
    for x = config.editorState.panX % gridSize, love.graphics.getWidth(), gridSize do
        love.graphics.line(x, config.EDITOR_CONFIG.TOOLBAR_HEIGHT, x, love.graphics.getHeight())
    end

    -- Lignes horizontales (décalées sous la barre d'outils)
    for y = (config.editorState.panY + config.EDITOR_CONFIG.TOOLBAR_HEIGHT) % gridSize, love.graphics.getHeight(), gridSize do
        love.graphics.line(0, y, love.graphics.getWidth(), y)
    end
end

-- Dessin d'un élément
function uiRenderer.drawElement(element, isSelectedLayer)
    local x, y = utils.worldToScreen(element.x, element.y)
    y = y + config.EDITOR_CONFIG.TOOLBAR_HEIGHT -- Décalage sous la barre d'outils
    local w, h = element.width * config.editorState.zoom, element.height * config.editorState.zoom

    -- Couleur selon l'état
    if element == selectedElement then
        love.graphics.setColor(1, 1, 0, 1)       -- Jaune pour sélectionné
    elseif isSelectedLayer then
        love.graphics.setColor(1, 1, 1, 1)       -- Blanc pour calque actif
    else
        love.graphics.setColor(0.7, 0.7, 0.7, 1) -- Gris pour autres calques
    end

    -- Dessiner selon le type d'élément
    if element.type == config.ELEMENT_TYPES.BACKGROUND then
        love.graphics.rectangle("fill", x, y, w, h)
    elseif element.type == config.ELEMENT_TYPES.SPRITE then
        love.graphics.rectangle("fill", x, y, w, h)
    elseif element.type == config.ELEMENT_TYPES.TEXT then
        love.graphics.rectangle("line", x, y, w, h)
        love.graphics.print(element.properties.text, x + 5, y + 5)
    elseif element.type == config.ELEMENT_TYPES.BUTTON then
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(element.properties.text, x + 10, y + h / 2 - 8)
    elseif element.type == config.ELEMENT_TYPES.PANEL then
        love.graphics.rectangle("fill", x, y, w, h)
    end

    -- Indicateur de sélection
    if element == selectedElement then
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.rectangle("line", x - 2, y - 2, w + 4, h + 4)
    end
end

-- Dessin de la scène
function uiRenderer.drawScene()
    if not currentScene then return end

    -- Fond de la scène (décalé sous la barre d'outils)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    local sceneX, sceneY = utils.worldToScreen(0, 0)
    sceneY = sceneY + config.EDITOR_CONFIG.TOOLBAR_HEIGHT -- Décalage sous la barre d'outils
    local sceneW, sceneH = currentScene.width * config.editorState.zoom, currentScene.height * config.editorState.zoom
    love.graphics.rectangle("fill", sceneX, sceneY, sceneW, sceneH)

    -- Bordure de la scène
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.rectangle("line", sceneX, sceneY, sceneW, sceneH)

    -- Dessiner les éléments de chaque calque
    for i, layer in ipairs(currentScene.layers) do
        if layer.visible then
            for j, element in ipairs(layer.elements) do
                uiRenderer.drawElement(element, i == selectedLayer)
            end
        end
    end

    -- Dessiner les poignées de redimensionnement
    resizeSystem.drawResizeHandles(currentScene)
end

-- Dessin des panneaux
function uiRenderer.drawPanels()
    local panelX = love.graphics.getWidth() - config.EDITOR_CONFIG.PANEL_WIDTH
    local panelY = config.EDITOR_CONFIG.TOOLBAR_HEIGHT

    -- Panneau des calques
    if showLayerPanel then
        love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
        love.graphics.rectangle("fill", panelX, panelY, config.EDITOR_CONFIG.PANEL_WIDTH, 200)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Calques", panelX + 10, panelY + 10)

        if currentScene then
            for i, layer in ipairs(currentScene.layers) do
                local layerY = panelY + 30 + (i - 1) * 25
                if i == selectedLayer then
                    love.graphics.setColor(0.5, 0.5, 0.5, 1)
                    love.graphics.rectangle("fill", panelX + 5, layerY, config.EDITOR_CONFIG.PANEL_WIDTH - 10, 20)
                end

                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.print(layer.name, panelX + 10, layerY + 2)
            end
        end
    end

    -- Panneau des propriétés d'élément
    if showElementPanel and selectedElement then
        love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
        love.graphics.rectangle("fill", panelX, panelY + 220, config.EDITOR_CONFIG.PANEL_WIDTH, 300)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Propriétés", panelX + 10, panelY + 230)

        local propY = panelY + 250
        love.graphics.print("Type: " .. selectedElement.type, panelX + 10, propY)
        love.graphics.print(string.format("Position: %.0f, %.0f", selectedElement.x, selectedElement.y), panelX + 10,
            propY + 20)
        love.graphics.print(string.format("Taille: %.0f x %.0f", selectedElement.width, selectedElement.height),
            panelX + 10, propY + 40)
    end
end

-- Fonction principale de rendu
function uiRenderer.draw()
    uiRenderer.drawToolbar()
    uiRenderer.drawGrid()
    uiRenderer.drawScene()
    uiRenderer.drawPanels()

    -- Informations de débogage
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print("F1: Calques | F2: Propriétés | G: Grille | Ctrl+N: Nouveau | Ctrl+S: Sauvegarder", 10,
        love.graphics.getHeight() - 20)
end

-- Setters pour les variables d'état
function uiRenderer.setCurrentScene(scene)
    currentScene = scene
end

function uiRenderer.setSelectedLayer(layer)
    selectedLayer = layer
end

function uiRenderer.setSelectedElement(element)
    selectedElement = element
end

function uiRenderer.setShowLayerPanel(show)
    showLayerPanel = show
end

function uiRenderer.setShowElementPanel(show)
    showElementPanel = show
end

return uiRenderer
