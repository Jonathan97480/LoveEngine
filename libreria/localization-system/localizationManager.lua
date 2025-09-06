-- =========================================================================
-- LOCALIZATION MANAGER - Gestionnaire Principal Multi-Langue
-- =========================================================================
-- Auteur: GitHub Copilot
-- Date: 2 septembre 2025
-- Description: Système complet de localisation FR/EN avec JSON et variables
-- =========================================================================

local localizationManager = {}

-- =========================================================================
-- CONFIGURATION ET VARIABLES GLOBALES
-- =========================================================================

-- Configuration par défaut
local DEFAULT_LANGUAGE = "fr"
local FALLBACK_LANGUAGE = "fr"
local LOCALIZATION_PATH = "localization/"

-- État interne du système
local currentLanguage = DEFAULT_LANGUAGE
local loadedTexts = {}
local availableLanguages = {}
local isInitialized = false

-- Cache pour optimisation
local textCache = {}
local lastLoadTime = {}

-- Logs et debugging
local function log(level, message)
    if _G.globalFunction and _G.globalFunction.log then
        _G.globalFunction.log[level](string.format("[LocalizationManager] %s", message))
    else
        print(string.format("[%s] LocalizationManager: %s", level:upper(), message))
    end
end

-- =========================================================================
-- CHARGEMENT ET GESTION DES FICHIERS JSON
-- =========================================================================

-- Chargeur de fichier JSON sécurisé
local function loadJSONFile(filepath)
    local file = love.filesystem.newFile(filepath)
    if not file then
        log("error", "Impossible d'ouvrir le fichier: " .. filepath)
        return nil
    end

    local success, errormsg = file:open("r")
    if not success then
        log("error", "Impossible de lire le fichier: " .. filepath .. " - " .. tostring(errormsg))
        return nil
    end

    local content = file:read()
    file:close()

    if not content then
        log("error", "Contenu vide pour: " .. filepath)
        return nil
    end

    -- Parser JSON avec gestion d'erreur
    local json = _G.json or require("libreria/tools/json")
    local success, data = pcall(json.decode, content)

    if not success then
        log("error", "Erreur parsing JSON pour " .. filepath .. ": " .. tostring(data))
        return nil
    end

    log("info", "Fichier chargé avec succès: " .. filepath)
    return data
end

-- Scan des langues disponibles
local function scanAvailableLanguages()
    availableLanguages = {}

    -- Liste des fichiers dans le dossier localization
    local files = love.filesystem.getDirectoryItems(LOCALIZATION_PATH)

    for _, filename in ipairs(files) do
        if filename:match("%.json$") then
            local langCode = filename:gsub("%.json$", "")
            local filepath = LOCALIZATION_PATH .. filename

            -- Validation du fichier
            local data = loadJSONFile(filepath)
            if data and data.meta and data.meta.language then
                availableLanguages[langCode] = {
                    code = langCode,
                    name = data.meta.name or langCode,
                    version = data.meta.version or "1.0",
                    filepath = filepath
                }
                log("info", string.format("Langue détectée: %s (%s)", langCode, data.meta.name or langCode))
            end
        end
    end

    -- Assurer qu'au moins le français est disponible
    if not availableLanguages[FALLBACK_LANGUAGE] then
        log("warn", "Langue de fallback '" .. FALLBACK_LANGUAGE .. "' non trouvée")
    end

    log("info", string.format("Scan terminé: %d langues disponibles", table.getn(availableLanguages)))
end

-- Chargement d'une langue spécifique
local function loadLanguage(langCode)
    if not langCode then
        log("error", "Code langue requis pour loadLanguage")
        return false
    end

    local langInfo = availableLanguages[langCode]
    if not langInfo then
        log("error", "Langue non disponible: " .. langCode)
        return false
    end

    -- Vérifier cache et temps de modification
    local currentTime = love.timer.getTime()
    if loadedTexts[langCode] and
        lastLoadTime[langCode] and
        (currentTime - lastLoadTime[langCode]) < 30 then -- Cache 30 secondes
        log("info", "Utilisation cache pour langue: " .. langCode)
        return true
    end

    -- Charger le fichier JSON
    local data = loadJSONFile(langInfo.filepath)
    if not data then
        log("error", "Impossible de charger la langue: " .. langCode)
        return false
    end

    -- Valider la structure
    if not data.ui or not data.cards or not data.meta then
        log("error", "Structure JSON invalide pour langue: " .. langCode)
        return false
    end

    -- Stocker les données
    loadedTexts[langCode] = data
    lastLoadTime[langCode] = currentTime

    -- Vider le cache de traduction
    textCache = {}

    log("info", string.format("Langue chargée: %s v%s", langCode, data.meta.version or "1.0"))
    return true
end

-- =========================================================================
-- API PUBLIQUE DE TRADUCTION
-- =========================================================================

-- Fonction principale de traduction avec variables
function localizationManager.t(key, variables)
    if not key or key == "" then
        log("error", "Clé de traduction requise")
        return "[MISSING_KEY]"
    end

    -- Vérifier cache
    local cacheKey = currentLanguage .. ":" .. key .. (variables and table.concat(variables or {}, ",") or "")
    if textCache[cacheKey] then
        return textCache[cacheKey]
    end

    -- Récupérer le texte traduit
    local text = localizationManager.getText(key, currentLanguage)

    -- Appliquer formatage avec variables si nécessaire
    if variables and type(variables) == "table" then
        text = localizationManager.formatText(text, variables)
    end

    -- Mettre en cache
    textCache[cacheKey] = text
    return text
