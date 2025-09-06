local DialogueManager = {}

-- Charger configuration
local config = require("libreria.dlg.config")

-- Simple stateful dialogue manager
local active = false
local dialogues = {}
local current = { list = nil, index = 0 }
local hud = nil

-- Cache des sources audio pour optimisation
local audioCache = {}
local audioCacheSize = 0

-- Système d'événements
local eventCallbacks = {}

local function _log(msg, level)
    level = level or "info"
    if config.debug.enableLogging then
        if _G.globalFunction and _G.globalFunction.log and _G.globalFunction.log[level] then
            _G.globalFunction.log[level]("[DialogueManager] " .. tostring(msg))
        else
            print("[DialogueManager] " .. tostring(msg))
        end
    end
end

-- Système d'événements
function DialogueManager.addEventListener(event, callback)
    if not eventCallbacks[event] then eventCallbacks[event] = {} end
    table.insert(eventCallbacks[event], callback)
end

function DialogueManager.removeEventListener(event, callback)
    if eventCallbacks[event] then
        for i, cb in ipairs(eventCallbacks[event]) do
            if cb == callback then
                table.remove(eventCallbacks[event], i)
                break
            end
        end
    end
end

local function fireEvent(event, data)
    if eventCallbacks[event] then
        for _, callback in ipairs(eventCallbacks[event]) do
            pcall(callback, data)
        end
    end
end

-- Validation des données
local function validateDialogueEntry(entry, index)
    if type(entry) ~= "table" then
        return false, "Entry at index " .. index .. " must be a table"
    end
    if not entry.text or type(entry.text) ~= "string" then
        return false, "Entry at index " .. index .. " must have a text field (string)"
    end
    if entry.duration and type(entry.duration) ~= "number" then
        return false, "Entry at index " .. index .. ": duration must be a number"
    end
    if entry.portrait and type(entry.portrait) ~= "string" then
        return false, "Entry at index " .. index .. ": portrait must be a string path"
    end
    if entry.audio and type(entry.audio) ~= "string" then
        return false, "Entry at index " .. index .. ": audio must be a string path"
    end
    return true, nil
end

-- Estimation params (utilise config maintenant)
local defaultParams = config.timing

-- Runtime timing state
local elapsed = 0
local currentDuration = 0
local currentSource = nil      -- love.audio.Source when available
local postRevealPause = 0      -- Pause après révélation complète
local PAUSE_AFTER_REVEAL = 2.0 -- 2 secondes de pause après révélation

local function estimateDurationForText(text, params)
    params = params or defaultParams
    local chars = 0
    if type(text) == "string" then
        chars = #text
    end
    local ms = params.baseMs + chars * params.charMs
    -- punctuation bonus
    local punct = 0
    for p in string.gmatch(text or "", "[%.%!%?]") do
        punct = punct + 1
    end
    ms = ms + punct * params.punctuationMs
    if ms < params.minMs then ms = params.minMs end
    if ms > params.maxMs then ms = params.maxMs end
    return ms / 1000 -- seconds
end

-- Safe audio helpers avec cache (work only if running under LÖVE)
local function tryLoadAudio(path)
    if not path or not config.performance.enableAudioCaching then return nil end

    -- Vérifier le cache d'abord
    if audioCache[path] then
        _log("Audio cache hit: " .. path, "debug")
        return audioCache[path]
    end

    if type(love) ~= "table" or type(love.audio) ~= "table" then return nil end
    local ok, src = pcall(love.audio.newSource, path, "static")
    if ok and src then
        -- Gérer la taille du cache
        if audioCacheSize >= config.audio.cacheSize then
            -- Supprimer le plus ancien (simple FIFO)
            local oldestPath = next(audioCache)
            if oldestPath then
                audioCache[oldestPath] = nil
                audioCacheSize = audioCacheSize - 1
                _log("Audio cache evicted: " .. oldestPath, "debug")
            end
        end

        audioCache[path] = src
        audioCacheSize = audioCacheSize + 1
        _log("Audio cached: " .. path, "debug")
        return src
    end
    return nil
end

