-- Enhanced resource cache with monitoring and memory management.
local res = {}

-- Chargement sécurisé des utilitaires
local function _safeRequire(name)
    local ok, mod = pcall(require, name)
    return ok and mod or nil
end

local globalFunction = rawget(_G, 'globalFunction')

-- Configuration du cache
local CACHE_CONFIG = {
    ENABLE_MONITORING = true, -- Activer/désactiver le monitoring
    ENABLE_CLEANUP = true,    -- Activer/désactiver le nettoyage automatique
    MAX_CACHE_SIZE = 200,     -- Limite d'éléments par type de cache
    CLEANUP_THRESHOLD = 0.8,  -- Seuil de nettoyage (80% de la limite)
    LOG_HIT_MISS = false,     -- Logs détaillés hit/miss (peut être verbeux)
}

-- Métriques de monitoring
local _stats = {
    images = { hits = 0, misses = 0, count = 0 },
    fonts = { hits = 0, misses = 0, count = 0 },
    audio = { hits = 0, misses = 0, count = 0 },
    last_cleanup = 0,
    total_memory_saves = 0
}

-- Fonction utilitaire de logging
local function _log(level, msg)
    if globalFunction and globalFunction.log and globalFunction.log[level] then
        globalFunction.log[level]("[ResourceCache] " .. msg)
    end
end

-- Fonction de nettoyage intelligent
local function _cleanupIfNeeded(cacheTable, cacheType, maxSize)
    if not CACHE_CONFIG.ENABLE_CLEANUP then return end

    local count = 0
    for _ in pairs(cacheTable) do count = count + 1 end

    if count >= maxSize * CACHE_CONFIG.CLEANUP_THRESHOLD then
        _log("warn", string.format("Cache %s proche de la limite (%d/%d) - Nettoyage requis",
            cacheType, count, maxSize))
        return true
    end
    return false
end

-- Fonction de validation des entrées
local function _validatePath(path, functionName)
    if type(path) ~= "string" then
        error(string.format("%s expects a string path, got %s", functionName, type(path)), 3)
    end
    if path == "" then
        error(string.format("%s: path cannot be empty", functionName), 3)
    end
    return true
end

local _images = {}
--[[*
    Charge une image et la met en cache avec monitoring intégré.
    @param path Le chemin de l'image à charger.
    @return L'image chargée ou nil en cas d'erreur.
--]]
function res.image(path)
    _validatePath(path, "res.image")

    local wasHit = _images[path] ~= nil

    if not _images[path] then
        -- Vérifier si nettoyage nécessaire
        if _cleanupIfNeeded(_images, "images", CACHE_CONFIG.MAX_CACHE_SIZE) then
            _log("info", "Limite cache images atteinte - Considérer augmenter MAX_CACHE_SIZE")
        end

        -- Chargement avec protection d'erreur
        local success, result = pcall(love.graphics.newImage, path)
        if success then
            _images[path] = result
            _stats.images.count = _stats.images.count + 1
            _stats.images.misses = _stats.images.misses + 1

            if CACHE_CONFIG.LOG_HIT_MISS then
                _log("info", string.format("MISS: Image chargée '%s' (total: %d)",
                    path, _stats.images.count))
            end
        else
            _log("error", string.format("Échec chargement image '%s': %s", path, result))
            return nil
        end
    else
        _stats.images.hits = _stats.images.hits + 1
        _stats.total_memory_saves = _stats.total_memory_saves + 1

        if CACHE_CONFIG.LOG_HIT_MISS then
            _log("info", string.format("HIT: Image en cache '%s'", path))
        end
    end

    return _images[path]
end

