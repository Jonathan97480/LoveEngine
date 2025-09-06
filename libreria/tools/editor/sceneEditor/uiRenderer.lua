-- uiRenderer.lua
-- Rendu de l'interface utilisateur pour l'éditeur de scènes

local uiRenderer = {}
local config = require("libreria.tools.editor.sceneEditor.config")
local utils = require("libreria.tools.editor.sceneEditor.utils")
local resizeSystem = require("libreria.tools.editor.sceneEditor.resizeSystem")

-- NOUVEAU: Utilisation des modules HUD standardisés
local hud = _G.hud or require("libreria.hud.hud")

-- Variables d'état (seront définies depuis le module principal)
local currentScene = nil
local selectedLayer = 1
local selectedElement = nil
local showLayerPanel = false
local showElementPanel = false
local showLayerPropertiesPanel = false

-- NOUVEAU: Instances des éléments HUD
local mainToolbar = nil
local layerPropertiesPanel = nil
local elementPropertiesPanel = nil
local layerListPanel = nil

-- Variables pour le curseur clignotant (conservées pour compatibilité)
local cursorBlinkTimer = 0
local cursorVisible = true
local CURSOR_BLINK_RATE = 0.5 -- secondes

-- Dessin de la barre d'outils (NOUVEAU: utilise le module HUD standardisé)
function uiRenderer.drawToolbar()
    -- Initialiser la toolbar si nécessaire
    if not mainToolbar then
        mainToolbar = hud.createToolbar(0, 0, love.graphics.getWidth())
        mainToolbar:setTitle("Éditeur de Scène - " .. (currentScene and currentScene.name or "Aucune scène"))

        -- Ajouter les boutons standards
        mainToolbar:addButton("Nouveau", function()
            _G.globalFunction.log.info("Bouton Nouveau cliqué")
            -- TODO: Implémenter la logique nouveau projet
        end)

        mainToolbar:addButton("Sauvegarder", function()
            _G.globalFunction.log.info("Bouton Sauvegarder cliqué")
            -- TODO: Implémenter la logique de sauvegarde
        end)

        mainToolbar:addButton("Charger", function()
            _G.globalFunction.log.info("Bouton Charger cliqué")
            -- TODO: Implémenter la logique de chargement
        end)
    end

    -- Mettre à jour le titre si la scène a changé
    if currentScene then
        mainToolbar:setTitle("Éditeur de Scène - " .. currentScene.name)
    end

    -- Dessiner la toolbar
    mainToolbar:draw()
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
function uiRenderer.drawElement(element, isSelectedLayer, layerAlpha)
    local x, y = utils.worldToScreen(element.x, element.y)
    y = y + config.EDITOR_CONFIG.TOOLBAR_HEIGHT -- Décalage sous la barre d'outils
    local w, h = element.width * config.editorState.zoom, element.height * config.editorState.zoom

    -- Couleur selon l'état avec alpha du calque
    layerAlpha = layerAlpha or 1.0

    if element == selectedElement then
        love.graphics.setColor(1, 1, 0, layerAlpha)       -- Jaune pour sélectionné
    elseif isSelectedLayer then
        love.graphics.setColor(1, 1, 1, layerAlpha)       -- Blanc pour calque actif
    else
        love.graphics.setColor(0.7, 0.7, 0.7, layerAlpha) -- Gris pour autres calques
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

    -- Fond de la scène (utilise la couleur du calque actif si disponible)
    local bgColor = { 0.1, 0.1, 0.1, 1 } -- Couleur par défaut
    if currentScene.layers[selectedLayer] and currentScene.layers[selectedLayer].backgroundColor then
        local layerColor = currentScene.layers[selectedLayer].backgroundColor
        local layerAlpha = currentScene.layers[selectedLayer].alpha or 1.0
        bgColor = {
            layerColor.r or 0.1,
            layerColor.g or 0.1,
            layerColor.b or 0.1,
            (layerColor.a or 1) * layerAlpha
        }
    end
    love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])

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
                uiRenderer.drawElement(element, i == selectedLayer, layer.alpha or 1.0)
            end
        end
    end

    -- Dessiner les poignées de redimensionnement
    resizeSystem.drawResizeHandles(currentScene)
end

