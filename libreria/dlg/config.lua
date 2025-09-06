-- Configuration centralisée pour le DialogueManager
local config = {
    ui = {
        panel = {
            x = 610, -- Centré: (1920 - 700) / 2 = 610
            y = 850, -- Plus en bas, laisse 90px du bas de l'écran (1080 - 140 - 90 = 850)
            w = 700,
            h = 140,
            bg = { 0, 0, 0, 0.8 }
        },
        text = {
            x = 620, -- Ajusté relativement au panel (610 + 10)
            y = 890, -- Ajusté relativement au panel (850 + 40)
            font = 18,
            color = { 1, 1, 1 }
        },
        portrait = {
            x = 620, -- Ajusté relativement au panel (610 + 10)
            y = 860, -- Ajusté relativement au panel (850 + 10)
            scale = 1.0,
            layer = "props"
        },
        speaker = {
            x = 630,               -- Ajusté relativement au panel (610 + 20)
            y = 855,               -- Ajusté relativement au panel (850 + 5)
            font = 16,
            color = { 1, 1, 0.7 }, -- Couleur dorée
            layer = "button"
        },
        skipButton = {
            x = 1230, -- Position droite (610 + 700 - 80)
            y = 800,  -- Au-dessus de la boîte (850 - 50)
            w = 80,
            h = 36,
            text = "Skip",
            layer = "button"
        }
    },
    timing = {
        baseMs = 200,        -- base overhead per line in milliseconds
        charMs = 40,         -- ms per character
        punctuationMs = 300, -- extra ms for .,!? etc
        minMs = 600,
        maxMs = 15000
    },
    audio = {
        cacheSize = 10, -- Nombre max de fichiers en cache
        fadeInMs = 200,
        fadeOutMs = 300
    },
    performance = {
        enableWordCaching = true,  -- Cache des mots pour révélation
        enableAudioCaching = true, -- Cache des sources audio
        maxCachedDialogues = 5     -- Nombre max de dialogues en cache
    },
    debug = {
        enableLogging = true,
        enableDebugPanel = false, -- Activé via _G.GameFlags.dialogue_debug
        logLevel = "info"         -- "debug", "info", "warn", "error"
    }
}

return config
