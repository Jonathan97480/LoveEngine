-- =========================================================================
-- TEXT LOADER - Chargeur de Fichiers JSON de Localisation
-- =========================================================================
-- Auteur: GitHub Copilot
-- Date: 2 septembre 2025
-- Description: Utilitaires spécialisés pour chargement et validation JSON
-- =========================================================================

local textLoader = {}

-- =========================================================================
-- CONFIGURATION
-- =========================================================================

local SUPPORTED_VERSIONS = { "1.0", "1.1" }
local REQUIRED_SECTIONS = { "meta", "ui", "cards" }

-- =========================================================================
-- VALIDATION DE STRUCTURE JSON
-- =========================================================================

-- Validation de la structure JSON de localisation
function textLoader.validateStructure(data, filepath)
    if not data then
        return false, "Données JSON vides"
    end

    -- Vérifier la présence des sections requises
    for _, section in ipairs(REQUIRED_SECTIONS) do
        if not data[section] then
            return false, "Section manquante: " .. section
        end
    end

    -- Validation section meta
    if not data.meta.language then
        return false, "meta.language requis"
    end

    if not data.meta.name then
        return false, "meta.name requis"
    end

    -- Vérifier version supportée
    local version = data.meta.version or "1.0"
    local versionSupported = false
    for _, supportedVersion in ipairs(SUPPORTED_VERSIONS) do
        if version == supportedVersion then
            versionSupported = true
            break
        end
    end

    if not versionSupported then
        return false, "Version non supportée: " .. version
    end

    -- Validation section UI
    if not data.ui.menu then
        return false, "ui.menu requis"
    end

    local requiredMenuItems = { "play", "options", "quit" }
    for _, item in ipairs(requiredMenuItems) do
        if not data.ui.menu[item] then
            return false, "ui.menu." .. item .. " requis"
        end
    end

    -- Validation section cartes
    if not data.cards.names then
        return false, "cards.names requis"
    end

    if not data.cards.descriptions then
        return false, "cards.descriptions requis"
    end

    return true, "Structure valide"
end

-- =========================================================================
-- CHARGEMENT OPTIMISÉ
-- =========================================================================

-- Chargement avec cache et validation
function textLoader.loadWithValidation(filepath)
    -- Vérifier que le fichier existe
    if not love.filesystem.getInfo(filepath) then
        return nil, "Fichier non trouvé: " .. filepath
    end

    -- Charger le contenu brut
    local content, err = love.filesystem.read(filepath)
    if not content then
        return nil, "Impossible de lire le fichier: " .. (err or "erreur inconnue")
    end

    -- Parser JSON
    local json = _G.json or require("libreria/tools/json")
    local success, data = pcall(json.decode, content)

    if not success then
        return nil, "Erreur parsing JSON: " .. tostring(data)
    end

    -- Valider la structure
    local valid, validationError = textLoader.validateStructure(data, filepath)
    if not valid then
        return nil, "Validation échouée: " .. validationError
    end

    return data, nil
end

-- Chargement avec fallback
function textLoader.loadWithFallback(filepath, fallbackPath)
    -- Essayer le fichier principal
    local data, err = textLoader.loadWithValidation(filepath)
    if data then
        return data, nil
    end

    -- Si échec, essayer le fallback
    if fallbackPath and fallbackPath ~= filepath then
        local fallbackData, fallbackErr = textLoader.loadWithValidation(fallbackPath)
        if fallbackData then
            return fallbackData, "Chargé depuis fallback: " .. fallbackPath
        end

        return nil, "Échec principal et fallback: " .. err .. " / " .. fallbackErr
    end

    return nil, err
end

-- =========================================================================
-- OPTIMISATION ET CACHE
-- =========================================================================

-- Cache local pour éviter recharges multiples
local fileCache = {}
local cacheTimestamps = {}
local CACHE_DURATION = 60 -- secondes

-- Chargement avec cache temporel
function textLoader.loadCached(filepath)
    local currentTime = love.timer.getTime()

    -- Vérifier cache existant
    if fileCache[filepath] and cacheTimestamps[filepath] then
        local cacheAge = currentTime - cacheTimestamps[filepath]
        if cacheAge < CACHE_DURATION then
            return fileCache[filepath], "from_cache"
        end
    end

    -- Charger depuis disque
    local data, err = textLoader.loadWithValidation(filepath)
    if data then
        fileCache[filepath] = data
        cacheTimestamps[filepath] = currentTime
        return data, "from_disk"
    end

    return nil, err
end

-- Invalidation cache
function textLoader.invalidateCache(filepath)
    if filepath then
        fileCache[filepath] = nil
        cacheTimestamps[filepath] = nil
    else
        -- Vider tout le cache
        fileCache = {}
        cacheTimestamps = {}
    end
end

-- =========================================================================
-- UTILITAIRES D'ANALYSE
-- =========================================================================

-- Analyser les clés manquantes entre deux fichiers de langue
function textLoader.compareLanguageFiles(baseFilepath, compareFilepath)
    local baseData, baseErr = textLoader.loadWithValidation(baseFilepath)
    if not baseData then
        return nil, "Impossible de charger fichier de base: " .. baseErr
    end

    local compareData, compareErr = textLoader.loadWithValidation(compareFilepath)
    if not compareData then
        return nil, "Impossible de charger fichier de comparaison: " .. compareErr
    end

    local missingKeys = {}
    local extraKeys = {}

    -- Fonction récursive pour explorer les clés
    local function exploreKeys(base, compare, currentPath)
        currentPath = currentPath or ""

        -- Vérifier clés manquantes dans compare
        for key, value in pairs(base) do
            local fullKey = currentPath == "" and key or currentPath .. "." .. key

            if compare[key] == nil then
                table.insert(missingKeys, fullKey)
            elseif type(value) == "table" and type(compare[key]) == "table" then
                exploreKeys(value, compare[key], fullKey)
            end
        end

        -- Vérifier clés supplémentaires dans compare
        for key, value in pairs(compare) do
            local fullKey = currentPath == "" and key or currentPath .. "." .. key

            if base[key] == nil then
                table.insert(extraKeys, fullKey)
            end
        end
    end

    exploreKeys(baseData, compareData)

    return {
        missingKeys = missingKeys,
        extraKeys = extraKeys,
        baseLanguage = baseData.meta.language,
        compareLanguage = compareData.meta.language
    }
end

-- Statistiques d'un fichier de langue
function textLoader.getLanguageStats(filepath)
    local data, err = textLoader.loadWithValidation(filepath)
    if not data then
        return nil, err
    end

    local stats = {
        language = data.meta.language,
        name = data.meta.name,
        version = data.meta.version,
        totalKeys = 0,
        sections = {}
    }

    -- Compter les clés récursivement
    local function countKeys(obj, sectionName)
        local count = 0
        if type(obj) == "table" then
            for key, value in pairs(obj) do
                if type(value) == "string" then
                    count = count + 1
                elseif type(value) == "table" then
                    count = count + countKeys(value, sectionName)
                end
            end
        end
        return count
    end

    -- Analyser chaque section
    for section, content in pairs(data) do
        if section ~= "meta" then
            local keyCount = countKeys(content, section)
            stats.sections[section] = keyCount
            stats.totalKeys = stats.totalKeys + keyCount
        end
    end

    return stats
end

-- =========================================================================
-- EXPORT DU MODULE
-- =========================================================================

return textLoader
