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
function resizeSystem.getResizeHandle(mouseX, mouseY, scene)
    if not scene then return nil end

    local sceneX, sceneY = utils.worldToScreen(0, 0)
    sceneY = sceneY + config.EDITOR_CONFIG.TOOLBAR_HEIGHT
    local sceneW, sceneH = scene.width * config.editorState.zoom, scene.height * config.editorState.zoom

    local handleSize = 12 -- Augmenté de 8 à 12 pour plus de facilité
    local handles = {
        nw = { x = sceneX - handleSize / 2, y = sceneY - handleSize / 2 },
        ne = { x = sceneX + sceneW - handleSize / 2, y = sceneY - handleSize / 2 },
        sw = { x = sceneX - handleSize / 2, y = sceneY + sceneH - handleSize / 2 },
        se = { x = sceneX + sceneW - handleSize / 2, y = sceneY + sceneH - handleSize / 2 }
    }

    globalFunction.log.debug("Détection poignée - Souris: (" ..
        mouseX .. ", " .. mouseY .. "), Scène: (" .. sceneX .. ", " .. sceneY .. ", " .. sceneW .. ", " .. sceneH .. ")")

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
function resizeSystem.drawResizeHandles(scene)
    if not scene then return end

    local sceneX, sceneY = utils.worldToScreen(0, 0)
    sceneY = sceneY + config.EDITOR_CONFIG.TOOLBAR_HEIGHT
    local sceneW, sceneH = scene.width * config.editorState.zoom, scene.height * config.editorState.zoom

    local handleSize = 12 -- Même taille que dans getResizeHandle
    local handles = {
        { x = sceneX - handleSize / 2,          y = sceneY - handleSize / 2 },
        { x = sceneX + sceneW - handleSize / 2, y = sceneY - handleSize / 2 },
        { x = sceneX - handleSize / 2,          y = sceneY + sceneH - handleSize / 2 },
        { x = sceneX + sceneW - handleSize / 2, y = sceneY + sceneH - handleSize / 2 }
    }

    love.graphics.setColor(1, 1, 0, 1) -- Jaune pour les poignées
    for i, handle in ipairs(handles) do
        -- Changer la couleur si c'est la poignée active
        if isResizing and resizeHandle then
            local handleNames = { "nw", "ne", "sw", "se" }
            if resizeHandle == handleNames[i] then
                love.graphics.setColor(1, 0, 0, 1) -- Rouge pour la poignée active
            else
                love.graphics.setColor(1, 1, 0, 1) -- Jaune pour les autres
            end
        end

        love.graphics.rectangle("fill", handle.x, handle.y, handleSize, handleSize)
        love.graphics.setColor(0, 0, 0, 1) -- Bordure noire
        love.graphics.rectangle("line", handle.x, handle.y, handleSize, handleSize)
        love.graphics.setColor(1, 1, 0, 1) -- Retour au jaune
    end
end

-- Application du redimensionnement
function resizeSystem.applyResize(dx, dy, scene)
    globalFunction.log.debug("applyResize appelée avec dx=" ..
    dx .. ", dy=" .. dy .. ", scene=" .. (scene and "présente" or "absente"))
    globalFunction.log.debug("isResizing=" .. tostring(isResizing) .. ", resizeHandle=" .. tostring(resizeHandle))

    if not isResizing or not scene or not resizeHandle then
        globalFunction.log.debug("applyResize: conditions non remplies, retour anticipé")
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
        scene.width = math.max(100, scene.width + worldDeltaX)
        scene.height = math.max(100, scene.height + worldDeltaY)
        globalFunction.log.debug("Redimensionnement SE terminé - Nouvelles dimensions: " ..
            scene.width .. "x" .. scene.height)
    elseif resizeHandle == "sw" then -- Sud-Ouest (coin inférieur gauche)
        local newWidth = math.max(100, scene.width - worldDeltaX)
        local widthDiff = scene.width - newWidth
        scene.width = newWidth
        scene.height = math.max(100, scene.height + worldDeltaY)
        -- Déplacer la scène vers la gauche
        config.editorState.panX = config.editorState.panX + widthDiff * config.editorState.zoom
        globalFunction.log.debug("Redimensionnement SW terminé - Nouvelles dimensions: " ..
            scene.width .. "x" .. scene.height .. ", panX: " .. config.editorState.panX)
    elseif resizeHandle == "ne" then -- Nord-Est (coin supérieur droit)
        scene.width = math.max(100, scene.width + worldDeltaX)
        local newHeight = math.max(100, scene.height - worldDeltaY)
        local heightDiff = scene.height - newHeight
        scene.height = newHeight
        -- Déplacer la scène vers le haut
        config.editorState.panY = config.editorState.panY + heightDiff * config.editorState.zoom
        globalFunction.log.debug("Redimensionnement NE terminé - Nouvelles dimensions: " ..
            scene.width .. "x" .. scene.height .. ", panY: " .. config.editorState.panY)
    elseif resizeHandle == "nw" then -- Nord-Ouest (coin supérieur gauche)
        local newWidth = math.max(100, scene.width - worldDeltaX)
        local newHeight = math.max(100, scene.height - worldDeltaY)
        local widthDiff = scene.width - newWidth
        local heightDiff = scene.height - newHeight
        scene.width = newWidth
        scene.height = newHeight
        -- Déplacer la scène
        config.editorState.panX = config.editorState.panX + widthDiff * config.editorState.zoom
        config.editorState.panY = config.editorState.panY + heightDiff * config.editorState.zoom
        globalFunction.log.debug("Redimensionnement NW terminé - Nouvelles dimensions: " ..
            scene.width ..
            "x" .. scene.height .. ", panX: " .. config.editorState.panX .. ", panY: " .. config.editorState.panY)
    end
end

-- Gestion des événements de redimensionnement
function resizeSystem.startResize(handle, x, y, scene)
    currentScene = scene
    resizeHandle = handle
    isResizing = true
    resizeStartPos.x = x
    resizeStartPos.y = y
    if scene then
        resizeStartSize.width = scene.width
        resizeStartSize.height = scene.height
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
