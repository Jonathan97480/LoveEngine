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

-- NOUVEAU: Conteneur principal pour les panneaux
local propertiesContainer = nil
local containerScrollOffset = 0
local containerMaxScroll = 0

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
    _G.globalFunction.log.info("drawElement appelé pour élément type: " ..
        (element.type or "unknown") .. ", position: " .. element.x .. "," .. element.y)
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

    -- Fond de la scène (taille fixe de la scène)
    love.graphics.setColor(0.05, 0.05, 0.05, 1)           -- Fond sombre pour la scène
    local sceneX, sceneY = utils.worldToScreen(0, 0)
    sceneY = sceneY + config.EDITOR_CONFIG.TOOLBAR_HEIGHT -- Décalage sous la barre d'outils
    local sceneW, sceneH = currentScene.width * config.editorState.zoom, currentScene.height * config.editorState.zoom
    love.graphics.rectangle("fill", sceneX, sceneY, sceneW, sceneH)

    -- Bordure de la scène (jaune pour indiquer la taille fixe)
    love.graphics.setColor(1, 1, 0, 0.5)
    love.graphics.rectangle("line", sceneX, sceneY, sceneW, sceneH)

    -- Dessiner les calques avec leurs propres dimensions
    for i, layer in ipairs(currentScene.layers) do
        if layer.visible then
            -- Position et taille du calque
            local layerX, layerY = utils.worldToScreen(layer.x, layer.y)
            layerY = layerY + config.EDITOR_CONFIG.TOOLBAR_HEIGHT
            local layerW, layerH = layer.width * config.editorState.zoom, layer.height * config.editorState.zoom

            -- Fond du calque
            if layer.backgroundColor then
                local layerColor = layer.backgroundColor
                local layerAlpha = layer.alpha or 1.0
                love.graphics.setColor(
                    layerColor.r or 0.1,
                    layerColor.g or 0.1,
                    layerColor.b or 0.1,
                    (layerColor.a or 1) * layerAlpha
                )
                love.graphics.rectangle("fill", layerX, layerY, layerW, layerH)
            end

            -- Bordure du calque (plus visible pour le calque sélectionné)
            if i == selectedLayer then
                love.graphics.setColor(1, 0, 0, 1)         -- Rouge pour le calque sélectionné
            else
                love.graphics.setColor(0.5, 0.5, 0.5, 0.5) -- Gris pour les autres calques
            end
            love.graphics.rectangle("line", layerX, layerY, layerW, layerH)

            -- Dessiner les éléments du calque
            for j, element in ipairs(layer.elements) do
                -- Ajuster la position des éléments par rapport au calque
                local adjustedElement = {
                    type = element.type,
                    x = element.x + layer.x,
                    y = element.y + layer.y,
                    width = element.width,
                    height = element.height,
                    rotation = element.rotation,
                    scaleX = element.scaleX,
                    scaleY = element.scaleY,
                    visible = element.visible,
                    properties = element.properties
                }
                uiRenderer.drawElement(adjustedElement, i == selectedLayer, layer.alpha or 1.0)
            end
        end
    end

    -- Dessiner les poignées de redimensionnement seulement pour le calque sélectionné
    resizeSystem.drawResizeHandles(currentScene, selectedLayer)
end

-- Dessin des panneaux (NOUVEAU: système de conteneur avec slider)
function uiRenderer.drawPanels()
    -- Créer le conteneur principal si nécessaire
    if not propertiesContainer then
        uiRenderer.createPropertiesContainer()
    end

    -- Dessiner le conteneur principal
    if propertiesContainer then
        propertiesContainer:draw()

        -- Dessiner la scrollbar si nécessaire
        if containerMaxScroll > 0 then
            uiRenderer.drawContainerScrollbar()
        end
    end
end

