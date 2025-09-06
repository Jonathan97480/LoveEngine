-- =========================================================================
-- SAVE UI - Interface Utilisateur de Sauvegarde
-- =========================================================================
-- Auteur: GitHub Copilot
-- Date: 3 septembre 2025
-- Description: Interface HUD pour gestion des sauvegardes (sauver/charger/lister)
-- =========================================================================

local saveUI = {}

local globalFunction = require("libreria/tools/globalFunction")
local hud = require("libreria/hud/hud")
local SaveManager = require("libreria/save-system/saveManager")

-- =========================================================================
-- CONFIGURATION
-- =========================================================================

local UI_LAYER = "props"
local BUTTON_LAYER = "button"
local SLOTS_PER_PAGE = 5
local SLOT_HEIGHT = 80
local SAVE_DIALOG_WIDTH = 600
local SAVE_DIALOG_HEIGHT = 400

-- =========================================================================
-- ÉTAT DE L'INTERFACE
-- =========================================================================

local currentPage = 1
local selectedSlot = nil
local isVisible = false
local dialogMode = "list" -- "list", "save", "load", "confirm"
local saveSlots = {}

-- =========================================================================
-- UTILITAIRES
-- =========================================================================

local function log(level, message)
    if globalFunction and globalFunction.log then
        globalFunction.log[level](string.format("[SaveUI] %s", message))
    else
        print(string.format("[%s] SaveUI: %s", level:upper(), message))
    end
end

-- Formatage de la date/heure
local function formatTimestamp(timestamp)
    if not timestamp then
        return "Date inconnue"
    end

    return os.date("%d/%m/%Y %H:%M", timestamp)
end

-- Formatage de la taille de fichier
local function formatFileSize(bytes)
    if not bytes then
        return "Taille inconnue"
    end

    if bytes < 1024 then
        return bytes .. " B"
    elseif bytes < 1024 * 1024 then
        return string.format("%.1f KB", bytes / 1024)
    else
        return string.format("%.1f MB", bytes / (1024 * 1024))
    end
end

-- Formatage du temps de jeu
local function formatPlayTime(seconds)
    if not seconds then
        return "Temps inconnu"
    end

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)

    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    else
        return string.format("%dm", minutes)
    end
end

-- =========================================================================
-- INTERFACE PRINCIPALE
-- =========================================================================

-- Afficher l'interface de sauvegarde
function saveUI.show(mode)
    dialogMode = mode or "list"
    isVisible = true
    currentPage = 1
    selectedSlot = nil

    -- Rafraîchir la liste des sauvegardes
    saveUI.refreshSaveList()

    -- Créer l'interface
    saveUI.createInterface()

    log("info", "Interface de sauvegarde ouverte en mode: " .. dialogMode)
end

-- Masquer l'interface
function saveUI.hide()
    isVisible = false

    -- Nettoyer l'interface HUD
    if hud then
        hud.removeByTag("save_dialog")
    end

    log("info", "Interface de sauvegarde fermée")
end

-- Vérifier si l'interface est visible
function saveUI.isVisible()
    return isVisible
end

-- =========================================================================
-- GESTION DES SAUVEGARDES
-- =========================================================================

