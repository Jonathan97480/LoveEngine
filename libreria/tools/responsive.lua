local screenManager = {};

screenManager.gameReso = {
    width = 1920,
    height = 1080
};
screenManager.ratioScreen = {
    height = 1,
    width = 1
};
local curentDimensions = {
    width = 1280,
    height = 720
};

-- Variables de zoom
screenManager.zoom = {
    level = 1.0, -- Niveau de zoom actuel
    min = 0.1,   -- Zoom minimum (10%)
    max = 5.0,   -- Zoom maximum (500%)
    step = 0.1   -- Incrément de zoom par molette
};

screenManager.getRatio = function()
    return screenManager.ratioScreen.width, screenManager.ratioScreen.height
end

screenManager.getZoom = function()
    return screenManager.zoom.level
end

screenManager.setZoom = function(newZoom)
    screenManager.zoom.level = math.max(screenManager.zoom.min, math.min(screenManager.zoom.max, newZoom))
end

screenManager.zoomIn = function()
    screenManager.setZoom(screenManager.zoom.level + screenManager.zoom.step)
end

screenManager.zoomOut = function()
    screenManager.setZoom(screenManager.zoom.level - screenManager.zoom.step)
end

screenManager.resetZoom = function()
    screenManager.zoom.level = 1.0
end

screenManager.Syncro = true;
screenManager.FullScreen = false;
screenManager.resizable = true;
screenManager.getWindow = {};
local isHover = false;

-- Initialisation différée de la fenêtre (appelée depuis love.load)
function screenManager.initWindow()
    if love and love.window and love.window.setMode then
        love.window.setMode(1920, 1080, {
            fullscreen = screenManager.FullScreen,
            resizable = screenManager.resizable,
            vsync = screenManager.Syncro,
            minwidth = 1280,
            minheight = 720
        });
    end
end

--[[ MOUSE SCALE POSITION ]]
local function _getRawMouse()
    if love and love.mouse and love.mouse.getPosition then
        local x, y = love.mouse.getPosition()
        if x and y then return x, y end
    end
    return 0, 0
end

-- Initialisation différée de la souris
function screenManager.initMouse()
    local x, y = _getRawMouse()
    screenManager.mouse = {};
    -- guard against zero ratios
    local __rw = screenManager.ratioScreen.width or 1
    local __rh = screenManager.ratioScreen.height or 1
    if __rw == 0 then __rw = 1 end
    if __rh == 0 then __rh = 1 end
    -- Appliquer le zoom aux coordonnées souris
    local zoom = screenManager.zoom.level
    screenManager.mouse.X = (x / __rw) / zoom;
    screenManager.mouse.Y = (y / __rh) / zoom;
end

--[[
Fonction : screenManager.UpdateRatio
Rôle : Fonction « Update ratio » liée à la logique du jeu.
Paramètres :
  - dt : paramètre détecté automatiquement.
Retour : aucune valeur (nil).
]]
function screenManager.UpdateRatio(dt)
    if love and love.graphics and love.graphics.getDimensions then
        curentDimensions.width, curentDimensions.height = love.graphics.getDimensions();
        screenManager.ratioScreen.height = curentDimensions.height / screenManager.gameReso.height;
        screenManager.ratioScreen.width = curentDimensions.width / screenManager.gameReso.width;
        -- guard against zero ratios (defensive)
        if screenManager.ratioScreen.width == 0 then screenManager.ratioScreen.width = 1 end
        if screenManager.ratioScreen.height == 0 then screenManager.ratioScreen.height = 1 end
        screenManager.getWindow = curentDimensions;
    end

    x, y = _getRawMouse();
    local __rw2 = screenManager.ratioScreen.width or 1
    local __rh2 = screenManager.ratioScreen.height or 1
    -- Initialiser screenManager.mouse si nécessaire
    if not screenManager.mouse then
        screenManager.mouse = {}
    end
    -- Appliquer le zoom aux coordonnées souris
    local zoom = screenManager.zoom.level
    screenManager.mouse.X = (x / __rw2) / zoom;
    screenManager.mouse.Y = (y / __rh2) / zoom;
end

return screenManager;
