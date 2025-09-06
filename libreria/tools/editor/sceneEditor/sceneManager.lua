-- sceneManager.lua
-- Gestionnaire de scènes pour l'éditeur

local sceneManager = {}
local globalFunction = require("libreria.tools.globalFunction")

-- Fonction utilitaire pour vérifier la disponibilité de Love2D
local function isLoveAvailable()
    return type(_G.love) == "table" and type(_G.love.filesystem) == "table"
end

-- Sauvegarde d'une scène
function sceneManager.saveScene(scene)
    if not scene or not scene.name then return false end

    scene.metadata.modified = os.date("%Y-%m-%d %H:%M:%S")

    local filename = "src/scenes/" .. scene.name .. ".json"

    -- Encoder en JSON
    local json = _G.json or require("libreria/tools/json")
    local success, jsonData = pcall(json.encode, scene)

    if not success then
        if globalFunction and globalFunction.log then
            globalFunction.log.error("Erreur encodage JSON: " .. tostring(jsonData))
        end
        return false
    end

    -- Écrire le fichier de manière sécurisée
    if not isLoveAvailable() then
        if globalFunction and globalFunction.log then
            globalFunction.log.error("Erreur écriture fichier: Love2D non disponible")
        end
        return false
    end

    local ok, result = pcall(function() return _G.love.filesystem.write(filename, jsonData) end)
    if not ok or not result then
        if globalFunction and globalFunction.log then
            globalFunction.log.error("Erreur écriture fichier: " .. tostring(result or "Erreur inconnue"))
        end
        return false
    end

    if globalFunction and globalFunction.log then
        globalFunction.log.info("Scène sauvegardée: " .. filename)
    end
    return true
end

-- Chargement d'une scène
function sceneManager.loadScene(name)
    local filename = "src/scenes/" .. name .. ".json"

    -- Lire le fichier de manière sécurisée
    if not isLoveAvailable() then
        if globalFunction and globalFunction.log then
            globalFunction.log.error("Erreur lecture fichier: Love2D non disponible")
        end
        return nil
    end

    local ok, result = pcall(function() return _G.love.filesystem.read(filename) end)
    if not ok then
        if globalFunction and globalFunction.log then
            globalFunction.log.error("Erreur lecture fichier: " .. tostring(result))
        end
        return nil
    end

    local fileData = result
    if not fileData then
        if globalFunction and globalFunction.log then
            globalFunction.log.error("Fichier non trouvé: " .. filename)
        end
        return nil
    end

    -- Décoder le JSON
    local json = _G.json or require("libreria/tools/json")
    local success, sceneData = pcall(json.decode, fileData)

    if not success then
        if globalFunction and globalFunction.log then
            globalFunction.log.error("Erreur décodage JSON: " .. tostring(sceneData))
        end
        return nil
    end

    if globalFunction and globalFunction.log then
        globalFunction.log.info("Scène chargée: " .. filename)
    end
    return sceneData
end

-- Copie d'image vers le dossier de la scène
function sceneManager.copyImageToSceneFolder(imagePath, sceneName)
    if not isLoveAvailable() then return nil end

    local success, hasInfo = pcall(function() return _G.love.filesystem.getInfo(imagePath) end)
    if not (success and hasInfo) then return nil end

    local sceneImageDir = "src/images/" .. sceneName
    pcall(function() _G.love.filesystem.createDirectory(sceneImageDir) end)

    local filename = imagePath:match("([^/\\]+)$")
    local destPath = sceneImageDir .. "/" .. filename

    -- Copier le fichier (simulation avec Love2D filesystem)
    local fileData = nil
    success, fileData = pcall(function() return _G.love.filesystem.newFileData(imagePath) end)
    if success and fileData then
        pcall(function() _G.love.filesystem.write(destPath, fileData) end)
        return destPath
    end

    return nil
end

return sceneManager
