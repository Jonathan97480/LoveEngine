-- sceneEditor.lua
-- Éditeur de scènes pour LoveEngine
-- Permet de créer et modifier des scènes avec un système de calques

local sceneEditor = {}

-- Variables locales
local currentScene = nil
local selectedLayer = 1
local selectedElement = nil
local isDragging = false
local dragOffset = { x = 0, y = 0 }
local showElementPanel = false
local showLayerPanel = false
local showFileDialog = false

-- Configuration de l'éditeur
local EDITOR_CONFIG = {
    PANEL_WIDTH = 300,
    TOOLBAR_HEIGHT = 40,
    ELEMENT_SIZE = 32,
    SNAP_GRID = 16,
    ZOOM_LEVELS = { 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0 },
    DEFAULT_SCENE_SIZE = { width = 800, height = 600 }
}

-- États de l'éditeur
local editorState = {
    zoom = 1.0,
    panX = 0,
    panY = 0,
    gridVisible = true,
    snapToGrid = true,
    currentTool = "select" -- select, move, resize, add
}

-- Types d'éléments disponibles
local ELEMENT_TYPES = {
    BACKGROUND = "background",
    SPRITE = "sprite",
    TEXT = "text",
    BUTTON = "button",
    PANEL = "panel"
}

-- Structure d'une scène
local function createNewScene(name)
    return {
        name = name or "Nouvelle Scene",
        width = EDITOR_CONFIG.DEFAULT_SCENE_SIZE.width,
        height = EDITOR_CONFIG.DEFAULT_SCENE_SIZE.height,
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
local function createElement(type, x, y)
    local element = {
        id = love.math.random(1000000),
        type = type,
        x = x or 0,
        y = y or 0,
        width = EDITOR_CONFIG.ELEMENT_SIZE,
        height = EDITOR_CONFIG.ELEMENT_SIZE,
        rotation = 0,
        scaleX = 1.0,
        scaleY = 1.0,
        visible = true,
        properties = {}
    }

    -- Propriétés spécifiques selon le type
    if type == ELEMENT_TYPES.BACKGROUND then
        element.properties = {
            image = nil,
            color = { 1, 1, 1, 1 },
            stretch = true
        }
    elseif type == ELEMENT_TYPES.SPRITE then
        element.properties = {
            image = nil,
            color = { 1, 1, 1, 1 }
        }
    elseif type == ELEMENT_TYPES.TEXT then
        element.properties = {
            text = "Nouveau texte",
            font = "default",
            fontSize = 16,
            color = { 1, 1, 1, 1 },
            align = "left"
        }
    elseif type == ELEMENT_TYPES.BUTTON then
        element.properties = {
            text = "Bouton",
            normalColor = { 0.5, 0.5, 0.5, 1 },
            hoverColor = { 0.7, 0.7, 0.7, 1 },
            pressedColor = { 0.3, 0.3, 0.3, 1 },
            callback = nil
        }
    elseif type == ELEMENT_TYPES.PANEL then
        element.properties = {
            backgroundColor = { 0.2, 0.2, 0.2, 0.8 },
            borderColor = { 0.5, 0.5, 0.5, 1 },
            borderWidth = 2
        }
    end

    return element
end

-- Fonctions utilitaires
local function worldToScreen(x, y)
    return x * editorState.zoom + editorState.panX,
        y * editorState.zoom + editorState.panY
end

local function screenToWorld(x, y)
    return (x - editorState.panX) / editorState.zoom,
        (y - editorState.panY) / editorState.zoom
end

local function snapToGrid(x, y)
    if not editorState.snapToGrid then return x, y end
    local grid = EDITOR_CONFIG.SNAP_GRID
    return math.floor(x / grid + 0.5) * grid,
        math.floor(y / grid + 0.5) * grid
end

-- Gestion des fichiers
local function saveScene(scene)
    if not scene or not scene.name then return false end

    scene.metadata.modified = os.date("%Y-%m-%d %H:%M:%S")

    local filename = "src/scenes/" .. scene.name .. ".json"
    local success = _G.globalFunction.saveToFile(filename, scene)

    if success then
        _G.globalFunction.log.info("Scène sauvegardée: " .. filename)
    else
        _G.globalFunction.log.error("Erreur lors de la sauvegarde de la scène")
    end

    return success
end

local function loadScene(name)
    local filename = "src/scenes/" .. name .. ".json"
    local scene = _G.globalFunction.loadFromFile(filename)

    if scene then
        _G.globalFunction.log.info("Scène chargée: " .. filename)
        return scene
    else
        _G.globalFunction.log.error("Erreur lors du chargement de la scène: " .. filename)
        return nil
    end
end

local function copyImageToSceneFolder(imagePath, sceneName)
    if not love.filesystem.getInfo(imagePath) then return nil end

    local sceneImageDir = "src/images/" .. sceneName
    love.filesystem.createDirectory(sceneImageDir)

    local filename = imagePath:match("([^/\\]+)$")
    local destPath = sceneImageDir .. "/" .. filename

    -- Copier le fichier (simulation avec Love2D filesystem)
    local fileData = love.filesystem.newFileData(imagePath)
    if fileData then
        love.filesystem.write(destPath, fileData)
        return destPath
    end

    return nil
end

-- Interface utilisateur
local function drawToolbar()
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), EDITOR_CONFIG.TOOLBAR_HEIGHT)

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