-- Rafraîchir la liste des sauvegardes
function saveUI.refreshSaveList()
    saveSlots = SaveManager.getSaveSlots() or {}

    log("info", "Liste des sauvegardes rafraîchie: " .. #saveSlots .. " sauvegardes trouvées")
end

-- Sauvegarder dans un slot
function saveUI.saveToSlot(slotId)
    local success, result = SaveManager.saveToSlot(slotId)

    if success then
        log("info", "Sauvegarde réussie dans le slot " .. slotId)
        saveUI.refreshSaveList()

        -- Afficher message de confirmation
        saveUI.showMessage("Sauvegarde réussie !", "success")

        -- Fermer l'interface après sauvegarde réussie
        saveUI.hide()
    else
        log("error", "Échec sauvegarde slot " .. slotId .. ": " .. tostring(result))
        saveUI.showMessage("Échec de la sauvegarde: " .. tostring(result), "error")
    end

    return success, result
end

-- Charger depuis un slot
function saveUI.loadFromSlot(slotId)
    local success, result = SaveManager.loadFromSlot(slotId)

    if success then
        log("info", "Chargement réussi depuis le slot " .. slotId)
        saveUI.showMessage("Jeu chargé avec succès !", "success")
        saveUI.hide()
    else
        log("error", "Échec chargement slot " .. slotId .. ": " .. tostring(result))
        saveUI.showMessage("Échec du chargement: " .. tostring(result), "error")
    end

    return success, result
end

-- Supprimer une sauvegarde
function saveUI.deleteSave(filename)
    local success, result = SaveManager.deleteSave(filename)

    if success then
        log("info", "Sauvegarde supprimée: " .. filename)
        saveUI.refreshSaveList()
        saveUI.showMessage("Sauvegarde supprimée", "info")
    else
        log("error", "Échec suppression: " .. tostring(result))
        saveUI.showMessage("Impossible de supprimer: " .. tostring(result), "error")
    end

    return success, result
end

-- =========================================================================
-- CONSTRUCTION DE L'INTERFACE
-- =========================================================================

-- Créer l'interface principale
function saveUI.createInterface()
    if not hud then
        log("error", "HUD non disponible pour l'interface de sauvegarde")
        return
    end

    -- Nettoyer l'interface existante
    hud.removeByTag("save_dialog")

    -- Fond semi-transparent
    hud.addPanel("save_background", {
        layer = "background",
        x = 0,
        y = 0,
        w = love.graphics.getWidth(),
        h = love.graphics.getHeight(),
        bg = { 0, 0, 0, 0.7 },
        tag = "save_dialog"
    })

    -- Panneau principal du dialogue
    local dialogX = (love.graphics.getWidth() - SAVE_DIALOG_WIDTH) / 2
    local dialogY = (love.graphics.getHeight() - SAVE_DIALOG_HEIGHT) / 2

    hud.addPanel("save_dialog", {
        layer = UI_LAYER,
        x = dialogX,
        y = dialogY,
        w = SAVE_DIALOG_WIDTH,
        h = SAVE_DIALOG_HEIGHT,
        bg = { 0.2, 0.2, 0.3, 0.95 },
        tag = "save_dialog"
    })

    -- Titre du dialogue
    local title = ""
    if dialogMode == "save" then
        title = "Sauvegarder la partie"
    elseif dialogMode == "load" then
        title = "Charger une partie"
    else
        title = "Gestion des sauvegardes"
    end

    hud.addLabel("save_title", {
        layer = UI_LAYER,
        x = dialogX + 20,
        y = dialogY + 20,
        text = title,
        font = 24,
        color = { 1, 1, 1 },
        tag = "save_dialog"
    })

    -- Bouton fermer
    hud.addButton("save_close", {
        layer = BUTTON_LAYER,
        x = dialogX + SAVE_DIALOG_WIDTH - 60,
        y = dialogY + 10,
        w = 50,
        h = 30,
        text = "✕",
        font = 20,
        callback = function()
            saveUI.hide()
        end,
        tag = "save_dialog"
    })

    -- Créer la liste des slots
    saveUI.createSlotList(dialogX, dialogY)

    -- Boutons de navigation
    saveUI.createNavigationButtons(dialogX, dialogY)
end

-- Créer la liste des slots de sauvegarde
function saveUI.createSlotList(dialogX, dialogY)
    local startY = dialogY + 70
    local startIndex = (currentPage - 1) * SLOTS_PER_PAGE + 1
    local endIndex = math.min(startIndex + SLOTS_PER_PAGE - 1, #saveSlots)

    for i = startIndex, endIndex do
        local save = saveSlots[i]
        local slotY = startY + ((i - startIndex) * SLOT_HEIGHT)

        saveUI.createSlotItem(save, dialogX + 20, slotY, i)
    end

    -- Créer des slots vides si mode sauvegarde
    if dialogMode == "save" then
        for slot = 1, 10 do -- Créer jusqu'à 10 slots
            local hasExistingSave = false
            for _, save in ipairs(saveSlots) do
                if save.slot == slot and not save.isAutoSave then
                    hasExistingSave = true
                    break
                end
            end

            if not hasExistingSave then
                local emptySlotIndex = #saveSlots + slot
                local slotInPage = emptySlotIndex - startIndex + 1

                if slotInPage > 0 and slotInPage <= SLOTS_PER_PAGE then
                    local slotY = startY + ((slotInPage - 1) * SLOT_HEIGHT)
                    saveUI.createEmptySlotItem(slot, dialogX + 20, slotY)
                end
            end
        end
    end
end

-- Créer un élément de slot existant
function saveUI.createSlotItem(save, x, y, index)
    -- Panneau du slot
    hud.addPanel("save_slot_" .. index, {
        layer = UI_LAYER,
        x = x,
        y = y,
        w = SAVE_DIALOG_WIDTH - 40,
        h = SLOT_HEIGHT - 10,
        bg = selectedSlot == index and { 0.4, 0.4, 0.6, 0.8 } or { 0.3, 0.3, 0.4, 0.8 },
        tag = "save_dialog"
    })

    -- Informations de la sauvegarde
    local slotText = save.isAutoSave and "Auto-Save" or ("Slot " .. (save.slot or "?"))
    local dateText = formatTimestamp(save.timestamp)
    local sizeText = formatFileSize(save.size)
    local playTimeText = save.playTime and formatPlayTime(save.playTime) or "Temps inconnu"

    hud.addLabel("save_slot_title_" .. index, {
        layer = UI_LAYER,
        x = x + 10,
        y = y + 5,
        text = slotText,
        font = 18,
        color = { 1, 1, 1 },
        tag = "save_dialog"
    })

    _G.hud.addLabel("save_slot_date_" .. index, {
        layer = UI_LAYER,
        x = x + 10,
        y = y + 25,
        text = dateText,
        font = 14,
        color = { 0.8, 0.8, 0.8 },
        tag = "save_dialog"
    })

    _G.hud.addLabel("save_slot_info_" .. index, {
        layer = UI_LAYER,
        x = x + 10,
        y = y + 45,
        text = string.format("Temps: %s | Taille: %s", playTimeText, sizeText),
        font = 12,
        color = { 0.7, 0.7, 0.7 },
        tag = "save_dialog"
    })

    -- Boutons d'action
    if dialogMode == "load" then
        _G.hud.addButton("save_load_" .. index, {
            layer = BUTTON_LAYER,
            x = x + SAVE_DIALOG_WIDTH - 180,
            y = y + 20,
            w = 80,
            h = 30,
            text = "Charger",
            callback = function()
                if save.slot then
                    saveUI.loadFromSlot(save.slot)
                end
            end,
            tag = "save_dialog"
        })
    end

    -- Bouton supprimer (sauf pour auto-saves)
    if not save.isAutoSave then
        _G.hud.addButton("save_delete_" .. index, {
            layer = BUTTON_LAYER,
            x = x + SAVE_DIALOG_WIDTH - 90,
            y = y + 20,
            w = 70,
            h = 30,
            text = "Suppr",
            color = { 0.8, 0.3, 0.3 },
            callback = function()
                saveUI.deleteSave(save.filename)
            end,
            tag = "save_dialog"
        })
    end
end

-- Créer un slot vide pour sauvegarde
function saveUI.createEmptySlotItem(slotNumber, x, y)
    -- Panneau du slot vide
    _G.hud.addPanel("save_empty_slot_" .. slotNumber, {
        layer = UI_LAYER,
        x = x,
        y = y,
        w = SAVE_DIALOG_WIDTH - 40,
        h = SLOT_HEIGHT - 10,
        bg = { 0.2, 0.2, 0.3, 0.8 },
        tag = "save_dialog"
    })

    _G.hud.addLabel("save_empty_title_" .. slotNumber, {
        layer = UI_LAYER,
        x = x + 10,
        y = y + 20,
        text = "Slot " .. slotNumber .. " - Vide",
        font = 18,
        color = { 0.6, 0.6, 0.6 },
        tag = "save_dialog"
    })

    _G.hud.addButton("save_new_" .. slotNumber, {
        layer = BUTTON_LAYER,
        x = x + SAVE_DIALOG_WIDTH - 180,
        y = y + 20,
        w = 150,
        h = 30,
        text = "Sauvegarder ici",
        callback = function()
            saveUI.saveToSlot(slotNumber)
        end,
        tag = "save_dialog"
    })
end

-- Créer les boutons de navigation
function saveUI.createNavigationButtons(dialogX, dialogY)
    local totalPages = math.ceil(#saveSlots / SLOTS_PER_PAGE)

    if totalPages > 1 then
        -- Bouton page précédente
        if currentPage > 1 then
            _G.hud.addButton("save_prev_page", {
                layer = BUTTON_LAYER,
                x = dialogX + 20,
                y = dialogY + SAVE_DIALOG_HEIGHT - 50,
                w = 100,
                h = 30,
                text = "< Précédent",
                callback = function()
                    currentPage = currentPage - 1
                    saveUI.createInterface()
                end,
                tag = "save_dialog"
            })
        end

        -- Bouton page suivante
        if currentPage < totalPages then
            _G.hud.addButton("save_next_page", {
                layer = BUTTON_LAYER,
                x = dialogX + SAVE_DIALOG_WIDTH - 120,
                y = dialogY + SAVE_DIALOG_HEIGHT - 50,
                w = 100,
                h = 30,
                text = "Suivant >",
                callback = function()
                    currentPage = currentPage + 1
                    saveUI.createInterface()
                end,
                tag = "save_dialog"
            })
        end

        -- Indicateur de page
        _G.hud.addLabel("save_page_indicator", {
            layer = UI_LAYER,
            x = dialogX + SAVE_DIALOG_WIDTH / 2 - 30,
            y = dialogY + SAVE_DIALOG_HEIGHT - 45,
            text = string.format("Page %d/%d", currentPage, totalPages),
            font = 14,
            color = { 0.8, 0.8, 0.8 },
            tag = "save_dialog"
        })
    end
end

-- =========================================================================
-- MESSAGES ET NOTIFICATIONS
-- =========================================================================

-- Afficher un message temporaire
function saveUI.showMessage(message, type)
    local color = { 1, 1, 1 }
    if type == "success" then
        color = { 0.2, 0.8, 0.2 }
    elseif type == "error" then
        color = { 0.8, 0.2, 0.2 }
    elseif type == "info" then
        color = { 0.2, 0.6, 0.8 }
    end

    if _G.hud then
        _G.hud.addLabel("save_message", {
            layer = "props",
            x = love.graphics.getWidth() / 2 - 150,
            y = 50,
            text = message,
            font = 16,
            color = color,
            duration = 3 -- Afficher pendant 3 secondes
        })
    end

    log("info", "Message affiché: " .. message)
end

-- =========================================================================
-- INTÉGRATION AVEC LE JEU
-- =========================================================================

-- Gestion des événements clavier
function saveUI.keypressed(key)
    if not isVisible then
        return false
    end

    if key == "escape" then
        saveUI.hide()
        return true
    end

    return false
end

-- Mise à jour de l'interface
function saveUI.update(dt)
    if not isVisible then
        return
    end

    -- Ici on pourrait ajouter des animations ou des mises à jour temps réel
end

-- =========================================================================
-- API PUBLIQUE
-- =========================================================================

-- Raccourcis rapides pour les actions communes
function saveUI.quickSave()
    return SaveManager.autoSave()
end

function saveUI.quickLoad()
    local latestSave = SaveManager.getLatestSave()

    if latestSave and latestSave.slot then
        return SaveManager.loadFromSlot(latestSave.slot)
    else
        return false, "Aucune sauvegarde disponible"
    end
end

-- =========================================================================
-- EXPORT DU MODULE
-- =========================================================================

return saveUI
