-- fileDialog.lua
-- Utilitaires pour les dialogues de fichiers

local fileDialog = {}

-- Ouvrir l'explorateur Windows pour sélectionner une image
function fileDialog.openImageDialog()
    -- Pour Windows, on utilise PowerShell pour ouvrir l'explorateur
    local command =
    'powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.Filter = \'Images (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg\'; $f.ShowDialog() | Out-Null; $f.FileName"'

    -- Cette fonction retourne le chemin du fichier sélectionné
    -- Note: Cette implémentation est simplifiée et pourrait nécessiter des ajustements
    -- selon l'environnement Love2D

    _G.globalFunction.log.info("Ouverture du dialogue de sélection d'image")
    return nil -- Placeholder pour l'instant
end

-- Copier un fichier vers le dossier de la scène
function fileDialog.copyImageToScene(sourcePath, sceneName)
    if not sourcePath or not sceneName then return nil end

    local sceneDir = "src/images/" .. sceneName
    love.filesystem.createDirectory(sceneDir)

    local filename = sourcePath:match("([^/\\]+)$")
    local destPath = sceneDir .. "/" .. filename

    -- Copier le fichier
    local success = love.filesystem.write(destPath, love.filesystem.read(sourcePath))

    if success then
        _G.globalFunction.log.info("Image copiée: " .. destPath)
        return filename
    else
        _G.globalFunction.log.error("Erreur lors de la copie de l'image")
        return nil
    end
end

-- Lister les images d'une scène
function fileDialog.listSceneImages(sceneName)
    local sceneDir = "src/images/" .. sceneName
    local images = {}

    local files = love.filesystem.getDirectoryItems(sceneDir)
    for i, file in ipairs(files) do
        local ext = file:match("%.([^%.]+)$")
        if ext and (ext == "png" or ext == "jpg" or ext == "jpeg") then
            table.insert(images, file)
        end
    end

    return images
end

return fileDialog
