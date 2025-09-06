-- test_zoom.lua
-- Script de test pour vérifier le système de zoom

local testZoom = {}

function testZoom.run()
    print("=== Test du système de zoom ===")

    -- Test de chargement du screenManager
    if not _G.screenManager then
        print("ERREUR: screenManager non chargé")
        return false
    end

    -- Test des fonctions de zoom
    local initialZoom = _G.screenManager.getZoom()
    print("Zoom initial: " .. string.format("%.1f%%", initialZoom * 100))

    -- Test zoom avant
    _G.screenManager.zoomIn()
    local zoomAfterIn = _G.screenManager.getZoom()
    print("Après zoom avant: " .. string.format("%.1f%%", zoomAfterIn * 100))

    -- Test zoom arrière
    _G.screenManager.zoomOut()
    local zoomAfterOut = _G.screenManager.getZoom()
    print("Après zoom arrière: " .. string.format("%.1f%%", zoomAfterOut * 100))

    -- Test reset zoom
    _G.screenManager.resetZoom()
    local zoomAfterReset = _G.screenManager.getZoom()
    print("Après reset: " .. string.format("%.1f%%", zoomAfterReset * 100))

    -- Test limites
    _G.screenManager.setZoom(0.05) -- En dessous du minimum
    local zoomMin = _G.screenManager.getZoom()
    print("Test limite min: " .. string.format("%.1f%%", zoomMin * 100))

    _G.screenManager.setZoom(6.0) -- Au-dessus du maximum
    local zoomMax = _G.screenManager.getZoom()
    print("Test limite max: " .. string.format("%.1f%%", zoomMax * 100))

    -- Reset final
    _G.screenManager.resetZoom()

    print("=== Test terminé ===")
    return true
end

return testZoom
