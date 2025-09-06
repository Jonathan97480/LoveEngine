-- main.lua
-- Module principal de l'éditeur de scènes

local sceneEditor = {}

-- Dépendances
local config = require("libreria.tools.editor.sceneEditor.config")
local dataStructures = require("libreria.tools.editor.sceneEditor.dataStructures")
local utils = require("libreria.tools.editor.sceneEditor.utils")
local resizeSystem = require("libreria.tools.editor.sceneEditor.resizeSystem")
local sceneManager = require("libreria.tools.editor.sceneEditor.sceneManager")
local uiRenderer = require("libreria.tools.editor.sceneEditor.uiRenderer")
local globalFunction = require("libreria.tools.globalFunction")

-- Variables d'état
local currentScene = nil
local selectedLayer = 1
local selectedElement = nil
local isDragging = false
local dragOffset = { x = 0, y = 0 }
local showElementPanel = false
local showLayerPanel = true
local showLayerPropertiesPanel = false
local showScenePropertiesPanel = true
local showFileDialog = false

-- Initialisation
function sceneEditor.init()
    globalFunction.log.info("Éditeur de scène initialisé")
    uiRenderer.setCurrentScene(currentScene)
    uiRenderer.setSelectedLayer(selectedLayer)
    uiRenderer.setSelectedElement(selectedElement)
    uiRenderer.setShowLayerPanel(showLayerPanel)
    uiRenderer.setShowElementPanel(showElementPanel)
    uiRenderer.setShowLayerPropertiesPanel(showLayerPropertiesPanel)
    uiRenderer.setShowScenePropertiesPanel(showScenePropertiesPanel)
end

-- Mise à jour
function sceneEditor.update(dt)
    -- Mise à jour de l'éditeur
    uiRenderer.update(dt)
end

-- Rendu
function sceneEditor.draw()
    uiRenderer.draw()
end

