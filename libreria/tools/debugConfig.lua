-- ========================================
-- SYSTÈME DE CONFIGURATION DEBUG CENTRALISÉ
-- ========================================
-- Module central pour tous les flags de debug du projet
-- Remplace les variables dispersées par un namespace unifié

local DebugConfig = {}

local globalFunction = require("libreria/tools/globalFunction")

-- ========================================
-- FLAGS DE DEBUG CENTRALISÉS
-- ========================================

-- Structure centralisée de configuration debug
DebugConfig.FLAGS = {
    -- Core System Debug
    GLOBAL_DEBUG = false, -- Debug global du système
    VERBOSE_MODE = false, -- Mode ultra-verbeux (tous logs)

    -- Gameplay Debug
    GAMEPLAY = false,      -- Debug scene gameplay
    TRANSITIONS = false,   -- Debug système transitions
    SCENE_MANAGER = false, -- Debug navigation scènes

    -- Card System Debug
    TARGET_SELECTION = false, -- Debug sélection cibles
    TARGET_VERBOSE = false,   -- Logs ultra-détaillés ciblage
    STANDBY_SYSTEM = false,   -- Debug système standby cartes
    CARD_EFFECTS = false,     -- Debug effets cartes

    -- HUD Debug
    HUD_ENERGY = false,     -- Debug énergie/santé HUD
    HUD_BUTTONS = false,    -- Debug interactions boutons
    HUD_RESPONSIVE = false, -- Debug système responsive
    HUD_RENDER = false,     -- Debug rendu HUD

    -- AI Debug
    AI_CONTROLLER = false, -- Debug contrôleur IA
    AI_DECISIONS = false,  -- Debug décisions IA
    AI_SAFECALL = false,   -- Debug appels sécurisés IA

    -- Performance Debug
    CACHE_MONITOR = false,   -- Debug cache ressources
    MEMORY_TRACKING = false, -- Debug gestion mémoire
    FRAME_TIME = false,      -- Debug temps frame

    -- Input Debug
    INPUT_EVENTS = false,   -- Debug événements input
    MOUSE_TRACKING = false, -- Debug suivi souris
    GAMEPAD_INPUT = false,  -- Debug manette
}

-- ========================================
-- MIGRATION AUTOMATIQUE FLAGS LEGACY
-- ========================================

-- Fonction de migration des anciens flags vers le nouveau système
function DebugConfig.migrateLegacyFlags()
    if globalFunction and globalFunction.log then
        globalFunction.log.info("🔄 Migration flags debug legacy vers système centralisé...")
    end

    -- Migration GameFlags existants
    if _G.GameFlags then
        if _G.GameFlags.debug_mode then
            DebugConfig.FLAGS.GLOBAL_DEBUG = _G.GameFlags.debug_mode
        end
        if _G.GameFlags.hud_debug_energy then
            DebugConfig.FLAGS.HUD_ENERGY = _G.GameFlags.hud_debug_energy
        end
    end

    -- Migration flags globaux dispersés
    if rawget(_G, "DEBUG_TARGET_SELECTION") then
        DebugConfig.FLAGS.TARGET_SELECTION = _G.DEBUG_TARGET_SELECTION
    end
    if rawget(_G, "DEBUG_TARGET_VERBOSE") then
        DebugConfig.FLAGS.TARGET_VERBOSE = _G.DEBUG_TARGET_VERBOSE
    end

    -- Migration config cartes
    local cardConfig = rawget(_G, "config")
    if cardConfig and cardConfig.STANDBY and cardConfig.STANDBY.DEBUG_ENABLED then
        DebugConfig.FLAGS.STANDBY_SYSTEM = cardConfig.STANDBY.DEBUG_ENABLED
    end

    if globalFunction and globalFunction.log then
        globalFunction.log.info("✅ Migration flags debug terminée")
    end
end

-- ========================================
-- API CONFIGURATION DEBUG
-- ========================================