-- NOUVEAU: Créer le conteneur principal pour les panneaux
function uiRenderer.createPropertiesContainer()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local containerWidth = config.EDITOR_CONFIG.PANEL_WIDTH
    local containerHeight = screenHeight - config.EDITOR_CONFIG.TOOLBAR_HEIGHT

    -- Créer le conteneur principal (positionné en TOP LEFT)
    propertiesContainer = hud.createPanel(0, config.EDITOR_CONFIG.TOOLBAR_HEIGHT, containerWidth, containerHeight)
    propertiesContainer:setTitle("Propriétés")
    propertiesContainer:setBackgroundColor(0.15, 0.15, 0.15, 0.95)

    -- Initialiser le contenu du conteneur
    uiRenderer.updatePropertiesContainer()
end

-- NOUVEAU: Mettre à jour le contenu du conteneur
function uiRenderer.updatePropertiesContainer()
    if not propertiesContainer then return end

    -- Réinitialiser le contenu
    propertiesContainer.properties = {}
    local currentY = 10 -- Position Y de départ dans le conteneur

    -- 1. Panneau des calques
    if showLayerPanel then
        currentY = uiRenderer.addLayerPanelToContainer(currentY)
    end

    -- 2. Panneau des propriétés du calque
    if showLayerPropertiesPanel and currentScene and currentScene.layers[selectedLayer] then
        currentY = uiRenderer.addLayerPropertiesToContainer(currentY)
    end

    -- 3. Panneau des propriétés d'élément
    if showElementPanel and selectedElement then
        currentY = uiRenderer.addElementPropertiesToContainer(currentY)
    end

    -- Calculer la hauteur totale du contenu
    local contentHeight = currentY + 20
    local containerHeight = love.graphics.getHeight() - config.EDITOR_CONFIG.TOOLBAR_HEIGHT

    -- Mettre à jour le scroll maximum
    containerMaxScroll = math.max(0, contentHeight - containerHeight)

    -- Ajuster le scroll offset si nécessaire
    if containerScrollOffset > containerMaxScroll then
        containerScrollOffset = containerMaxScroll
    end
end

-- NOUVEAU: Ajouter le panneau des calques au conteneur
function uiRenderer.addLayerPanelToContainer(startY)
    local currentY = startY

    -- Titre du panneau
    propertiesContainer:addCustomProperty("Calques", function(x, y)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Calques", x, y + containerScrollOffset)
    end, 20)

    currentY = currentY + 25

    -- Bouton Nouveau calque
    propertiesContainer:addButtonProperty("Nouveau calque", function()
        _G.globalFunction.log.info("Bouton Nouveau calque cliqué")
        if _G.sceneEditor and _G.sceneEditor.addLayer then
            _G.sceneEditor.addLayer()
            uiRenderer.updatePropertiesContainer()
            _G.globalFunction.log.info("Nouveau calque ajouté depuis le conteneur")
        end
    end)

    currentY = currentY + 30

    -- Liste des calques
    if currentScene then
        for i, layer in ipairs(currentScene.layers) do
            local buttonText = layer.name
            if i == selectedLayer then
                buttonText = "▶ " .. buttonText .. " ◀"
            end

            propertiesContainer:addButtonProperty(buttonText, function()
                _G.globalFunction.log.info("Sélection du calque: " .. layer.name)
                uiRenderer.setSelectedLayer(i)
                uiRenderer.updatePropertiesContainer()
            end)

            currentY = currentY + 30
        end
    end

    return currentY + 10
end