-- Dessin des panneaux (NOUVEAU: utilise le module HUD standardisé)
function uiRenderer.drawPanels()
    local panelX = love.graphics.getWidth() - config.EDITOR_CONFIG.PANEL_WIDTH
    local panelY = config.EDITOR_CONFIG.TOOLBAR_HEIGHT

    -- Panneau des calques
    if showLayerPanel then
        if not layerListPanel then
            layerListPanel = hud.createPropertiesPanel(panelX, panelY, config.EDITOR_CONFIG.PANEL_WIDTH, 200,
                "Calques")
            -- Initialiser les propriétés des calques
            uiRenderer.updateLayerListPanel()
        end
        layerListPanel:draw()
    end

    -- Panneau des propriétés d'élément
    if showElementPanel and selectedElement then
        if not elementPropertiesPanel then
            elementPropertiesPanel = hud.createPropertiesPanel(panelX, panelY + 220, config.EDITOR_CONFIG.PANEL_WIDTH,
                300, "Propriétés")
            -- Initialiser les propriétés de l'élément
            uiRenderer.updateElementPropertiesPanel()
        end
        elementPropertiesPanel:draw()
    end

    -- Panneau des propriétés du calque
    if showLayerPropertiesPanel and currentScene and currentScene.layers[selectedLayer] then
        if not layerPropertiesPanel then
            layerPropertiesPanel = hud.createPropertiesPanel(panelX, panelY, config.EDITOR_CONFIG.PANEL_WIDTH, 250,
                "Propriétés du calque")
            -- Initialiser les propriétés du calque
            uiRenderer.updateLayerPropertiesPanel()
        end
        layerPropertiesPanel:draw()
    end
end

-- Fonctions helper pour mettre à jour les panneaux
function uiRenderer.updateLayerListPanel()
    if not layerListPanel then return end

    layerListPanel.properties = {}
    if currentScene then
        for i, layer in ipairs(currentScene.layers) do
            local layerName = (i == selectedLayer) and ("→ " .. layer.name) or layer.name
            layerListPanel:addTextProperty("Calque " .. i, layerName, false)
        end
    end
end

function uiRenderer.updateElementPropertiesPanel()
    if not elementPropertiesPanel or not selectedElement then return end

    elementPropertiesPanel.properties = {}

    elementPropertiesPanel:addTextProperty("Type", selectedElement.type, false)
    elementPropertiesPanel:addTextProperty("Position X", tostring(selectedElement.x), false)
    elementPropertiesPanel:addTextProperty("Position Y", tostring(selectedElement.y), false)
    elementPropertiesPanel:addTextProperty("Largeur", tostring(selectedElement.width), false)
    elementPropertiesPanel:addTextProperty("Hauteur", tostring(selectedElement.height), false)

    -- Propriétés spécifiques selon le type d'élément
    if selectedElement.type == config.ELEMENT_TYPES.TEXT and selectedElement.properties then
        elementPropertiesPanel:addTextProperty("Texte", selectedElement.properties.text or "", true)
        if selectedElement.properties.color then
            elementPropertiesPanel:addColorProperty("Couleur",
                selectedElement.properties.color[1] or 1,
                selectedElement.properties.color[2] or 1,
                selectedElement.properties.color[3] or 1,
                selectedElement.properties.color[4] or 1)
        end
    end
end