-- Active un flag de debug spécifique
function DebugConfig.enable(flagName)
    if DebugConfig.FLAGS[flagName] ~= nil then
        DebugConfig.FLAGS[flagName] = true
        local gf = _G.globalFunction
        if gf and gf.log then
            gf.log.info(string.format("🔧 Debug activé: %s", flagName))
        end
        return true
    end
    return false
end

-- Désactive un flag de debug spécifique
function DebugConfig.disable(flagName)
    if DebugConfig.FLAGS[flagName] ~= nil then
        DebugConfig.FLAGS[flagName] = false
        local gf = _G.globalFunction
        if gf and gf.log then
            gf.log.info(string.format("🔧 Debug désactivé: %s", flagName))
        end
        return true
    end
    return false
end

-- Toggle un flag de debug
function DebugConfig.toggle(flagName)
    if DebugConfig.FLAGS[flagName] ~= nil then
        DebugConfig.FLAGS[flagName] = not DebugConfig.FLAGS[flagName]
        local state = DebugConfig.FLAGS[flagName] and "activé" or "désactivé"
        local gf = _G.globalFunction
        if gf and gf.log then
            gf.log.info(string.format("🔧 Debug %s: %s", state, flagName))
        end
        return DebugConfig.FLAGS[flagName]
    end
    return nil
end

-- Vérifie si un flag est activé
function DebugConfig.isEnabled(flagName)
    return DebugConfig.FLAGS[flagName] == true
end

-- Active mode debug global (tous les flags)
function DebugConfig.enableAll()
    for flag, _ in pairs(DebugConfig.FLAGS) do
        DebugConfig.FLAGS[flag] = true
    end
    local gf = _G.globalFunction
    if gf and gf.log then
        gf.log.warn("🔥 Mode debug GLOBAL activé - TOUS les flags actifs")
    end
end

-- Désactive tous les flags debug
function DebugConfig.disableAll()
    for flag, _ in pairs(DebugConfig.FLAGS) do
        DebugConfig.FLAGS[flag] = false
    end
    local gf = _G.globalFunction
    if gf and gf.log then
        gf.log.info("🔇 Tous flags debug désactivés")
    end
end

-- ========================================
-- PRESETS DE CONFIGURATION
-- ========================================

-- Preset développement : debug essentiel
function DebugConfig.setDevelopmentMode()
    DebugConfig.disableAll()
    DebugConfig.FLAGS.GLOBAL_DEBUG = true
    DebugConfig.FLAGS.GAMEPLAY = true
    DebugConfig.FLAGS.HUD_ENERGY = true
    DebugConfig.FLAGS.AI_CONTROLLER = true

    local gf = _G.globalFunction
    if gf and gf.log then
        gf.log.info("🔧 Mode développement activé (debug essentiel)")
    end
end

-- Preset production : debug minimal
function DebugConfig.setProductionMode()
    DebugConfig.disableAll()
    -- Garder seulement erreurs critiques
    DebugConfig.FLAGS.AI_SAFECALL = true

    local gf = _G.globalFunction
    if gf and gf.log then
        gf.log.info("🚀 Mode production activé (debug minimal)")
    end
end

-- Preset debug complet : tout activé
function DebugConfig.setVerboseMode()
    DebugConfig.enableAll()
    local gf = _G.globalFunction
    if gf and gf.log then
        gf.log.warn("📢 Mode VERBOSE activé - Performance réduite !")
    end
end

-- ========================================
-- UTILITAIRES DEBUG
-- ========================================