-- NOUVEAU: Ajouter les propriétés du calque au conteneur
function uiRenderer.addLayerPropertiesToContainer(startY)
    local currentY = startY

    -- Titre du panneau
    propertiesContainer:addCustomProperty("Propriétés du calque", function(x, y)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Propriétés du calque", x, y + containerScrollOffset)
    end, 20)

    currentY = currentY + 25

    if currentScene and currentScene.layers[selectedLayer] then
        local layer = currentScene.layers[selectedLayer]

        propertiesContainer:addTextProperty("Nom", layer.name, true)
        currentY = currentY + 30

        propertiesContainer:addBooleanProperty("Visible", layer.visible)
        currentY = currentY + 30

        propertiesContainer:addBooleanProperty("Verrouillé", layer.locked)
        currentY = currentY + 30

        propertiesContainer:addSliderProperty("Alpha", layer.alpha or 1.0, function(value)
            layer.alpha = value
            _G.globalFunction.log.info("Alpha du calque modifié: " .. value)
        end)
        currentY = currentY + 40

        if layer.backgroundColor then
            propertiesContainer:addColorProperty("Couleur de fond",
                layer.backgroundColor.r or 0.1,
                layer.backgroundColor.g or 0.1,
                layer.backgroundColor.b or 0.1,
                layer.backgroundColor.a or 1.0)
            currentY = currentY + 40
        end
    end

    return currentY + 10
end

-- NOUVEAU: Ajouter les propriétés d'élément au conteneur
function uiRenderer.addElementPropertiesToContainer(startY)
    local currentY = startY

    -- Titre du panneau
    propertiesContainer:addCustomProperty("Propriétés d'élément", function(x, y)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Propriétés d'élément", x, y + containerScrollOffset)
    end, 20)

    currentY = currentY + 25

    if selectedElement then
        propertiesContainer:addTextProperty("Type", selectedElement.type, false)
        currentY = currentY + 30

        propertiesContainer:addTextProperty("Position X", tostring(selectedElement.x), false)
        currentY = currentY + 30

        propertiesContainer:addTextProperty("Position Y", tostring(selectedElement.y), false)
        currentY = currentY + 30

        propertiesContainer:addTextProperty("Largeur", tostring(selectedElement.width), false)
        currentY = currentY + 30

        propertiesContainer:addTextProperty("Hauteur", tostring(selectedElement.height), false)
        currentY = currentY + 30

        -- Propriétés spécifiques selon le type d'élément
        if selectedElement.type == config.ELEMENT_TYPES.TEXT and selectedElement.properties then
            propertiesContainer:addTextProperty("Texte", selectedElement.properties.text or "", true)
            currentY = currentY + 30

            if selectedElement.properties.color then
                propertiesContainer:addColorProperty("Couleur",
                    selectedElement.properties.color[1] or 1,
                    selectedElement.properties.color[2] or 1,
                    selectedElement.properties.color[3] or 1,
                    selectedElement.properties.color[4] or 1)
                currentY = currentY + 40
            end
        end
    end

    return currentY + 10
end

-- NOUVEAU: Dessiner la scrollbar du conteneur
function uiRenderer.drawContainerScrollbar()
    if not propertiesContainer then return end

    local containerX = propertiesContainer.x
    local containerY = propertiesContainer.y
    local containerWidth = propertiesContainer.width
    local containerHeight = propertiesContainer.height

    -- Fond de la scrollbar
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", containerX + containerWidth - 15, containerY, 15, containerHeight)

    -- Position de la scrollbar
    local scrollbarHeight = math.max(30, (containerHeight / (containerHeight + containerMaxScroll)) * containerHeight)
    local scrollbarY = containerY + (containerScrollOffset / containerMaxScroll) * (containerHeight - scrollbarHeight)

    -- Dessiner la scrollbar
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("fill", containerX + containerWidth - 12, scrollbarY, 9, scrollbarHeight)
end

-- Gestionnaire d'événements de souris pour le conteneur
function uiRenderer.handleContainerMouse(x, y, button)
    if not propertiesContainer then return false end

    local containerX = propertiesContainer.x
    local containerY = propertiesContainer.y
    local containerWidth = propertiesContainer.width
    local containerHeight = propertiesContainer.height

    -- Vérifier si le clic est dans le conteneur
    if x >= containerX and x <= containerX + containerWidth and
        y >= containerY and y <= containerY + containerHeight then
        -- Gérer la scrollbar
        if containerMaxScroll > 0 and x >= containerX + containerWidth - 15 then
            -- Calculer la position relative dans la scrollbar
            local relativeY = y - containerY
            local scrollRatio = relativeY / containerHeight
            containerScrollOffset = scrollRatio * containerMaxScroll
            containerScrollOffset = math.max(0, math.min(containerMaxScroll, containerScrollOffset))
            return true
        end

        return true
    end

    return false
