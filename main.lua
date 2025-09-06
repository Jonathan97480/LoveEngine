-- main.lua
-- Point d'entrée principal avec support des modes Développement et Jeu

-- Chargement des modules globaux
require("globals")

-- Chargement de la configuration
local config = require("config")

-- Configuration des modes
local MODES = {
    DEV = "dev",  -- Mode développement avec interface d'outils
    GAME = "game" -- Mode jeu normal
}

-- Variables globales de configuration
_G.config = config

-- Détection du mode via arguments de ligne de commande
local function detecterMode()
    local args = love.arg.getLow(love.arg.parseGameArguments(arg))

    -- Recherche des flags de mode
    for i, argument in ipairs(args) do
        if argument == "--dev" or argument == "-d" then
            return MODES.DEV
        elseif argument == "--game" or argument == "-g" then
            return MODES.GAME
        end
    end

    -- Mode par défaut depuis la configuration
    return config.defaultMode == "game" and MODES.GAME or MODES.DEV
end

-- Variables globales du mode
local modeActuel = detecterMode()
_G.gameMode = modeActuel
_G.isDevMode = (modeActuel == MODES.DEV)
_G.isGameMode = (modeActuel == MODES.GAME)

function love.load()
    _G.globalFunction.log.info("=== LoveEngine v1.0 ===")
    _G.globalFunction.log.info("Mode: " .. modeActuel:upper())

    if _G.isDevMode then
        -- Mode Développement : Interface d'outils
        _G.globalFunction.log.info("Initialisation du mode Développement...")
        initialiserModeDev()
    else
        -- Mode Jeu : Jeu normal
        _G.globalFunction.log.info("Initialisation du mode Jeu...")
        initialiserModeJeu()
    end
end

function love.update(dt)
    if _G.isDevMode then
        updateModeDev(dt)
    else
        updateModeJeu(dt)
    end
end

function love.draw()
    if _G.isDevMode then
        drawModeDev()
    else
        drawModeJeu()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if _G.isDevMode then
        keypressedModeDev(key, scancode, isrepeat)
    else
        keypressedModeJeu(key, scancode, isrepeat)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if _G.isDevMode then
        mousepressedModeDev(x, y, button, istouch, presses)
    else
        mousepressedModeJeu(x, y, button, istouch, presses)
    end
end

-- =====================================================================
-- MODE DÉVELOPPEMENT
-- =====================================================================

function initialiserModeDev()
    _G.globalFunction.log.info("Interface de développement initialisée")

    -- Interface de développement (à implémenter)
    -- Ici on pourra charger les outils de développement :
    -- - Éditeur de scènes
    -- - Inspecteur d'objets
    -- - Console de debug
    -- - Outils de profiling
end

function updateModeDev(dt)
    -- Logique de mise à jour du mode dev
end

function drawModeDev()
    -- Interface de développement
    love.graphics.clear(0.1, 0.1, 0.2) -- Fond bleu foncé pour le mode dev

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("MODE DÉVELOPPEMENT", 10, 10)
    love.graphics.print("LoveEngine v1.0", 10, 30)
    love.graphics.print("F1: Toggle Console | F2: Scene Editor | F3: Object Inspector", 10, 50)
    love.graphics.print("ESC: Quitter", 10, 70)

    -- TODO: Implémenter l'interface complète des outils
end

function keypressedModeDev(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    elseif key == "f1" then
        _G.globalFunction.log.info("Toggle Console (TODO)")
    elseif key == "f2" then
        _G.globalFunction.log.info("Scene Editor (TODO)")
    elseif key == "f3" then
        _G.globalFunction.log.info("Object Inspector (TODO)")
    end
end

function mousepressedModeDev(x, y, button, istouch, presses)
    -- Gestion des clics dans l'interface dev
end

-- =====================================================================
-- MODE JEU
-- =====================================================================

function initialiserModeJeu()
    _G.globalFunction.log.info("Jeu initialisé")

    -- Initialisation du jeu normal
    -- Ici on charge le jeu principal :
    -- - Chargement des niveaux
    -- - Initialisation des personnages
    -- - Configuration des contrôles
end

function updateModeJeu(dt)
    -- Logique de mise à jour du jeu
end

function drawModeJeu()
    -- Rendu du jeu
    love.graphics.clear(0.2, 0.2, 0.2) -- Fond gris pour le jeu

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("MODE JEU", 10, 10)
    love.graphics.print("LoveEngine v1.0", 10, 30)
    love.graphics.print("Jeu en cours de développement...", 10, 50)
    love.graphics.print("ESC: Retour au menu dev", 10, 70)

    -- TODO: Implémenter le rendu du jeu
end

function keypressedModeJeu(key, scancode, isrepeat)
    if key == "escape" then
        -- Retour au mode développement
        _G.gameMode = MODES.DEV
        _G.isDevMode = true
        _G.isGameMode = false
        _G.globalFunction.log.info("Retour au mode Développement")
    end
end

function mousepressedModeJeu(x, y, button, istouch, presses)
    -- Gestion des clics dans le jeu
end