-- Gestion des événements souris
function sceneEditor.mousepressed(x, y, button, istouch, presses)
    globalFunction.log.debug("Mouse pressed: (" .. x .. ", " .. y .. "), button: " .. button)
    if button == 1 then
        -- Vérifier les boutons de la barre d'outils
        if y <= config.EDITOR_CONFIG.TOOLBAR_HEIGHT then
            -- Bouton Nouveau (position 300-360)
            if x >= 300 and x <= 360 then
                currentScene = dataStructures.createNewScene("Scene_" .. os.date("%Y%m%d_%H%M%S"))
                selectedLayer = 1
                selectedElement = nil
                uiRenderer.setCurrentScene(currentScene)
                uiRenderer.setSelectedLayer(selectedLayer)
                uiRenderer.setSelectedElement(selectedElement)
                uiRenderer.updatePropertiesContainer()
                -- Afficher le panneau des propriétés de scène par défaut
                showScenePropertiesPanel = true
                uiRenderer.setShowScenePropertiesPanel(showScenePropertiesPanel)
                globalFunction.log.info("Nouvelle scène créée: " .. currentScene.name)
                return
                -- Bouton Sauvegarder (position 370-430)
            elseif x >= 370 and x <= 430 then
                if currentScene then
                    local success = sceneManager.saveScene(currentScene)
                    if success then
                        globalFunction.log.info("Scène sauvegardée: " .. currentScene.name)
                    else
                        globalFunction.log.error("Erreur lors de la sauvegarde")
                    end
                end
                return
                -- Bouton Charger (position 440-500)
            elseif x >= 440 and x <= 500 then
                -- Essayer de charger une scène de test
                local testSceneName = "TestScene"
                local loadedScene = sceneManager.loadScene(testSceneName)
                if loadedScene then
                    currentScene = loadedScene
                    selectedLayer = 1
                    selectedElement = nil
                    uiRenderer.setCurrentScene(currentScene)
                    uiRenderer.setSelectedLayer(selectedLayer)
                    uiRenderer.setSelectedElement(selectedElement)
                    uiRenderer.updatePropertiesContainer()
                    -- Afficher le panneau des propriétés de scène par défaut
                    showScenePropertiesPanel = true
                    uiRenderer.setShowScenePropertiesPanel(showScenePropertiesPanel)
                    globalFunction.log.info("Scène chargée: " .. loadedScene.name)
                else
                    globalFunction.log.warn("Aucune scène trouvée: " .. testSceneName)
                end
                return
            end
        end

        -- Vérifier les clics dans les panneaux de propriétés (déléguer à uiRenderer)
        if uiRenderer.mousepressed(x, y, button) then
            return
        end

        -- Vérifier les poignées de redimensionnement
        if currentScene then
            globalFunction.log.debug("Vérification poignées - Souris: (" .. x .. ", " .. y .. ")")
            local currentSelectedLayer = uiRenderer.getSelectedLayer() or selectedLayer
            local handle = resizeSystem.getResizeHandle(x, y, currentScene, currentSelectedLayer)
            if handle then
                globalFunction.log.info("Démarrage redimensionnement avec poignée: " ..
                    handle .. " à (" .. x .. ", " .. y .. ")")
                resizeSystem.startResize(handle, x, y, currentScene, currentSelectedLayer)
                globalFunction.log.debug("startResize terminé, isResizing=" .. tostring(resizeSystem.isResizing()))
                return
            else
                globalFunction.log.debug("Aucune poignée détectée à (" .. x .. ", " .. y .. ")")
            end
        end

        -- Sélection d'élément dans la scène
        if currentScene then
            -- Ajuster les coordonnées pour le décalage de la barre d'outils
            local adjustedY = y - config.EDITOR_CONFIG.TOOLBAR_HEIGHT
            local worldX, worldY = utils.screenToWorld(x, adjustedY)
            selectedElement = nil
            local currentSelectedLayer = uiRenderer.getSelectedLayer() or selectedLayer

            for i, layer in ipairs(currentScene.layers) do
                if layer.visible and not layer.locked then
                    for j, element in ipairs(layer.elements) do
                        if worldX >= element.x and worldX <= element.x + element.width and
                            worldY >= element.y and worldY <= element.y + element.height then
                            selectedElement = element
                            selectedLayer = i              -- Update main.lua's selectedLayer
                            uiRenderer.setSelectedLayer(i) -- Sync uiRenderer
                            isDragging = true
                            dragOffset.x = worldX - element.x
                            dragOffset.y = worldY - element.y
                            uiRenderer.setSelectedElement(selectedElement)
                            return
                        end
                    end
                end
            end
        end
    elseif button == 2 then -- Clic droit
        -- Menu contextuel pour ajouter des éléments
        local adjustedY = y - config.EDITOR_CONFIG.TOOLBAR_HEIGHT
        local worldX, worldY = utils.screenToWorld(x, adjustedY)
        local newElement = dataStructures.createElement(config.ELEMENT_TYPES.SPRITE, worldX, worldY)
        local currentSelectedLayer = uiRenderer.getSelectedLayer() or selectedLayer
        if currentScene and currentScene.layers[currentSelectedLayer] then
            table.insert(currentScene.layers[currentSelectedLayer].elements, newElement)
            selectedElement = newElement
            uiRenderer.setSelectedElement(selectedElement)
        end
    end
end

function sceneEditor.mousereleased(x, y, button)
    globalFunction.log.debug("Mouse released: (" .. x .. ", " .. y .. "), button: " .. button)
    if button == 1 then
        resizeSystem.endResize()
        isDragging = false
        globalFunction.log.debug("Redimensionnement terminé - isResizing=false, isDragging=false")
    end
end

function sceneEditor.mousemoved(x, y, dx, dy)
    globalFunction.log.debug("Mouse moved: (" ..
        x ..
        ", " ..
        y ..
        "), delta: (" ..
        dx ..
        ", " ..
        dy .. "), isResizing: " .. tostring(resizeSystem.isResizing()) .. ", isDragging: " .. tostring(isDragging))

    if isDragging and selectedElement then
        local adjustedY = y - config.EDITOR_CONFIG.TOOLBAR_HEIGHT
        local worldX, worldY = utils.screenToWorld(x, adjustedY)
        selectedElement.x = utils.snapToGrid(worldX - dragOffset.x)
        selectedElement.y = utils.snapToGrid(worldY - dragOffset.y)
    elseif resizeSystem.isResizing() then
        globalFunction.log.debug("Appel de applyResize avec dx=" ..
            dx .. ", dy=" .. dy .. ", isResizing=" .. tostring(resizeSystem.isResizing()))
        local currentSelectedLayer = uiRenderer.getSelectedLayer() or selectedLayer
        resizeSystem.applyResize(dx, dy, currentScene, currentSelectedLayer)
        globalFunction.log.debug("applyResize terminé")
    else
        globalFunction.log.debug("Pas en mode redimensionnement, isResizing=" .. tostring(resizeSystem.isResizing()))
    end
