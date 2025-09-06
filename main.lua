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

function mousemovedModeDev(x, y, dx, dy, istouch)
    -- Appliquer le scaling responsive aux coordonnées de la souris
    local ratioW, ratioH = 1, 1
    if _G.screenManager and _G.screenManager.getRatio then
        ratioW, ratioH = _G.screenManager.getRatio()
    end
    local scaledX = x / ratioW
    local scaledY = y / ratioH

    -- Vérifier si le mouvement est dans la zone de la scène (après la toolbar)
    local toolbarHeight = 40
    local zoom = 1.0
    if _G.screenManager and _G.screenManager.getZoom then
        zoom = _G.screenManager.getZoom()
    end

    if scaledY > toolbarHeight then
        -- Mouvement dans la zone de la scène : appliquer le zoom inverse
        local sceneX = 0
        local sceneY = toolbarHeight
        local localX = (scaledX - sceneX) / zoom
        local localY = (scaledY - sceneY) / zoom
        local localDX = dx / ratioW / zoom
        local localDY = dy / ratioH / zoom

        -- Gestion du mouvement dans l'éditeur de scènes
        if _G.sceneEditor then
            _G.sceneEditor.mousemoved(localX, localY, localDX, localDY, istouch)
        end
    else
        -- Mouvement dans l'interface : coordonnées normales
        if _G.sceneEditor then
            _G.sceneEditor.mousemoved(scaledX, scaledY, dx / ratioW, dy / ratioH, istouch)
        end
    end
end

_G.config = config

-- Détection du mode via arguments de ligne de commande
local function detecterMode()
    -- Récupération sécurisée des arguments
    local args = {}

    -- Essai sécurisé d'accès à love.arg
    if love and love.arg then
        -- Utilisation correcte des arguments Love2D
        local parsedArgs = love.arg.parseGameArguments(arg or {})
        local lowArgs = love.arg.getLow(parsedArgs)

        -- Vérification que lowArgs est une table
        if type(lowArgs) == "table" then
            args = lowArgs
        else
            -- Fallback si getLow retourne une string
            args = {}
        end
    else
        -- Fallback : pas d'arguments disponibles
        args = {}
    end

    -- Recherche des flags de mode
    for i, argument in ipairs(args) do
        if type(argument) == "string" then
            if argument == "--dev" or argument == "-d" then
                return MODES.DEV
            elseif argument == "--game" or argument == "-g" then
                return MODES.GAME
            end
        end
    end

    -- Mode par défaut depuis la configuration
    return config.defaultMode == "game" and MODES.GAME or MODES.DEV
end -- Variables globales du mode (initialisées dans love.load)
local modeActuel = nil
_G.gameMode = nil
_G.isDevMode = nil
_G.isGameMode = nil

-- Variables globales du mode (initialisées dans love.load)
local modeActuel = nil
_G.gameMode = nil
_G.isDevMode = nil
_G.isGameMode = nil

-- Fonction d'initialisation du mode (appelée depuis love.load)
local function initialiserMode()
    modeActuel = detecterMode()
    _G.gameMode = modeActuel
    _G.isDevMode = (modeActuel == MODES.DEV)
    _G.isGameMode = (modeActuel == MODES.GAME)
end

