-- resizeSystem.lua
-- Système de redimensionnement pour l'éditeur de scènes

local resizeSystem = {}
local config = require("libreria.tools.editor.sceneEditor.config")
local utils = require("libreria.tools.editor.sceneEditor.utils")
local globalFunction = require("libreria.tools.globalFunction")

-- Variables pour le redimensionnement
local isResizing = false
local resizeHandle = nil -- "nw", "ne", "sw", "se"
local resizeStartPos = { x = 0, y = 0 }
local resizeStartSize = { width = 0, height = 0 }
local currentScene = nil -- Sera défini depuis le module principal

-- Détection des poignées de redimensionnement
function resizeSystem.getResizeHandle(mouseX, mouseY, scene, selectedLayerIndex)
    if not scene or not selectedLayerIndex then return nil end

    local layer = scene.layers[selectedLayerIndex]
    if not layer then return nil end

    local sceneX, sceneY = utils.worldToScreen(layer.x, layer.y)
    sceneY = sceneY + config.EDITOR_CONFIG.TOOLBAR_HEIGHT
    local sceneW, sceneH = layer.width * config.editorState.zoom, layer.height * config.editorState.zoom

    local handleSize = 30 -- Augmenté de 20 à 30 pour plus de facilité
    local handles = {
        nw = { x = sceneX - handleSize / 2, y = sceneY - handleSize / 2 },
        ne = { x = sceneX + sceneW - handleSize / 2, y = sceneY - handleSize / 2 },
        sw = { x = sceneX - handleSize / 2, y = sceneY + sceneH - handleSize / 2 },
        se = { x = sceneX + sceneW - handleSize / 2, y = sceneY + sceneH - handleSize / 2 }
    }

    globalFunction.log.debug("Détection poignée - Souris: (" ..
        mouseX .. ", " .. mouseY .. "), Calque: (" .. sceneX .. ", " .. sceneY .. ", " .. sceneW .. ", " .. sceneH .. ")")

    for handle, pos in pairs(handles) do
        if mouseX >= pos.x and mouseX <= pos.x + handleSize and
            mouseY >= pos.y and mouseY <= pos.y + handleSize then
            globalFunction.log.debug("Poignée détectée: " ..
                handle .. " aux coordonnées (" .. pos.x .. ", " .. pos.y .. ")")
            return handle
        end
    end

    return nil
end

-- Rendu des poignées de redimensionnement
function resizeSystem.drawResizeHandles(scene, selectedLayerIndex)
    if not scene or not selectedLayerIndex then return end

    local layer = scene.layers[selectedLayerIndex]
    if not layer then return end

    local sceneX, sceneY = utils.worldToScreen(layer.x, layer.y)
    sceneY = sceneY + config.EDITOR_CONFIG.TOOLBAR_HEIGHT
    local sceneW, sceneH = layer.width * config.editorState.zoom, layer.height * config.editorState.zoom

    local handleSize = 30 -- Augmenté de 20 à 30 pour plus de facilité
    local handles = {
        { x = sceneX - handleSize / 2,          y = sceneY - handleSize / 2 },
        { x = sceneX + sceneW - handleSize / 2, y = sceneY - handleSize / 2 },
        { x = sceneX - handleSize / 2,          y = sceneY + sceneH - handleSize / 2 },
        { x = sceneX + sceneW - handleSize / 2, y = sceneY + sceneH - handleSize / 2 }
    }

    love.graphics.setColor(1, 0.5, 0, 1) -- Orange pour les poignées (plus visible)
    for i, handle in ipairs(handles) do
        -- Changer la couleur si c'est la poignée active
        if isResizing and resizeHandle then
            local handleNames = { "nw", "ne", "sw", "se" }
            if resizeHandle == handleNames[i] then
                love.graphics.setColor(1, 0, 0, 1)   -- Rouge pour la poignée active
            else
                love.graphics.setColor(1, 0.5, 0, 1) -- Orange pour les autres
            end
        end

        love.graphics.rectangle("fill", handle.x, handle.y, handleSize, handleSize)
        love.graphics.setColor(0, 0, 0, 1)   -- Bordure noire
        love.graphics.rectangle("line", handle.x, handle.y, handleSize, handleSize)
        love.graphics.setColor(1, 0.5, 0, 1) -- Retour à l'orange
    end
end

