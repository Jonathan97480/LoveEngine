-- Configuration centrale réutilisable par tout le projet
-- Placer ici les variables globales (titre, résolution, chemins, logs...)
local config = {
    game = {
        title = "Mon Jeu",
        version = "0.1.0",
        icon = "img/Menu/Titre.png",
    },

    window = {
        width = 800,
        height = 600,
        fullscreen = false,
        vsync = true,
    },

    logs = {
        -- nombre maximal de fichiers de logs à garder dans le dossier `gameLogs`
        maxFiles = 10,
        -- nombre maximal d'entrées conservées en mémoire par le logger
        maxEntries = 200,
        -- dossier d'export des logs (relatif au projet)
        dir = "gameLogs",
    },

    paths = {
        img = "img",
        fonts = "fonts",
        sounds = "sound",
    },
}

return config