local _fonts = {}
--[[*
    Charge une font et la met en cache avec monitoring intégré.
    @param path_or_size Le chemin de la font ou la taille par défaut.
    @param size La taille de la font (optionnel si path_or_size est un nombre).
    @return La font chargée ou nil en cas d'erreur.
--]]
function res.font(path_or_size, size)
    local key, isDefault

    if type(path_or_size) == "number" then
        key = "__default__:" .. tostring(path_or_size)
        isDefault = true
        if path_or_size <= 0 then
            _log("error", string.format("Taille de font invalide: %d", path_or_size))
            return nil
        end
    else
        _validatePath(path_or_size, "res.font")
        local s = size or 12
        if s <= 0 then
            _log("error", string.format("Taille de font invalide: %d", s))
            return nil
        end
        key = path_or_size .. ":" .. tostring(s)
        isDefault = false
    end

    local wasHit = _fonts[key] ~= nil

    if not _fonts[key] then
        -- Vérifier si nettoyage nécessaire
        if _cleanupIfNeeded(_fonts, "fonts", CACHE_CONFIG.MAX_CACHE_SIZE) then
            _log("info", "Limite cache fonts atteinte - Considérer augmenter MAX_CACHE_SIZE")
        end

        -- Chargement avec protection d'erreur
        local success, result
        if isDefault then
            success, result = pcall(love.graphics.newFont, path_or_size)
        else
            success, result = pcall(love.graphics.newFont, path_or_size, size or 12)
        end

        if success then
            _fonts[key] = result
            _stats.fonts.count = _stats.fonts.count + 1
            _stats.fonts.misses = _stats.fonts.misses + 1

            if CACHE_CONFIG.LOG_HIT_MISS then
                _log("info", string.format("MISS: Font chargée '%s' (total: %d)",
                    key, _stats.fonts.count))
            end
        else
            _log("error", string.format("Échec chargement font '%s': %s", key, result))
            return nil
        end
    else
        _stats.fonts.hits = _stats.fonts.hits + 1
        _stats.total_memory_saves = _stats.total_memory_saves + 1

        if CACHE_CONFIG.LOG_HIT_MISS then
            _log("info", string.format("HIT: Font en cache '%s'", key))
        end
    end

    return _fonts[key]
end

local _sources = {}
--[[*
    Charge un fichier audio et le met en cache avec monitoring intégré.
    @param path Le chemin du fichier audio.
    @param type_hint Le type de source audio ("static" ou "stream").
    @return Une nouvelle instance de la source audio ou nil en cas d'erreur.
--]]
function res.audio(path, type_hint)
    _validatePath(path, "res.audio")

    local audioType = type_hint or "static"
    if audioType ~= "static" and audioType ~= "stream" then
        _log("warn", string.format("Type audio inconnu '%s', utilisation 'static'", audioType))
        audioType = "static"
    end

    local key = path .. ":" .. audioType
    local wasHit = _sources[key] ~= nil

    if not _sources[key] then
        -- Vérifier si nettoyage nécessaire
        if _cleanupIfNeeded(_sources, "audio", CACHE_CONFIG.MAX_CACHE_SIZE) then
            _log("info", "Limite cache audio atteinte - Considérer augmenter MAX_CACHE_SIZE")
        end

        -- Chargement avec protection d'erreur
        local success, result = pcall(love.audio.newSource, path, audioType)
        if success then
            _sources[key] = result
            _stats.audio.count = _stats.audio.count + 1
            _stats.audio.misses = _stats.audio.misses + 1

            if CACHE_CONFIG.LOG_HIT_MISS then
                _log("info", string.format("MISS: Audio chargé '%s' type=%s (total: %d)",
                    path, audioType, _stats.audio.count))
            end
        else
            _log("error", string.format("Échec chargement audio '%s' type=%s: %s",
                path, audioType, result))
            return nil
        end
    else
        _stats.audio.hits = _stats.audio.hits + 1
        _stats.total_memory_saves = _stats.total_memory_saves + 1

        if CACHE_CONFIG.LOG_HIT_MISS then
            _log("info", string.format("HIT: Audio en cache '%s' type=%s", path, audioType))
        end
    end

    -- Retourner un clone pour éviter les conflits de lecture simultanée
    local success, clone = pcall(function() return _sources[key]:clone() end)
    if success then
        return clone
    else
        _log("error", string.format("Échec clonage audio '%s': %s", key, clone))
        return nil
    end
end

-- ===== FONCTIONS DE MONITORING ET GESTION MÉMOIRE =====