-- Application du redimensionnement
function resizeSystem.applyResize(dx, dy, scene, selectedLayerIndex)
    globalFunction.log.debug("applyResize appelée avec dx=" ..
        dx .. ", dy=" .. dy .. ", scene=" .. (scene and "présente" or "absente"))
    globalFunction.log.debug("isResizing=" .. tostring(isResizing) .. ", resizeHandle=" .. tostring(resizeHandle))

    if not isResizing or not scene or not resizeHandle or not selectedLayerIndex then
        globalFunction.log.debug("applyResize: conditions non remplies, retour anticipé")
        return
    end

    local layer = scene.layers[selectedLayerIndex]
    if not layer then
        globalFunction.log.debug("applyResize: calque non trouvé")
        return
    end

    -- Calculer le delta de déplacement par rapport à la position précédente
    local deltaX = dx -- Utiliser dx directement pour un mouvement relatif
    local deltaY = dy -- Utiliser dy directement pour un mouvement relatif

    -- Convertir le delta en unités monde
    local worldDeltaX = deltaX / config.editorState.zoom
    local worldDeltaY = deltaY / config.editorState.zoom

    globalFunction.log.debug("Redimensionnement en cours avec poignée: " ..
        (resizeHandle or "nil") .. ", dx: " .. dx .. ", dy: " .. dy)
    globalFunction.log.debug("Deltas monde: " .. worldDeltaX .. ", " .. worldDeltaY)

    -- Appliquer le redimensionnement selon la poignée
    if resizeHandle == "se" then -- Sud-Est (coin inférieur droit)
        layer.width = math.max(50, layer.width + worldDeltaX)
        layer.height = math.max(50, layer.height + worldDeltaY)
        globalFunction.log.debug("Redimensionnement SE terminé - Nouvelles dimensions: " ..
            layer.width .. "x" .. layer.height)
    elseif resizeHandle == "sw" then -- Sud-Ouest (coin inférieur gauche)
        local newWidth = math.max(50, layer.width - worldDeltaX)
        local widthDiff = layer.width - newWidth
        layer.width = newWidth
        layer.height = math.max(50, layer.height + worldDeltaY)
        -- Déplacer le calque vers la gauche
        layer.x = layer.x + widthDiff
        globalFunction.log.debug("Redimensionnement SW terminé - Nouvelles dimensions: " ..
            layer.width .. "x" .. layer.height .. ", x: " .. layer.x)
    elseif resizeHandle == "ne" then -- Nord-Est (coin supérieur droit)
        layer.width = math.max(50, layer.width + worldDeltaX)
        local newHeight = math.max(50, layer.height - worldDeltaY)
        local heightDiff = layer.height - newHeight
        layer.height = newHeight
        -- Déplacer le calque vers le haut
        layer.y = layer.y + heightDiff
        globalFunction.log.debug("Redimensionnement NE terminé - Nouvelles dimensions: " ..
            layer.width .. "x" .. layer.height .. ", y: " .. layer.y)
    elseif resizeHandle == "nw" then -- Nord-Ouest (coin supérieur gauche)
        local newWidth = math.max(50, layer.width - worldDeltaX)
        local newHeight = math.max(50, layer.height - worldDeltaY)
        local widthDiff = layer.width - newWidth
        local heightDiff = layer.height - newHeight
        layer.width = newWidth
        layer.height = newHeight
        -- Déplacer le calque
        layer.x = layer.x + widthDiff
        layer.y = layer.y + heightDiff
        globalFunction.log.debug("Redimensionnement NW terminé - Nouvelles dimensions: " ..
            layer.width ..
            "x" .. layer.height .. ", x: " .. layer.x .. ", y: " .. layer.y)
    end
end

-- Gestion des événements de redimensionnement
function resizeSystem.startResize(handle, x, y, scene, selectedLayerIndex)
    currentScene = scene
    resizeHandle = handle
    isResizing = true
    resizeStartPos.x = x
    resizeStartPos.y = y
    if scene and selectedLayerIndex then
        local layer = scene.layers[selectedLayerIndex]
        if layer then
            resizeStartSize.width = layer.width
            resizeStartSize.height = layer.height
        end
    end
end

function resizeSystem.endResize()
    if isResizing then
        globalFunction.log.debug("Fin du redimensionnement")
    end
    isResizing = false
    resizeHandle = nil
end

function resizeSystem.isResizing()
    return isResizing
end

function resizeSystem.getCurrentHandle()
    return resizeHandle
end

return resizeSystem