function uiRenderer.updateLayerPropertiesPanel()
    if not layerPropertiesPanel or not currentScene or not currentScene.layers[selectedLayer] then return end

    local layer = currentScene.layers[selectedLayer]
    layerPropertiesPanel.properties = {}

    layerPropertiesPanel:addTextProperty("Nom", layer.name, true)
    layerPropertiesPanel:addBooleanProperty("Visible", layer.visible)
    layerPropertiesPanel:addBooleanProperty("Verrouillé", layer.locked)
    layerPropertiesPanel:addSliderProperty("Alpha", layer.alpha or 1.0, function(value)
        layer.alpha = value
        _G.globalFunction.log.info("Alpha du calque modifié: " .. value)
    end)

    if layer.backgroundColor then
        layerPropertiesPanel:addColorProperty("Couleur",
            layer.backgroundColor.r or 0.5,
            layer.backgroundColor.g or 0.5,
            layer.backgroundColor.b or 0.5,
            layer.backgroundColor.a or 1,
            function(r, g, b, a)
                layer.backgroundColor.r = r
                layer.backgroundColor.g = g
                layer.backgroundColor.b = b
                layer.backgroundColor.a = a
                _G.globalFunction.log.info("Couleur du calque modifiée: " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
            end)
    end

    layerPropertiesPanel:addTextProperty("Éléments", tostring(#layer.elements), false)
end

-- Fonction principale de rendu
function uiRenderer.draw()
    uiRenderer.drawToolbar()
    uiRenderer.drawGrid()
    uiRenderer.drawScene()
    uiRenderer.drawPanels()

    -- Informations de débogage
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print(
        "F1: Calques | F2: Propriétés élément | F3: Propriétés calque | G: Grille | Ctrl+N: Nouveau | Ctrl+S: Sauvegarder",
        10,
        love.graphics.getHeight() - 20)
end

-- Setters pour les variables d'état
function uiRenderer.setCurrentScene(scene)
    currentScene = scene
end

function uiRenderer.setSelectedLayer(layer)
    selectedLayer = layer
    -- Masquer tous les autres calques pour se concentrer sur le calque actif
    if currentScene then
        for i, otherLayer in ipairs(currentScene.layers) do
            if i ~= layer then
                otherLayer.visible = false
            else
                otherLayer.visible = true
            end
        end
    end
    -- Mettre à jour les panneaux
    uiRenderer.updateLayerListPanel()
    uiRenderer.updateLayerPropertiesPanel()
end

function uiRenderer.setSelectedElement(element)
    selectedElement = element
    -- Mettre à jour le panneau des propriétés de l'élément
    uiRenderer.updateElementPropertiesPanel()
end

function uiRenderer.setShowLayerPanel(show)
    showLayerPanel = show
    if show then
        uiRenderer.updateLayerListPanel()
    end
end

function uiRenderer.setShowElementPanel(show)
    showElementPanel = show
    if show then
        uiRenderer.updateElementPropertiesPanel()
    end
end

function uiRenderer.setShowLayerPropertiesPanel(show)
    showLayerPropertiesPanel = show
    if show then
        uiRenderer.updateLayerPropertiesPanel()
    end
end

function uiRenderer.setEditingLayerName(editing)
    editingLayerName = editing
    if not editing then
        cursorVisible = false
        cursorBlinkTimer = 0
    end
end

function uiRenderer.setLayerNameInput(input)
    layerNameInput = input
end

-- Fonction de mise à jour pour le curseur clignotant
function uiRenderer.update(dt)
    if editingLayerName then
        cursorBlinkTimer = cursorBlinkTimer + dt
        if cursorBlinkTimer >= CURSOR_BLINK_RATE then
            cursorVisible = not cursorVisible
            cursorBlinkTimer = 0
        end
    else
        cursorVisible = false
        cursorBlinkTimer = 0
    end

    -- Mettre à jour les panneaux HUD
    if mainToolbar then
        mainToolbar:update(dt)
    end
    if layerPropertiesPanel then
        layerPropertiesPanel:update(dt)
    end
    if elementPropertiesPanel then
        elementPropertiesPanel:update(dt)
    end
end

-- Gestion des clics souris pour les panneaux HUD
function uiRenderer.mousepressed(x, y, button)
    _G.globalFunction.log.info("uiRenderer.mousepressed appelé: x=" .. x .. ", y=" .. y .. ", button=" .. button)
    -- Déléguer aux panneaux HUD
    if mainToolbar and mainToolbar:mousepressed(x, y, button) then
        _G.globalFunction.log.info("Clic géré par mainToolbar")
        return true
    end
    if layerPropertiesPanel and layerPropertiesPanel:mousepressed(x, y, button) then
        _G.globalFunction.log.info("Clic géré par layerPropertiesPanel")
        -- Sauvegarder les modifications du calque
        if currentScene and currentScene.layers[selectedLayer] then
            local layer = currentScene.layers[selectedLayer]
            _G.globalFunction.log.info("Sauvegarde des propriétés pour le calque: " .. layer.name)
            for _, prop in ipairs(layerPropertiesPanel.properties) do
                _G.globalFunction.log.info("Traitement propriété: " ..
                    prop.type .. " - " .. prop.label .. " = " .. tostring(prop.value))
                if prop.type == "text" and prop.label == "Nom" then
                    layer.name = prop.value
                    _G.globalFunction.log.info("Nom du calque modifié: " .. prop.value)
                elseif prop.type == "boolean" and prop.label == "Visible" then
                    layer.visible = prop.value
                    _G.globalFunction.log.info("Visibilité du calque modifiée: " .. tostring(prop.value))
                elseif prop.type == "boolean" and prop.label == "Verrouillé" then
                    layer.locked = prop.value
                    _G.globalFunction.log.info("Verrouillage du calque modifié: " .. tostring(prop.value))
                elseif prop.type == "slider" and prop.label == "Alpha" then
                    layer.alpha = prop.value
                    _G.globalFunction.log.info("Alpha du calque modifié: " .. prop.value)
                elseif prop.type == "color" and prop.label == "Couleur" then
                    if not layer.backgroundColor then layer.backgroundColor = {} end
                    layer.backgroundColor.r = prop.value.r
                    layer.backgroundColor.g = prop.value.g
                    layer.backgroundColor.b = prop.value.b
                    layer.backgroundColor.a = prop.value.a
                    _G.globalFunction.log.info("Couleur du calque modifiée: " ..
                        prop.value.r .. ", " .. prop.value.g .. ", " .. prop.value.b .. ", " .. prop.value.a)
                end
            end
        else
            _G.globalFunction.log.info("Pas de scène ou calque sélectionné")
        end
        -- Mettre à jour le panneau après les modifications
        uiRenderer.updateLayerPropertiesPanel()
        return true
    end
    if elementPropertiesPanel and elementPropertiesPanel:mousepressed(x, y, button) then
        -- Sauvegarder les modifications de l'élément
        if selectedElement then
            for _, prop in ipairs(elementPropertiesPanel.properties) do
                if prop.type == "text" and prop.label == "Texte" then
                    if not selectedElement.properties then selectedElement.properties = {} end
                    selectedElement.properties.text = prop.value
                end
            end
        end
        return true
    end
    if layerListPanel and layerListPanel:mousepressed(x, y, button) then
        _G.globalFunction.log.info("Clic géré par layerListPanel")
        -- Gérer la sélection de calque
        if currentScene then
            local propY = layerListPanel.y + 30 -- Position de départ des propriétés
            for i, prop in ipairs(layerListPanel.properties) do
                if x >= layerListPanel.x + 10 and x <= layerListPanel.x + layerListPanel.width - 10 and
                    y >= propY - 5 and y <= propY + 20 then
                    -- Extraire l'index du calque depuis le label
                    local layerIndex = tonumber(prop.label:match("Calque (%d+)"))
                    if layerIndex and layerIndex >= 1 and layerIndex <= #currentScene.layers then
                        selectedLayer = layerIndex
                        _G.globalFunction.log.info("Calque sélectionné: " ..
                            currentScene.layers[layerIndex].name .. " (index: " .. layerIndex .. ")")
                        -- Masquer tous les autres calques pour se concentrer sur le calque actif
                        for j, otherLayer in ipairs(currentScene.layers) do
                            if j ~= layerIndex then
                                otherLayer.visible = false
                            else
                                otherLayer.visible = true
                            end
                        end
                        uiRenderer.updateLayerListPanel()
                        uiRenderer.updateLayerPropertiesPanel()
                        break
                    end
                end
                propY = propY + layerListPanel.config.lineHeight
            end
        end
        return true
    end
    return false
end

-- Gestion de la saisie de texte pour les panneaux HUD
function uiRenderer.textinput(text)
    -- Déléguer aux panneaux HUD
    if layerPropertiesPanel then
        layerPropertiesPanel:textinput(text)
    end
    if elementPropertiesPanel then
        elementPropertiesPanel:textinput(text)
    end
end

-- Gestion des touches pour les panneaux HUD
function uiRenderer.keypressed(key)
    -- Déléguer aux panneaux HUD
    if layerPropertiesPanel then
        layerPropertiesPanel:keypressed(key)
    end
    if elementPropertiesPanel then
        elementPropertiesPanel:keypressed(key)
    end
end

return uiRenderer