-- Affiche l'état de tous les flags
function DebugConfig.printStatus()
    print("\n=== ÉTAT FLAGS DEBUG ===")

    local categories = {
        ["Core"] = { "GLOBAL_DEBUG", "VERBOSE_MODE" },
        ["Gameplay"] = { "GAMEPLAY", "TRANSITIONS", "SCENE_MANAGER" },
        ["Cards"] = { "TARGET_SELECTION", "TARGET_VERBOSE", "STANDBY_SYSTEM", "CARD_EFFECTS" },
        ["HUD"] = { "HUD_ENERGY", "HUD_BUTTONS", "HUD_RESPONSIVE", "HUD_RENDER" },
        ["AI"] = { "AI_CONTROLLER", "AI_DECISIONS", "AI_SAFECALL" },
        ["Performance"] = { "CACHE_MONITOR", "MEMORY_TRACKING", "FRAME_TIME" },
        ["Input"] = { "INPUT_EVENTS", "MOUSE_TRACKING", "GAMEPAD_INPUT" }
    }

    for category, flags in pairs(categories) do
        print(string.format("\n📂 %s:", category))
        for _, flag in ipairs(flags) do
            local status = DebugConfig.FLAGS[flag] and "✅" or "❌"
            print(string.format("   %s %s", status, flag))
        end
    end

    -- Statistiques
    local activeCount = 0
    for _, enabled in pairs(DebugConfig.FLAGS) do
        if enabled then activeCount = activeCount + 1 end
    end

    print(string.format("\n📊 Actifs: %d/%d flags", activeCount,
        (function()
            local c = 0; for _ in pairs(DebugConfig.FLAGS) do c = c + 1 end
            return c
        end)()))
    print("========================\n")
end

-- Sauvegarde la configuration dans un fichier
function DebugConfig.saveConfig(filename)
    filename = filename or "debug_config.lua"

    local file = io.open(filename, "w")
    if not file then
        print("❌ Erreur: Impossible de sauvegarder " .. filename)
        return false
    end

    file:write("-- Configuration debug générée automatiquement\n")
    file:write("-- Date: " .. os.date() .. "\n\n")
    file:write("return {\n")

    for flag, enabled in pairs(DebugConfig.FLAGS) do
        file:write(string.format("    %s = %s,\n", flag, tostring(enabled)))
    end

    file:write("}\n")
    file:close()

    print("✅ Configuration sauvegardée: " .. filename)
    return true
end

-- Charge la configuration depuis un fichier
function DebugConfig.loadConfig(filename)
    filename = filename or "debug_config.lua"

    local chunk, err = loadfile(filename)
    if not chunk then
        print("❌ Erreur chargement: " .. (err or "Fichier non trouvé"))
        return false
    end

    local config = chunk()
    if type(config) ~= "table" then
        print("❌ Erreur: Configuration invalide")
        return false
    end

    -- Appliquer configuration
    for flag, enabled in pairs(config) do
        if DebugConfig.FLAGS[flag] ~= nil then
            DebugConfig.FLAGS[flag] = enabled
        end
    end

    print("✅ Configuration chargée: " .. filename)
    return true
end

-- ========================================
-- INTÉGRATION SYSTÈME
-- ========================================

-- Fonction d'initialisation à appeler au démarrage
function DebugConfig.init()
    -- Migration des anciens flags
    DebugConfig.migrateLegacyFlags()

    -- Configuration par défaut (production - réduction verbosité)
    DebugConfig.setProductionMode()

    -- Exposition globale pour accès facile
    _G.DebugConfig = DebugConfig

    local gf = _G.globalFunction
    if gf and gf.log then
        gf.log.info("🎯 Système debug centralisé initialisé")
    end
end

-- Helpers pour compatibilité
function DebugConfig.isGameplayDebug()
    return DebugConfig.isEnabled("GAMEPLAY")
end

function DebugConfig.isHUDDebug()
    return DebugConfig.isEnabled("HUD_ENERGY") or DebugConfig.isEnabled("HUD_BUTTONS")
end

function DebugConfig.isVerbose()
    return DebugConfig.isEnabled("VERBOSE_MODE") or DebugConfig.isEnabled("TARGET_VERBOSE")
end

return DebugConfig
