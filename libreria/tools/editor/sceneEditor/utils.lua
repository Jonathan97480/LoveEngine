-- utils.lua
-- Fonctions utilitaires pour l'éditeur de scènes

local utils = {}
local config = require("libreria.tools.editor.sceneEditor.config")

-- Conversion coordonnées monde/écran
function utils.worldToScreen(x, y)
    return x * config.editorState.zoom + config.editorState.panX,
        y * config.editorState.zoom + config.editorState.panY
end

function utils.screenToWorld(x, y)
    return (x - config.editorState.panX) / config.editorState.zoom,
        (y - config.editorState.panY) / config.editorState.zoom
end

-- Fonction d'accrochage à la grille
function utils.snapToGrid(x, y)
    if not config.editorState.snapToGrid then return x, y end
    local grid = config.EDITOR_CONFIG.SNAP_GRID
    return math.floor(x / grid + 0.5) * grid,
        math.floor(y / grid + 0.5) * grid
end

return utils