-- Initialisation différée des callbacks Love2D
if love then
    function love.load()
        -- Initialisation du mode
        initialiserMode()

        _G.globalFunction.log.info("=== LoveEngine v1.0 ===")
        _G.globalFunction.log.info("Mode: " .. (modeActuel or "UNKNOWN"):upper())

        -- Initialisation du système responsive
        if _G.responsive and _G.responsive.initWindow then
            _G.responsive.initWindow()
        end
        if _G.responsive and _G.responsive.initMouse then
            _G.responsive.initMouse()
        end

        if _G.isDevMode then
            -- Mode Développement : Interface d'outils
            _G.globalFunction.log.info("Initialisation du mode Développement...")
            initialiserModeDev()

            -- Test du système de zoom
            local testZoom = require("test_zoom")
            testZoom.run()
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
            -- Vérifier d'abord si l'éditeur gère cette touche (pour l'édition du nom)
            if _G.sceneEditor and _G.sceneEditor.keypressedSpecial and _G.sceneEditor.keypressedSpecial(key) then
                return
            end
            keypressedModeDev(key, scancode, isrepeat)
        else
            keypressedModeJeu(key, scancode, isrepeat)
        end
    end

    function love.textinput(text)
        if _G.isDevMode and _G.sceneEditor and _G.sceneEditor.textinput then
            _G.sceneEditor.textinput(text)
        end
    end

    function love.mousemoved(x, y, dx, dy, istouch)
        if _G.isDevMode then
            mousemovedModeDev(x, y, dx, dy, istouch)
        else
            mousemovedModeJeu(x, y, dx, dy, istouch)
        end
    end

    function love.mousepressed(x, y, button, istouch, presses)
        if _G.isDevMode then
            mousepressedModeDev(x, y, button, istouch, presses)
        else
            mousepressedModeJeu(x, y, button, istouch, presses)
        end
    end

    function love.mousereleased(x, y, button, istouch, presses)
        if _G.isDevMode then
            mousereleasedModeDev(x, y, button, istouch, presses)
        else
            mousereleasedModeJeu(x, y, button, istouch, presses)
        end
    end

    function love.wheelmoved(x, y)
        if _G.isDevMode then
            wheelmovedModeDev(x, y)
        else
            wheelmovedModeJeu(x, y)
        end
    end

    function love.resize(w, h)
        if _G.isDevMode then
            -- Mettre à jour les ratios responsive
            if _G.screenManager then
                _G.screenManager.UpdateRatio(0)
            end

            -- Recréer l'interface de l'éditeur avec les nouvelles dimensions
            if _G.sceneEditor and _G.sceneEditor.uiRenderer then
                _G.sceneEditor.uiRenderer.createPropertiesContainer()
                _G.globalFunction.log.info("Interface redimensionnée: " .. w .. "x" .. h)
            end
        end
    end
else
    -- Mode hors Love2D (test/console)
    print("LoveEngine: Mode hors Love2D détecté")
    print("Utilisez 'love .' pour lancer avec Love2D")
end

-- =====================================================================
-- MODE DÉVELOPPEMENT
-- =====================================================================

function initialiserModeDev()
    _G.globalFunction.log.info("Interface de développement initialisée")

    -- Initialiser la bibliothèque responsive
    _G.screenManager = require("libreria.tools.responsive")
    if _G.screenManager then
        _G.screenManager.initWindow()
        _G.screenManager.initMouse()
        _G.globalFunction.log.info("Bibliothèque responsive initialisée")
    end

    -- Initialiser l'éditeur de scènes
    if _G.sceneEditor then
        _G.sceneEditor.init()
        _G.globalFunction.log.info("Éditeur de scènes initialisé")
    else
        _G.globalFunction.log.warn("Éditeur de scènes non disponible")
    end

    -- Interface de développement (à implémenter)
    -- Ici on pourra charger les outils de développement :
    -- - Éditeur de scènes
    -- - Inspecteur d'objets
    -- - Console de debug
    -- - Outils de profiling
end

function updateModeDev(dt)
    -- Mise à jour des ratios responsive
    if _G.screenManager then
        _G.screenManager.UpdateRatio(dt)
    end

    -- Mise à jour de l'éditeur de scènes
    if _G.sceneEditor then
        _G.sceneEditor.update(dt)
    end
end

function drawModeDev()
    -- Interface de développement
    love.graphics.clear(0.1, 0.1, 0.2) -- Fond bleu foncé pour le mode dev

    -- Appliquer le scaling responsive (sans zoom pour l'interface)
    local ratioW, ratioH = 1, 1
    if _G.screenManager and _G.screenManager.getRatio then
        ratioW, ratioH = _G.screenManager.getRatio()
    end

    love.graphics.push()
    love.graphics.scale(ratioW, ratioH)

    -- Dessiner l'interface (toolbar, panneaux) sans zoom
    if _G.sceneEditor then
        -- Sauvegarder l'état graphique
        love.graphics.push()

        -- Appliquer le zoom uniquement à la zone de la scène
        local zoom = 1.0
        if _G.screenManager and _G.screenManager.getZoom then
            zoom = _G.screenManager.getZoom()
        end

        -- Calculer la zone de la scène (après la toolbar)
        local toolbarHeight = 40 -- Hauteur de la toolbar
        local sceneX = 0
        local sceneY = toolbarHeight
        local sceneWidth = love.graphics.getWidth() / ratioW
        local sceneHeight = (love.graphics.getHeight() / ratioH) - toolbarHeight

        -- Se positionner à l'origine de la zone scène
        love.graphics.translate(sceneX, sceneY)
        love.graphics.scale(zoom, zoom)

        -- Dessiner uniquement la scène avec zoom
        _G.sceneEditor.drawSceneOnly()

        -- Restaurer l'état graphique
        love.graphics.pop()

        -- Dessiner l'interface (toolbar, panneaux) sans zoom
        _G.sceneEditor.drawInterfaceOnly()

        -- Afficher le niveau de zoom
        if _G.screenManager and _G.screenManager.getZoom then
            local currentZoom = _G.screenManager.getZoom()
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.rectangle("fill", 10, 10, 120, 25)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(string.format("Zoom: %.1f%%", currentZoom * 100), 15, 15)
            love.graphics.setColor(1, 1, 1)
        end
    else
        -- Interface par défaut
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("MODE DÉVELOPPEMENT", 10, 10)
        love.graphics.print("LoveEngine v1.0", 10, 30)
        love.graphics.print("F1: Toggle Console | F2: Scene Editor | F3: Object Inspector", 10, 50)
        love.graphics.print("ESC: Quitter", 10, 70)
        love.graphics.print("Éditeur de scènes non chargé", 10, 90)
    end

    love.graphics.pop()
end

function keypressedModeDev(key, scancode, isrepeat)
    -- Gestion des raccourcis de l'éditeur de scènes
    if _G.sceneEditor then
        _G.sceneEditor.keypressed(key)
    end

    if key == "escape" then
        love.event.quit()
    elseif key == "f1" then
        _G.globalFunction.log.info("Toggle Console (TODO)")
    elseif key == "f2" then
        _G.globalFunction.log.info("Scene Editor activé via F2")
    elseif key == "f3" then
        _G.globalFunction.log.info("Object Inspector (TODO)")
    elseif key == "0" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        -- Ctrl+0 : Reset zoom
        if _G.screenManager and _G.screenManager.resetZoom then
            _G.screenManager.resetZoom()
            _G.screenManager.UpdateRatio(0)
            _G.globalFunction.log.info("Zoom réinitialisé: 100%")
        end
    elseif key == "kp+" or key == "=" then
        -- + : Zoom avant
        if _G.screenManager and _G.screenManager.zoomIn then
            _G.screenManager.zoomIn()
            _G.screenManager.UpdateRatio(0)
            _G.globalFunction.log.info("Zoom avant: " .. string.format("%.1f", _G.screenManager.getZoom() * 100) .. "%")
        end
    elseif key == "kp-" or key == "-" then
        -- - : Zoom arrière
        if _G.screenManager and _G.screenManager.zoomOut then
            _G.screenManager.zoomOut()
            _G.screenManager.UpdateRatio(0)
            _G.globalFunction.log.info("Zoom arrière: " .. string.format("%.1f", _G.screenManager.getZoom() * 100) .. "%")
        end
    end
end

function mousepressedModeDev(x, y, button, istouch, presses)
    -- Appliquer le scaling responsive aux coordonnées de la souris
    local ratioW, ratioH = 1, 1
    if _G.screenManager and _G.screenManager.getRatio then
        ratioW, ratioH = _G.screenManager.getRatio()
    end
    local scaledX = x / ratioW
    local scaledY = y / ratioH

    -- Variables pour la logique de zones
    local toolbarHeight = 40
    local zoom = 1.0
    if _G.screenManager and _G.screenManager.getZoom then
        zoom = _G.screenManager.getZoom()
    end

    -- Vérifier si le clic est dans la zone du panneau des propriétés (côté droit)
    local panelWidth = 300 -- Largeur du panneau des propriétés
    local screenWidth = love.graphics.getWidth() / ratioW
    local panelX = screenWidth - panelWidth

    if scaledX >= panelX then
        -- Clic dans le panneau des propriétés : coordonnées scaled (interface)
        if _G.sceneEditor then
            _G.sceneEditor.mousepressed(scaledX, scaledY, button, istouch, presses)
        end
    elseif scaledY > toolbarHeight then
        -- Clic dans la zone de la scène : appliquer le zoom inverse
        local sceneX = 0
        local sceneY = toolbarHeight
        local localX = (scaledX - sceneX) / zoom
        local localY = (scaledY - sceneY) / zoom

        -- Gestion des clics dans l'éditeur de scènes
        if _G.sceneEditor then
            _G.sceneEditor.mousepressed(localX, localY, button, istouch, presses)
        end
    else
        -- Clic dans l'interface (toolbar) : coordonnées scaled
        if _G.sceneEditor then
            _G.sceneEditor.mousepressed(scaledX, scaledY, button, istouch, presses)
        end
    end
end

function mousemovedModeDev(x, y, dx, dy, istouch)
    -- Appliquer le scaling inverse et le zoom aux coordonnées de la souris
    local ratioW, ratioH = 1, 1
    if _G.screenManager and _G.screenManager.getRatio then
        ratioW, ratioH = _G.screenManager.getRatio()
    end
    local zoom = 1.0
    if _G.screenManager and _G.screenManager.getZoom then
        zoom = _G.screenManager.getZoom()
    end
    local scaledX = (x / ratioW) / zoom
    local scaledY = (y / ratioH) / zoom
    local scaledDX = (dx / ratioW) / zoom
    local scaledDY = (dy / ratioH) / zoom

    -- Gestion des mouvements de souris dans l'éditeur de scènes
    if _G.sceneEditor then
        _G.sceneEditor.mousemoved(scaledX, scaledY, scaledDX, scaledDY)
    end
end

function mousereleasedModeDev(x, y, button, istouch, presses)
    -- Appliquer le scaling responsive aux coordonnées de la souris
    local ratioW, ratioH = 1, 1
    if _G.screenManager and _G.screenManager.getRatio then
        ratioW, ratioH = _G.screenManager.getRatio()
    end
    local scaledX = x / ratioW
    local scaledY = y / ratioH

    -- Vérifier si le relâchement est dans la zone de la scène (après la toolbar)
    local toolbarHeight = 40
    local zoom = 1.0
    if _G.screenManager and _G.screenManager.getZoom then
        zoom = _G.screenManager.getZoom()
    end

    if scaledY > toolbarHeight then
        -- Relâchement dans la zone de la scène : appliquer le zoom inverse
        local sceneX = 0
        local sceneY = toolbarHeight
        local localX = (scaledX - sceneX) / zoom
        local localY = (scaledY - sceneY) / zoom

        -- Gestion du relâchement dans l'éditeur de scènes
        if _G.sceneEditor then
            _G.sceneEditor.mousereleased(localX, localY, button)
        end
    else
        -- Relâchement dans l'interface : coordonnées normales
        if _G.sceneEditor then
            _G.sceneEditor.mousereleased(scaledX, scaledY, button)
        end
    end
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

function mousemovedModeJeu(x, y, dx, dy, istouch)
    -- Gestion des mouvements de souris dans le jeu
end

function mousereleasedModeJeu(x, y, button, istouch, presses)
    -- Gestion du relâchement de souris dans le jeu
end

function wheelmovedModeDev(x, y)
    -- Gestion du zoom avec la molette de souris
    if _G.screenManager then
        if y > 0 then
            -- Zoom avant (molette vers le haut)
            _G.screenManager.zoomIn()
            _G.globalFunction.log.info("Zoom avant: " .. string.format("%.1f", _G.screenManager.getZoom() * 100) .. "%")
        elseif y < 0 then
            -- Zoom arrière (molette vers le bas)
            _G.screenManager.zoomOut()
            _G.globalFunction.log.info("Zoom arrière: " .. string.format("%.1f", _G.screenManager.getZoom() * 100) .. "%")
        end
        -- Mettre à jour les ratios après le changement de zoom
        _G.screenManager.UpdateRatio(0)
    end
end

function wheelmovedModeJeu(x, y)
    -- Gestion du zoom dans le mode jeu (si nécessaire)
end