end

-- Gestionnaire de la molette de la souris pour le scroll
function uiRenderer.handleContainerWheel(x, y)
    if not propertiesContainer then return false end

    local containerX = propertiesContainer.x
    local containerY = propertiesContainer.y
    local containerWidth = propertiesContainer.width
    local containerHeight = propertiesContainer.height

    -- Vérifier si la souris est dans le conteneur
    if x >= containerX and x <= containerX + containerWidth and
        y >= containerY and y <= containerY + containerHeight then
        -- Ajuster le scroll offset
        local scrollSpeed = 20
        containerScrollOffset = containerScrollOffset - y * scrollSpeed
        containerScrollOffset = math.max(0, math.min(containerMaxScroll, containerScrollOffset))
        return true
    end

    return false
end

-- Gestion des clics souris pour les panneaux HUD
function uiRenderer.mousepressed(x, y, button)
    _G.globalFunction.log.info("uiRenderer.mousepressed appelé: x=" .. x .. ", y=" .. y .. ", button=" .. button)

    -- Gérer les clics dans le conteneur de propriétés
    if uiRenderer.handleContainerMouse(x, y, button) then
        _G.globalFunction.log.info("Clic géré par le conteneur de propriétés")
        return true
    end

    -- Déléguer aux panneaux HUD (ancien système pour compatibilité)
    if mainToolbar and mainToolbar:mousepressed(x, y, button) then
        _G.globalFunction.log.info("Clic géré par mainToolbar")
        return true
    end

    return false
end

-- Gestionnaire de la molette de la souris
function uiRenderer.wheelmoved(x, y)
    -- Gérer le scroll dans le conteneur
    if uiRenderer.handleContainerWheel(x, y) then
        return true
    end

    return false
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
    -- Vérifier si le calque cible est verrouillé et n'est pas le calque actuel
    if currentScene and currentScene.layers[layer] then
        local targetLayer = currentScene.layers[layer]
        if targetLayer.locked and layer ~= selectedLayer then
            _G.globalFunction.log.info("Calque verrouillé - sélection impossible: " .. targetLayer.name)
            return -- Ne pas changer de calque
        end
    end

    -- Log avant la sélection
    if currentScene then
        _G.globalFunction.log.debug("Avant sélection - Calque " .. layer .. " visible: " ..
            tostring(currentScene.layers[layer] and currentScene.layers[layer].visible))
    end

    selectedLayer = layer

    -- Vérification RENFORCÉE: Ne JAMAIS modifier la visibilité des calques
    if currentScene then
        for i, layerObj in ipairs(currentScene.layers) do
            -- S'assurer que tous les calques restent visibles
            if not layerObj.visible then
                _G.globalFunction.log.warn("Calque " ..
                i .. " (" .. layerObj.name .. ") était invisible - remise à visible")
                layerObj.visible = true
            end
        end
    end
end

function uiRenderer.setSelectedElement(element)
    selectedElement = element
end

function uiRenderer.setShowLayerPanel(show)
    showLayerPanel = show
    uiRenderer.updatePropertiesContainer()
end

function uiRenderer.setShowElementPanel(show)
    showElementPanel = show
    uiRenderer.updatePropertiesContainer()
end

function uiRenderer.setShowLayerPropertiesPanel(show)
    showLayerPropertiesPanel = show
    uiRenderer.updatePropertiesContainer()
end

-- Getter pour selectedLayer
function uiRenderer.getSelectedLayer()
    return selectedLayer
end

return uiRenderer