--[[*
    Retourne les statistiques détaillées du cache.
    @return Table avec les métriques de performance.
--]]
function res.getStats()
    local totalItems = _stats.images.count + _stats.fonts.count + _stats.audio.count
    local totalHits = _stats.images.hits + _stats.fonts.hits + _stats.audio.hits
    local totalMisses = _stats.images.misses + _stats.fonts.misses + _stats.audio.misses
    local totalRequests = totalHits + totalMisses

    return {
        images = {
            count = _stats.images.count,
            hits = _stats.images.hits,
            misses = _stats.images.misses,
            hit_rate = totalRequests > 0 and (_stats.images.hits / (totalRequests)) * 100 or 0
        },
        fonts = {
            count = _stats.fonts.count,
            hits = _stats.fonts.hits,
            misses = _stats.fonts.misses,
            hit_rate = totalRequests > 0 and (_stats.fonts.hits / (totalRequests)) * 100 or 0
        },
        audio = {
            count = _stats.audio.count,
            hits = _stats.audio.hits,
            misses = _stats.audio.misses,
            hit_rate = totalRequests > 0 and (_stats.audio.hits / (totalRequests)) * 100 or 0
        },
        global = {
            total_items = totalItems,
            total_hits = totalHits,
            total_misses = totalMisses,
            total_requests = totalRequests,
            global_hit_rate = totalRequests > 0 and (totalHits / totalRequests) * 100 or 0,
            memory_saves = _stats.total_memory_saves,
            last_cleanup = _stats.last_cleanup
        }
    }
end

--[[*
    Affiche un rapport détaillé des performances du cache.
--]]
function res.printStats()
    local stats = res.getStats()

    _log("info", "=== RAPPORT CACHE DE RESSOURCES ===")
    _log("info", string.format("Images: %d éléments, %.1f%% hit rate (%d hits, %d misses)",
        stats.images.count, stats.images.hit_rate, stats.images.hits, stats.images.misses))
    _log("info", string.format("Fonts: %d éléments, %.1f%% hit rate (%d hits, %d misses)",
        stats.fonts.count, stats.fonts.hit_rate, stats.fonts.hits, stats.fonts.misses))
    _log("info", string.format("Audio: %d éléments, %.1f%% hit rate (%d hits, %d misses)",
        stats.audio.count, stats.audio.hit_rate, stats.audio.hits, stats.audio.misses))
    _log("info", string.format("GLOBAL: %d éléments total, %.1f%% hit rate global",
        stats.global.total_items, stats.global.global_hit_rate))
    _log("info", string.format("Économies mémoire: %d accès évités", stats.global.memory_saves))
end

--[[*
    Configure les paramètres du cache.
    @param config Table de configuration.
--]]
function res.configure(config)
    if type(config) ~= "table" then
        _log("error", "res.configure: config doit être une table")
        return false
    end

    for key, value in pairs(config) do
        if CACHE_CONFIG[key] ~= nil then
            CACHE_CONFIG[key] = value
            _log("info", string.format("Configuration mise à jour: %s = %s", key, tostring(value)))
        else
            _log("warn", string.format("Option de configuration inconnue: %s", key))
        end
    end

    return true
end

--[[*
    Nettoie manuellement le cache (libère la mémoire).
    @param force_all Si true, vide tout le cache.
--]]
function res.cleanup(force_all)
    local cleaned = 0

    if force_all then
        -- Nettoyage complet
        _images = {}
        _fonts = {}
        _sources = {}
        cleaned = _stats.images.count + _stats.fonts.count + _stats.audio.count

        -- Reset des compteurs
        _stats.images.count = 0
        _stats.fonts.count = 0
        _stats.audio.count = 0

        _log("info", string.format("Nettoyage complet: %d éléments supprimés", cleaned))
    else
        -- Nettoyage intelligent basé sur l'usage (à implémenter plus tard)
        _log("info", "Nettoyage intelligent non encore implémenté")
    end

    _stats.last_cleanup = love.timer.getTime()
    return cleaned
end

--[[*
    Retourne des informations sur la configuration actuelle.
--]]
function res.getConfig()
    return {
        monitoring_enabled = CACHE_CONFIG.ENABLE_MONITORING,
        cleanup_enabled = CACHE_CONFIG.ENABLE_CLEANUP,
        max_cache_size = CACHE_CONFIG.MAX_CACHE_SIZE,
        cleanup_threshold = CACHE_CONFIG.CLEANUP_THRESHOLD,
        log_hit_miss = CACHE_CONFIG.LOG_HIT_MISS
    }
end

--[[*
    Active ou désactive le monitoring détaillé.
    @param enabled Boolean pour activer/désactiver.
--]]
function res.setMonitoring(enabled)
    CACHE_CONFIG.ENABLE_MONITORING = enabled
    CACHE_CONFIG.LOG_HIT_MISS = enabled
    _log("info", string.format("Monitoring %s", enabled and "activé" or "désactivé"))
end

return res
