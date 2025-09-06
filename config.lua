-- config.lua
-- Configuration générale de LoveEngine

local config = {
    -- Mode par défaut au lancement
    defaultMode = "dev", -- "dev" ou "game"

    -- Paramètres de développement
    dev = {
        showFPS = true,
        showLogs = true,
        enableProfiling = false,
        debugShortcuts = true
    },

    -- Paramètres de jeu
    game = {
        showFPS = false,
        showLogs = false,
        enableCheats = false,
        autoSave = true
    },

    -- Paramètres globaux
    window = {
        title = "LoveEngine v1.0",
        width = 800,
        height = 600,
        resizable = true,
        vsync = true
    },

    -- Logs
    logs = {
        maxFiles = 10,
        maxEntries = 200,
        dir = "gameLogs",
        immediateWrite = true
    }
}

return config