end

function sceneEditor.wheelmoved(x, y)
    -- Gérer d'abord le scroll dans le conteneur de propriétés
    if uiRenderer.wheelmoved(x, y) then
        return
    end

    -- Sinon gérer le zoom
    if y > 0 then
        config.editorState.zoom = math.min(config.editorState.zoom * 1.1,
            config.EDITOR_CONFIG.ZOOM_LEVELS[#config.EDITOR_CONFIG.ZOOM_LEVELS])
    elseif y < 0 then
        config.editorState.zoom = math.max(config.editorState.zoom / 1.1, config.EDITOR_CONFIG.ZOOM_LEVELS[1])
    end
end

-- Gestion des scènes
function sceneEditor.newScene(name)
    currentScene = dataStructures.createNewScene(name)
    selectedLayer = 1
    selectedElement = nil
    uiRenderer.setCurrentScene(currentScene)
    uiRenderer.setSelectedLayer(selectedLayer)
    uiRenderer.setSelectedElement(selectedElement)
    uiRenderer.updatePropertiesContainer()
    return currentScene
end

function sceneEditor.loadScene(name)
    currentScene = sceneManager.loadScene(name)
    if currentScene then
        selectedLayer = 1
        selectedElement = nil
        uiRenderer.setCurrentScene(currentScene)
        uiRenderer.setSelectedLayer(selectedLayer)
        uiRenderer.setSelectedElement(selectedElement)
        uiRenderer.updatePropertiesContainer()
    end
    return currentScene
end

function sceneEditor.saveCurrentScene()
    if currentScene then
        return sceneManager.saveScene(currentScene)
    end
    return false
end

function sceneEditor.saveScene(scene)
    return sceneManager.saveScene(scene or currentScene)
end

-- Fonction helper pour vérifier si un nom de calque existe déjà
function sceneEditor.layerNameExists(name)
    if not currentScene then return false end

    for _, layer in ipairs(currentScene.layers) do
        if layer.name == name then
            return true
        end
    end
    return false
end

-- Gestion des calques
function sceneEditor.addLayer(name)
    if not currentScene then return end

    local layerName = name
    if not layerName then
        -- Générer un nom unique pour éviter les doublons
        local baseName = "Calque "
        local counter = 1
        layerName = baseName .. counter

        -- Vérifier si le nom existe déjà
        while sceneEditor.layerNameExists(layerName) do
            counter = counter + 1
            layerName = baseName .. counter
        end
    else
        -- Si un nom est fourni, vérifier quand même s'il existe
        if sceneEditor.layerNameExists(layerName) then
            _G.globalFunction.log.warn("Un calque avec le nom '" .. layerName .. "' existe déjà")
            -- Générer un nom unique en ajoutant un suffixe
            local counter = 1
            local originalName = layerName
            layerName = originalName .. " (" .. counter .. ")"

            while sceneEditor.layerNameExists(layerName) do
                counter = counter + 1
                layerName = originalName .. " (" .. counter .. ")"
            end
            _G.globalFunction.log.info("Nouveau nom généré: '" .. layerName .. "'")
        end
    end

    local newLayer = {
        id = #currentScene.layers + 1,
        name = layerName,
        visible = true,
        locked = false,
        alpha = 1.0,
        backgroundColor = {
            r = 0.1 + (#currentScene.layers * 0.1), -- Couleur différente pour chaque calque
            g = 0.2 + (#currentScene.layers * 0.1),
            b = 0.3 + (#currentScene.layers * 0.1),
            a = 1.0
        },
        -- Propriétés de position et taille du calque
        x = 0,
        y = 0,
        width = currentScene.width,
        height = currentScene.height,
        elements = {}
    }

    table.insert(currentScene.layers, newLayer)
    selectedLayer = #currentScene.layers
    uiRenderer.setSelectedLayer(selectedLayer)
    -- Mettre à jour explicitement le panneau des calques
    uiRenderer.updateLayerListPanel()
end

-- Gestion des éléments
function sceneEditor.addElement(type, x, y)
    if not currentScene or not currentScene.layers[selectedLayer] then return end

    local element = dataStructures.createElement(type, x, y)
    table.insert(currentScene.layers[selectedLayer].elements, element)
    selectedElement = element
    uiRenderer.setSelectedElement(selectedElement)
    return element
end

-- Gestion des événements clavier
function sceneEditor.keypressed(key)
    if key == "f1" then
        showLayerPanel = not showLayerPanel
        uiRenderer.setShowLayerPanel(showLayerPanel)
        globalFunction.log.info("Panneau des calques: " .. (showLayerPanel and "activé" or "désactivé"))
    elseif key == "f2" then
        showElementPanel = not showElementPanel
        uiRenderer.setShowElementPanel(showElementPanel)
        globalFunction.log.info("Panneau des propriétés: " .. (showElementPanel and "activé" or "désactivé"))
    elseif key == "f3" then
        showLayerPropertiesPanel = not showLayerPropertiesPanel
        uiRenderer.setShowLayerPropertiesPanel(showLayerPropertiesPanel)
        globalFunction.log.info("Panneau des propriétés du calque: " ..
            (showLayerPropertiesPanel and "activé" or "désactivé"))
    elseif key == "g" then
        config.editorState.gridVisible = not config.editorState.gridVisible
        globalFunction.log.info("Grille: " .. (config.editorState.gridVisible and "activée" or "désactivée"))
    elseif key == "s" then
        -- Ctrl+S : Sauvegarder la scène
        if currentScene then
            local success = sceneManager.saveScene(currentScene)
            if success then
                globalFunction.log.info("Scène sauvegardée: " .. currentScene.name)
            else
                globalFunction.log.error("Erreur lors de la sauvegarde")
            end
        end
    elseif key == "n" then
        -- Ctrl+N : Nouvelle scène
        currentScene = dataStructures.createNewScene("Scene_" .. os.date("%Y%m%d_%H%M%S"))
        selectedLayer = 1
        selectedElement = nil
        uiRenderer.setCurrentScene(currentScene)
        uiRenderer.setSelectedLayer(selectedLayer)
        uiRenderer.setSelectedElement(selectedElement)
        globalFunction.log.info("Nouvelle scène créée: " .. currentScene.name)
    elseif key == "f4" then
        showScenePropertiesPanel = not showScenePropertiesPanel
        uiRenderer.setShowScenePropertiesPanel(showScenePropertiesPanel)
        globalFunction.log.info("Panneau des propriétés de scène: " ..
            (showScenePropertiesPanel and "activé" or "désactivé"))
    elseif key == "l" then
        -- L : Ajouter un nouveau calque
        sceneEditor.addLayer()
        globalFunction.log.info("Nouveau calque ajouté avec raccourci L")
    end
end

-- Gestion de l'entrée de texte (relayer vers uiRenderer)
function sceneEditor.textinput(text)
    uiRenderer.textinput(text)
end

-- Gestion des touches spéciales (relayer vers uiRenderer)
function sceneEditor.keypressedSpecial(key)
    return uiRenderer.keypressed(key)
end

-- Getters
function sceneEditor.getCurrentScene()
    return currentScene
end

function sceneEditor.setCurrentScene(scene)
    currentScene = scene
    selectedLayer = 1
    selectedElement = nil
    uiRenderer.setCurrentScene(currentScene)
    uiRenderer.setSelectedLayer(selectedLayer)
    uiRenderer.setSelectedElement(selectedElement)
end

-- NOUVEAU: Fonctions pour le rendu séparé (scène vs interface)
function sceneEditor.drawSceneOnly()
    uiRenderer.drawSceneOnly()
end

function sceneEditor.drawInterfaceOnly()
    uiRenderer.drawInterfaceOnly()
end

return sceneEditor
