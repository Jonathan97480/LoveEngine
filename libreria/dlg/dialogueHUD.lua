local DialogueHUD = {}

-- Charger configuration
local config = require("libreria.dlg.config")
local globalFunction = require("libreria/tools/globalFunction")
local hud = require("libreria/hud/hud")
local dialogue = require("libreria/dlg/dialogueManager")

local visible = false
local currentEntry = nil
local revealMode = "char" -- or "word"
local revealedText = ""
local totalChars = 0

local function _log(msg, level)
    level = level or "info"
    if config.debug.enableLogging then
        if globalFunction and globalFunction.log and globalFunction.log[level] then
            globalFunction.log[level]("[DialogueHUD] " .. tostring(msg))
        else
            print("[DialogueHUD] " .. tostring(msg))
        end
    end
end

function DialogueHUD.initialize()
    -- Setup HUD elements using _G.hud if available; fallback to noop
    _log("initialize")
    return true
end

function DialogueHUD.show(entry)
    visible = true
    currentEntry = entry
    _log("=== SHOW ENTRY APPELÉ ===")
    _log("show entry: " .. (entry and (entry.character or "nil") or "nil"))

    -- Prepare reveal state
    revealedText = ""
    totalChars = entry and (entry.text and #entry.text or 0) or 0
    revealMode = entry and entry.revealMode or "char"

    -- Cache des mots si mode word et caching activé
    if config.performance.enableWordCaching and revealMode == "word" and entry and entry.text then
        if not entry._cachedWords then
            entry._cachedWords = {}
            for w in string.gmatch(entry.text, "%S+") do
                table.insert(entry._cachedWords, w)
            end
            _log("Words cached for entry", "debug")
        end
    end

    -- Portrait support: entry.portrait should be a path relative to project
    if entry and entry.portrait and hud and hud.addIcon then
        local portraitConfig = config.ui.portrait
        hud.addIcon("dialogue_portrait", {
            layer = portraitConfig.layer,
            x = portraitConfig.x,
            y = portraitConfig.y,
            img = entry.portrait,
            scale = portraitConfig.scale
        })
    end

    -- If hud exists, add panels and elements using config
    if hud and hud.addPanel then
        local panelConfig = config.ui.panel
        hud.addPanel("dialogue_panel", {
            x = panelConfig.x,
            y = panelConfig.y,
            w = panelConfig.w,
            h = panelConfig.h,
            bg = panelConfig.bg,
            children = {}
        })

        -- Afficher le nom du locuteur si disponible
        if entry and entry.character then
            local speakerConfig = config.ui.speaker
            hud.addLabel("dialogue_speaker_name", {
                layer = speakerConfig.layer,
                x = speakerConfig.x,
                y = speakerConfig.y,
                text = entry.character,
                font = speakerConfig.font,
                color = speakerConfig.color
            })
        end

        -- Texte principal
        local textConfig = config.ui.text
        hud.addLabel("dialogue_text", {
            layer = "button",
            x = textConfig.x,
            y = textConfig.y,
            text = "",
            font = textConfig.font,
            color = textConfig.color
        })

        -- Add skip button (calls global dialogue.skip if present)
        _log("Vérification HUD disponible: " .. (hud and "OUI" or "NON"))
        if hud then
            _log("Vérification addButton disponible: " .. (hud.addButton and "OUI" or "NON"))
        end

        if hud and hud.addButton then
            local skipConfig = config.ui.skipButton
            _log("Création du bouton Skip à position x=" .. skipConfig.x .. ", y=" .. skipConfig.y)
            hud.addButton("dialogue_skip_btn", {
                layer = skipConfig.layer,
                x = skipConfig.x,
                y = skipConfig.y,
                w = skipConfig.w,
                h = skipConfig.h,
                text = skipConfig.text,
                callback = function()
                    _log("Bouton Skip cliqué !")
                    if dialogue and dialogue.skip then
                        _log("Appel de dialogue.skip()")
                        pcall(function() dialogue.skip() end)
                    else
                        _log("ERROR: dialogue.skip non disponible")
                    end
                end
            })
            _log("Bouton Skip créé avec succès")
        else
            _log("ERROR: _G.hud.addButton non disponible")
        end
    end
end

function DialogueHUD.update(entry)
    currentEntry = entry
    _log("update entry")
    -- reset reveal when updating to new entry
    revealedText = ""
    totalChars = entry and (entry.text and #entry.text or 0) or 0
    revealMode = entry and entry.revealMode or "char"

    -- Cache des mots si nécessaire
    if config.performance.enableWordCaching and revealMode == "word" and entry and entry.text then
        if not entry._cachedWords then
            entry._cachedWords = {}
            for w in string.gmatch(entry.text, "%S+") do
                table.insert(entry._cachedWords, w)
            end
            _log("Words cached for entry", "debug")
        end
    end

    -- update portrait if provided
    if entry and entry.portrait and hud and hud.addIcon then
        local portraitConfig = config.ui.portrait
        hud.addIcon("dialogue_portrait", {
            layer = portraitConfig.layer,
            x = portraitConfig.x,
            y = portraitConfig.y,
            img = entry.portrait,
            scale = portraitConfig.scale
        })
    end

    -- Mettre à jour le nom du locuteur
    if entry and entry.character and hud and hud.setText then
        hud.setText("dialogue_speaker_name", entry.character)
    end

    if hud and hud.setText then
        hud.setText("dialogue_text", "")
    end
end

function DialogueHUD.setProgress(progress)
    if not currentEntry or not currentEntry.text then
        _log("setProgress appelé mais pas de currentEntry ou texte")
        return
    end
    progress = math.max(0, math.min(1, progress or 0))
    _log("setProgress appelé avec progress: " ..
        tostring(progress) .. " pour texte: '" .. (currentEntry.text or "nil") .. "'")

    if revealMode == "word" then
        -- Utiliser cache des mots si disponible
        local words = currentEntry._cachedWords
        if not words and config.performance.enableWordCaching then
            words = {}
            for w in string.gmatch(currentEntry.text, "%S+") do
                table.insert(words, w)
            end
            currentEntry._cachedWords = words
            _log("Words cached on-demand", "debug")
        elseif not words then
            -- Fallback sans cache
            words = {}
            for w in string.gmatch(currentEntry.text, "%S+") do
                table.insert(words, w)
            end
        end

        local n = math.floor(#words * progress + 0.0001)
        revealedText = table.concat(words, " ", 1, math.max(0, n))
        _log("Mode word: n=" .. n .. ", texte révélé: '" .. (revealedText or "nil") .. "'")
    else
        local n = math.floor(totalChars * progress + 0.0001)
        revealedText = string.sub(currentEntry.text or "", 1, n)
        _log("Mode char: n=" .. n .. ", texte révélé: '" .. (revealedText or "nil") .. "'")
    end

    if hud and hud.setText then
        hud.setText("dialogue_text", revealedText)
        _log("setText appelé avec: '" .. (revealedText or "nil") .. "'")
    else
        _log("ERROR: hud.setText non disponible")
    end
end

function DialogueHUD.hide()
    visible = false
    currentEntry = nil
    _log("hide")
    if hud and hud.setVisible then
        hud.setVisible("dialogue_panel", false)
        hud.setVisible("dialogue_text", false)
        hud.setVisible("dialogue_speaker_name", false) -- Masquer le nom
        if hud.setVisible then
            hud.setVisible("dialogue_skip_btn", false)
            -- hide portrait if exists
            hud.setVisible("dialogue_portrait", false)
        end
    end
end

-- Nouvelles fonctions utilitaires
function DialogueHUD.getConfig()
    return config
end

function DialogueHUD.clearCache()
    -- Nettoyer les caches de mots dans les entrées
    if currentEntry and currentEntry._cachedWords then
        currentEntry._cachedWords = nil
        _log("Word cache cleared for current entry", "debug")
    end
end

function DialogueHUD.isVisible()
    return visible
end

return DialogueHUD