end

-- Récupération de texte avec fallback
function localizationManager.getText(key, langCode)
    langCode = langCode or currentLanguage

    if not loadedTexts[langCode] then
        log("warn", "Langue non chargée: " .. langCode)
        return "[LANG_NOT_LOADED:" .. key .. "]"
    end

    -- Navigation dans la structure JSON avec clés séparées par des points
    local keys = {}
    for k in key:gmatch("[^%.]+") do
        table.insert(keys, k)
    end

    local current = loadedTexts[langCode]
    for _, k in ipairs(keys) do
        if type(current) == "table" and current[k] then
            current = current[k]
        else
            -- Fallback vers langue par défaut si différente
            if langCode ~= FALLBACK_LANGUAGE then
                log("warn",
                    string.format("Clé manquante '%s' pour langue '%s', fallback vers '%s'", key, langCode,
                        FALLBACK_LANGUAGE))
                return localizationManager.getText(key, FALLBACK_LANGUAGE)
            else
                log("error", "Clé de traduction manquante: " .. key)
                return "[MISSING:" .. key .. "]"
            end
        end
    end

    if type(current) == "string" then
        return current
    else
        log("error", "Clé ne pointe pas vers une chaîne: " .. key)
        return "[INVALID:" .. key .. "]"
    end
end

-- Formatage de texte avec variables
function localizationManager.formatText(text, variables)
    if not text or not variables then
        return text
    end

    local result = text

    -- Remplacer variables {nom} par leur valeur
    for key, value in pairs(variables) do
        local pattern = "{" .. key .. "}"
        result = result:gsub(pattern, tostring(value))
    end

    return result
end

-- =========================================================================
-- GESTION DES LANGUES
-- =========================================================================

-- Changer la langue courante
function localizationManager.setLanguage(langCode)
    if not langCode then
        log("error", "Code langue requis")
        return false
    end

    if langCode == currentLanguage then
        log("info", "Langue déjà active: " .. langCode)
        return true
    end

    if not availableLanguages[langCode] then
        log("error", "Langue non disponible: " .. langCode)
        return false
    end

    -- Charger la nouvelle langue
    if not loadLanguage(langCode) then
        log("error", "Impossible de charger la langue: " .. langCode)
        return false
    end

    -- Mettre à jour la langue courante
    local oldLang = currentLanguage
    currentLanguage = langCode

    -- Vider le cache
    textCache = {}

    log("info", string.format("Langue changée: %s → %s", oldLang, langCode))

    -- Déclencher événement de changement de langue si disponible
    if _G.eventBus and _G.eventBus.emit then
        _G.eventBus.emit("language_changed", {
            from = oldLang,
            to = langCode
        })
    end

    return true
end

-- Obtenir la langue courante
function localizationManager.getCurrentLanguage()
    return currentLanguage
end

-- Obtenir les langues disponibles
function localizationManager.getAvailableLanguages()
    local result = {}
    for code, info in pairs(availableLanguages) do
        table.insert(result, {
            code = code,
            name = info.name,
            version = info.version
        })
    end
    return result
end

-- Vérifier si une langue est disponible
function localizationManager.isLanguageAvailable(langCode)
    return availableLanguages[langCode] ~= nil
end

-- =========================================================================
-- INTÉGRATION AVEC CARTES
-- =========================================================================

-- Traduction spécialisée pour cartes
function localizationManager.getCardText(cardId, textType, variables)
    if not cardId or not textType then
        log("error", "cardId et textType requis")
        return "[MISSING_CARD_DATA]"
    end

    local key = "cards." .. textType .. "." .. cardId
    return localizationManager.t(key, variables)
end

-- Traduction nom de carte
function localizationManager.getCardName(cardId)
    return localizationManager.getCardText(cardId, "names")
end

-- Traduction description de carte avec variables
function localizationManager.getCardDescription(cardId, variables)
    return localizationManager.getCardText(cardId, "descriptions", variables)
end

-- =========================================================================
-- INITIALISATION ET LIFECYCLE
-- =========================================================================

-- Initialisation du système
function localizationManager.initialize()
    if isInitialized then
        log("warn", "LocalizationManager déjà initialisé")
        return true
    end

    log("info", "Initialisation du LocalizationManager...")

    -- Scanner les langues disponibles
    scanAvailableLanguages()

    -- Charger la langue par défaut
    if not loadLanguage(DEFAULT_LANGUAGE) then
        log("error", "Impossible de charger la langue par défaut: " .. DEFAULT_LANGUAGE)
        return false
    end

    currentLanguage = DEFAULT_LANGUAGE
    isInitialized = true

    log("info", "LocalizationManager initialisé avec succès")
    return true
end

-- Rechargement à chaud
function localizationManager.reload()
    log("info", "Rechargement du système de localisation...")

    -- Vider les caches
    textCache = {}
    loadedTexts = {}
    lastLoadTime = {}

    -- Re-scanner et recharger
    scanAvailableLanguages()
    return loadLanguage(currentLanguage)
end

-- Status du système
function localizationManager.getStatus()
    return {
        initialized = isInitialized,
        currentLanguage = currentLanguage,
        availableLanguages = table.getn(availableLanguages),
        cacheSize = table.getn(textCache),
        loadedLanguages = {}
    }
end

-- =========================================================================
-- UTILITAIRES ET HELPERS
-- =========================================================================

-- Traduction rapide pour interface (alias court)
_G.t = function(key, variables)
    return localizationManager.t(key, variables)
end

-- Export du module
return localizationManager
