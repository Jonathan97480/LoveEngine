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

screenManager.getRatio = function()
    return screenManager.ratioScreen.width, screenManager.ratioScreen.height
end

screenManager.Syncro = true;
screenManager.FullScreen = false;
screenManager.resizable = true;
screenManager.getWindow = {};
local isHover = false;


love.window.setMode(1280, 720, {
    fullscreen = screenManager.FullScreen,
    resizable = screenManager.resizable,
    vsync = screenManager.Syncro,
    minwidth = 1280,
    minheight = 720
});
--[[ MOUSE SCALE POSITION ]]
local function _getRawMouse()
    local x, y = love.mouse.getPosition()
    if x and y then return x, y end
    return 0, 0
end

local x, y = _getRawMouse()
screenManager.mouse = {};
-- guard against zero ratios
local __rw = screenManager.ratioScreen.width or 1
local __rh = screenManager.ratioScreen.height or 1
if __rw == 0 then __rw = 1 end
if __rh == 0 then __rh = 1 end
screenManager.mouse.X = x / __rw;
screenManager.mouse.Y = y / __rh;
--[[
Fonction : screenManager.UpdateRatio
Rôle : Fonction « Update ratio » liée à la logique du jeu.
Paramètres :
  - dt : paramètre détecté automatiquement.
Retour : aucune valeur (nil).
]]
function screenManager.UpdateRatio(dt)
    curentDimensions.width, curentDimensions.height = love.graphics.getDimensions();
    screenManager.ratioScreen.height = curentDimensions.height / screenManager.gameReso.height;
    screenManager.ratioScreen.width = curentDimensions.width / screenManager.gameReso.width;
    -- guard against zero ratios (defensive)
    if screenManager.ratioScreen.width == 0 then screenManager.ratioScreen.width = 1 end
    if screenManager.ratioScreen.height == 0 then screenManager.ratioScreen.height = 1 end
    screenManager.getWindow = curentDimensions;

    x, y = _getRawMouse();
    local __rw2 = screenManager.ratioScreen.width or 1
    local __rh2 = screenManager.ratioScreen.height or 1
    screenManager.mouse.X = x / __rw2;
    screenManager.mouse.Y = y / __rh2;
end

return screenManager;
