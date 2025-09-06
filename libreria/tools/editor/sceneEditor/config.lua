-- config.lua
-- Configuration de l'éditeur de scènes

local config = {}

-- Configuration de l'éditeur
config.EDITOR_CONFIG = {
    PANEL_WIDTH = 300,
    TOOLBAR_HEIGHT = 40,
    ELEMENT_SIZE = 32,
    SNAP_GRID = 16,
    ZOOM_LEVELS = { 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0 },
    DEFAULT_SCENE_SIZE = { width = 800, height = 600 }
}

-- États de l'éditeur
config.editorState = {
    zoom = 1.0,
    panX = 0,
    panY = 0,
    gridVisible = true,
    snapToGrid = true,
    currentTool = "select" -- select, move, resize, add
}

-- Types d'éléments disponibles
config.ELEMENT_TYPES = {
    BACKGROUND = "background",
    SPRITE = "sprite",
    TEXT = "text",
    BUTTON = "button",
    PANEL = "panel"
}

return config