local function drawGrid()
    if not editorState.gridVisible then return end

    love.graphics.setColor(0.2, 0.2, 0.2, 0.3)
    local gridSize = EDITOR_CONFIG.SNAP_GRID * editorState.zoom

    -- Lignes verticales
    for x = editorState.panX % gridSize, love.graphics.getWidth(), gridSize do
        love.graphics.line(x, 0, x, love.graphics.getHeight())
    end

    -- Lignes horizontales
    for y = editorState.panY % gridSize, love.graphics.getHeight(), gridSize do
        love.graphics.line(0, y, love.graphics.getWidth(), y)
    end
end

local function drawScene()
    if not currentScene then return end

    -- Fond de la scène
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    local sceneX, sceneY = worldToScreen(0, 0)
    local sceneW, sceneH = currentScene.width * editorState.zoom, currentScene.height * editorState.zoom
    love.graphics.rectangle("fill", sceneX, sceneY, sceneW, sceneH)

    -- Bordure de la scène
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.rectangle("line", sceneX, sceneY, sceneW, sceneH)

    -- Dessiner les éléments de chaque calque
    for i, layer in ipairs(currentScene.layers) do
        if layer.visible then
            for j, element in ipairs(layer.elements) do
                drawElement(element, i == selectedLayer)
            end
        end
    end
end

local function drawElement(element, isSelectedLayer)
    local x, y = worldToScreen(element.x, element.y)
    local w, h = element.width * editorState.zoom, element.height * editorState.zoom

    -- Couleur selon l'état
    if element == selectedElement then
        love.graphics.setColor(1, 1, 0, 1)       -- Jaune pour sélectionné
    elseif isSelectedLayer then
        love.graphics.setColor(1, 1, 1, 1)       -- Blanc pour calque actif
    else
        love.graphics.setColor(0.7, 0.7, 0.7, 1) -- Gris pour autres calques
    end

    -- Dessiner selon le type d'élément
    if element.type == ELEMENT_TYPES.BACKGROUND then
        love.graphics.rectangle("fill", x, y, w, h)
    elseif element.type == ELEMENT_TYPES.SPRITE then
        love.graphics.rectangle("fill", x, y, w, h)
    elseif element.type == ELEMENT_TYPES.TEXT then
        love.graphics.rectangle("line", x, y, w, h)
        love.graphics.print(element.properties.text, x + 5, y + 5)
    elseif element.type == ELEMENT_TYPES.BUTTON then
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(element.properties.text, x + 10, y + h / 2 - 8)
    elseif element.type == ELEMENT_TYPES.PANEL then
        love.graphics.rectangle("fill", x, y, w, h)
    end

    -- Indicateur de sélection
    if element == selectedElement then
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.rectangle("line", x - 2, y - 2, w + 4, h + 4)
    end
end

local function drawPanels()
    local panelX = love.graphics.getWidth() - EDITOR_CONFIG.PANEL_WIDTH
    local panelY = EDITOR_CONFIG.TOOLBAR_HEIGHT

    -- Panneau des calques
    if showLayerPanel then
        love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
        love.graphics.rectangle("fill", panelX, panelY, EDITOR_CONFIG.PANEL_WIDTH, 200)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Calques", panelX + 10, panelY + 10)

        if currentScene then
            for i, layer in ipairs(currentScene.layers) do
                local layerY = panelY + 30 + (i - 1) * 25
                if i == selectedLayer then
                    love.graphics.setColor(0.5, 0.5, 0.5, 1)
                    love.graphics.rectangle("fill", panelX + 5, layerY, EDITOR_CONFIG.PANEL_WIDTH - 10, 20)
                end

                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.print(layer.name, panelX + 10, layerY + 2)
            end
        end
    end

    -- Panneau des propriétés d'élément
    if showElementPanel and selectedElement then
        love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
        love.graphics.rectangle("fill", panelX, panelY + 220, EDITOR_CONFIG.PANEL_WIDTH, 300)

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

-- Gestion des événements
function sceneEditor.keypressed(key)
    if key == "f1" then
        showLayerPanel = not showLayerPanel
    elseif key == "f2" then
        showElementPanel = not showElementPanel
    elseif key == "g" then
        editorState.gridVisible = not editorState.gridVisible
    elseif key == "s" and love.keyboard.isDown("lctrl") then
        if currentScene then
            saveScene(currentScene)
        end
    elseif key == "n" and love.keyboard.isDown("lctrl") then
        currentScene = createNewScene("Scene_" .. os.date("%Y%m%d_%H%M%S"))
        selectedLayer = 1
        selectedElement = nil
    end