local function clearAudioCache()
    audioCache = {}
    audioCacheSize = 0
    _log("Audio cache cleared", "debug")
end

local function playSource(src)
    if not src then return false end
    if type(src.play) == "function" then pcall(function() src:play() end) end
    return true
end

local function stopSource(src)
    if not src then return false end
    if type(src.stop) == "function" then pcall(function() src:stop() end) end
    return true
end

function DialogueManager.initialize(opts)
    -- opts optional: hud module override
    -- Try to load local HUD module safely (avoid using _G._safeRequire which may be unavailable)
    if opts and opts.hud then
        hud = opts.hud
    else
        local ok, mod = pcall(require, "libreria/dlg/dialogueHUD")
        hud = ok and mod or nil
    end
    if type(hud) == "table" and hud.initialize then
        hud.initialize()
    end
    _log("initialized")
    return true
end

function DialogueManager.start(dialogueTable)
    if not dialogueTable or type(dialogueTable) ~= "table" then
        _log("start() called with invalid dialogueTable", "error")
        return false
    end

    -- Validation préalable de toutes les entrées
    for i, entry in ipairs(dialogueTable) do
        local valid, error = validateDialogueEntry(entry, i)
        if not valid then
            _log("Validation failed: " .. error, "error")
            return false
        end
    end

    dialogues = dialogueTable
    current.list = dialogues
    current.index = 1
    active = true
    elapsed = 0

    -- Déclencher événement
    fireEvent("dialogue_started", { dialogue = dialogueTable })

    -- compute duration for first entry
    local entry = current.list[current.index]
    if entry then
        -- prefer explicit duration, then audio file duration (if available), then estimate
        if entry.duration then
            currentDuration = entry.duration
        else
            -- try to load audio if provided
            currentSource = nil
            if entry.audio then
                currentSource = tryLoadAudio(entry.audio)
            end
            if currentSource then
                -- try to get real duration
                local ok, dur = pcall(function() return currentSource:getDuration() end)
                if ok and type(dur) == "number" and dur > 0 then
                    currentDuration = dur
                elseif entry.audioDuration then
                    currentDuration = entry.audioDuration
                else
                    currentDuration = estimateDurationForText(entry.text)
                end
                -- autostart audio unless explicitly disabled
                if entry.playAudio ~= false then playSource(currentSource) end
            else
                if entry.audioDuration then
                    currentDuration = entry.audioDuration
                else
                    currentDuration = estimateDurationForText(entry.text)
                end
            end
        end
    else
        currentDuration = 1.0
    end
    if hud and hud.show then hud.show(current.list[current.index]) end
    _log("started dialogue with " .. tostring(#dialogueTable) .. " entries")
    return true
end

function DialogueManager.next()
    if not active then return false end
    current.index = current.index + 1
    if current.index > #current.list then
        DialogueManager.close()
        return false
    end
    -- reset timing for new entry
    elapsed = 0
    postRevealPause = 0 -- Réinitialiser la pause pour la nouvelle entrée
    local entry = current.list[current.index]
    if entry then
        -- stop previous source if any
        if currentSource then
            stopSource(currentSource)
            currentSource = nil
        end
        if entry.duration then
            currentDuration = entry.duration
        else
            currentSource = nil
            if entry.audio then
                currentSource = tryLoadAudio(entry.audio)
            end
            if currentSource then
                local ok, dur = pcall(function() return currentSource:getDuration() end)
                if ok and type(dur) == "number" and dur > 0 then
                    currentDuration = dur
                elseif entry.audioDuration then
                    currentDuration = entry.audioDuration
                else
                    currentDuration = estimateDurationForText(entry.text)
                end
                if entry.playAudio ~= false then playSource(currentSource) end
            else
                if entry.audioDuration then
                    currentDuration = entry.audioDuration
                else
                    currentDuration = estimateDurationForText(entry.text)
                end
            end
        end
    else
        currentDuration = 1.0
    end
    if hud and hud.update then hud.update(current.list[current.index]) end
    return true
end

function DialogueManager.skip()
    if not active then return false end
    -- reveal current fully and close
    if hud and hud.setProgress then hud.setProgress(1.0) end
    if currentSource then
        stopSource(currentSource)
        currentSource = nil
    end
    DialogueManager.close()
    return true
end

-- update should be called from a scene (or integrated into main update)
function DialogueManager.update(dt)
    if not active then return end
    -- input: allow skip via keyboard (Escape / Return / Space)
    local function _checkSkipInput()
        -- Prefer project's inputManager if available
        if _G and _G.inputManager then
            -- try common method names safely
            local ok, res = pcall(function()
                if _G.inputManager.isKeyPressed then
                    return _G.inputManager.isKeyPressed("escape") or _G.inputManager.isKeyPressed("return") or
                        _G.inputManager.isKeyPressed("space")
                elseif _G.inputManager.isPressed then
                    return _G.inputManager.isPressed("escape") or _G.inputManager.isPressed("return") or
                        _G.inputManager.isPressed("space")
                end
                return false
            end)
            if ok and res then return true end
        end
        -- Fallback to love.keyboard if running under LÖVE
        if type(love) == "table" and love.keyboard and type(love.keyboard.isDown) == "function" then
            if love.keyboard.isDown("escape") or love.keyboard.isDown("return") or love.keyboard.isDown("space") then
                return true
            end
        end
        return false
    end

    if _checkSkipInput() then
        pcall(function() DialogueManager.skip() end)
        return
    end

    -- prefer audio source timing when available
    local progress = 0
    if currentSource and type(currentSource.getTime) == "function" and type(currentSource.getDuration) == "function" then
        local ok, t = pcall(function() return currentSource:getTime() end)
        local ok2, dur = pcall(function() return currentSource:getDuration() end)
        if ok and ok2 and type(t) == "number" and type(dur) == "number" and dur > 0 then
            progress = math.min(1, t / dur)
        else
            elapsed = elapsed + (dt or 0)
            if currentDuration and currentDuration > 0 then
                progress = math.min(1, elapsed / currentDuration)
            else
                progress = 1
            end
        end
    else
        elapsed = elapsed + (dt or 0)
        if currentDuration and currentDuration > 0 then
            progress = math.min(1, elapsed / currentDuration)
        else
            progress = 1
        end
    end
    if hud and hud.setProgress then hud.setProgress(progress) end
    if progress >= 1 then
        -- ensure audio stopped
        if currentSource then
            -- if audio still playing, stop it
            if type(currentSource.isPlaying) == "function" then
                local ok, playing = pcall(function() return currentSource:isPlaying() end)
                if ok and playing then pcall(function() currentSource:stop() end) end
            else
                pcall(function() currentSource:stop() end)
            end
            currentSource = nil
        end

        -- Ajouter une pause après révélation complète
        if postRevealPause <= 0 then
            postRevealPause = PAUSE_AFTER_REVEAL
            _log("Texte révélé complètement, pause de " .. PAUSE_AFTER_REVEAL .. "s avant le suivant")
        else
            postRevealPause = postRevealPause - (dt or 0)
            if postRevealPause <= 0 then
                -- auto advance to next entry after pause
                postRevealPause = 0
                DialogueManager.next()
            end
        end
    end
end

function DialogueManager.close()
    if hud and hud.hide then hud.hide() end

    -- Arrêter l'audio en cours
    if currentSource then
        stopSource(currentSource)
        currentSource = nil
    end

    -- Déclencher événement avant de nettoyer l'état
    local closedDialogue = current.list
    fireEvent("dialogue_closed", { dialogue = closedDialogue })

    active = false
    current.list = nil
    current.index = 0
    _log("closed dialogue")
    return true
end

-- Nouvelles fonctions utilitaires
function DialogueManager.clearCache()
    if config.performance.enableAudioCaching then
        clearAudioCache()
    end
end

function DialogueManager.getConfig()
    return config
end

function DialogueManager.setDebugMode(enabled)
    config.debug.enableDebugPanel = enabled
    if enabled then
        _log("Debug mode enabled", "debug")
    end
end

function DialogueManager.isActive()
    return active
end

-- Small helper to get current entry
function DialogueManager.getCurrent()
    if not active or not current.list then return nil end
    return current.list[current.index]
end

return DialogueManager