end

function sceneEditor.mousepressed(x, y, button)
    if button == 1 then -- Clic gauche
        -- Vérifier les boutons de la toolbar
        if y <= EDITOR_CONFIG.TOOLBAR_HEIGHT then
            if x >= 300 and x <= 360 then -- Bouton Nouveau
                currentScene = createNewScene("Scene_" .. os.date("%Y%m%d_%H%M%S"))
                selectedLayer = 1
                selectedElement = nil
            elseif x >= 370 and x <= 430 then -- Bouton Sauvegarder
                if currentScene then
                    saveScene(currentScene)
                end
            elseif x >= 440 and x <= 500 then -- Bouton Charger
                -- TODO: Ouvrir un dialogue de sélection de fichier
            end
            return
        end

        -- Sélection d'élément dans la scène
        if currentScene then
            local worldX, worldY = screenToWorld(x, y)
            selectedElement = nil

            for i, layer in ipairs(currentScene.layers) do
                if layer.visible and not layer.locked then
                    for j, element in ipairs(layer.elements) do
                        if worldX >= element.x and worldX <= element.x + element.width and
                            worldY >= element.y and worldY <= element.y + element.height then
                            selectedElement = element
                            selectedLayer = i
                            isDragging = true
                            dragOffset.x = worldX - element.x
                            dragOffset.y = worldY - element.y
                            return
                        end
                    end
                end
            end
        end
    elseif button == 2 then -- Clic droit
        -- Menu contextuel pour ajouter des éléments
        local worldX, worldY = screenToWorld(x, y)
        local newElement = createElement(ELEMENT_TYPES.SPRITE, worldX, worldY)
        if currentScene and currentScene.layers[selectedLayer] then
            table.insert(currentScene.layers[selectedLayer].elements, newElement)
            selectedElement = newElement
        end
    end
end

function sceneEditor.mousereleased(x, y, button)
    if button == 1 then
        isDragging = false
    end
end

function sceneEditor.mousemoved(x, y, dx, dy)
    if isDragging and selectedElement then
        local worldX, worldY = screenToWorld(x, y)
        selectedElement.x = snapToGrid(worldX - dragOffset.x)
        selectedElement.y = snapToGrid(worldY - dragOffset.y)
    end
end

function sceneEditor.wheelmoved(x, y)
    if y > 0 then
        editorState.zoom = math.min(editorState.zoom * 1.1, EDITOR_CONFIG.ZOOM_LEVELS[#EDITOR_CONFIG.ZOOM_LEVELS])
    elseif y < 0 then
        editorState.zoom = math.max(editorState.zoom / 1.1, EDITOR_CONFIG.ZOOM_LEVELS[1])
    end
end

-- Fonctions publiques
function sceneEditor.init()
    _G.globalFunction.log.info("Éditeur de scène initialisé")
end

function sceneEditor.update(dt)
    -- Mise à jour de l'éditeur
end

function sceneEditor.draw()
    drawToolbar()
    drawGrid()
    drawScene()
    drawPanels()

    -- Instructions
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print("F1: Calques | F2: Propriétés | G: Grille | Ctrl+N: Nouveau | Ctrl+S: Sauvegarder", 10,
        love.graphics.getHeight() - 20)
end

function sceneEditor.newScene(name)
    currentScene = createNewScene(name)
    selectedLayer = 1
    selectedElement = nil
    return currentScene
end

function sceneEditor.loadScene(name)
    currentScene = loadScene(name)
    if currentScene then
        selectedLayer = 1
        selectedElement = nil
    end
    return currentScene
end

function sceneEditor.saveCurrentScene()
    if currentScene then
        return saveScene(currentScene)
    end
    return false
end

function sceneEditor.addLayer(name)
    if not currentScene then return end

    local layerName = name or ("Calque " .. (#currentScene.layers + 1))
    local newLayer = {
        id = #currentScene.layers + 1,
        name = layerName,
        visible = true,
        locked = false,
        elements = {}
    }

    table.insert(currentScene.layers, newLayer)
    selectedLayer = #currentScene.layers
end

function sceneEditor.addElement(type, x, y)
    if not currentScene or not currentScene.layers[selectedLayer] then return end

    local element = createElement(type, x, y)
    table.insert(currentScene.layers[selectedLayer].elements, element)
    selectedElement = element
    return element
end

function sceneEditor.getCurrentScene()
    return currentScene
end

function sceneEditor.setCurrentScene(scene)
    currentScene = scene
    selectedLayer = 1
    selectedElement = nil
end

return sceneEditor
