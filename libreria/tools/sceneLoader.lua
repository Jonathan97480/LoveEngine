-- sceneLoader.lua
-- Chargeur de scènes pour LoveEngine
-- Charge et gère les scènes créées avec l'éditeur de scènes

local sceneLoader = {}

-- Variables locales
local currentScene = nil
local loadedScenes = {}
local sceneImages = {}

-- Charger une scène depuis un fichier JSON
local function loadSceneFromFile(filename)
    local filepath = "src/scenes/" .. filename
    local sceneData = _G.globalFunction.loadFromFile(filepath)

    if sceneData then
        _G.globalFunction.log.info("Scène chargée: " .. filename)

        -- Charger les images de la scène
        loadSceneImages(sceneData.name)

        return sceneData
    else
        _G.globalFunction.log.error("Erreur lors du chargement de la scène: " .. filename)
        return nil
    end
end

-- Charger les images d'une scène
function loadSceneImages(sceneName)
    local imageDir = "src/images/" .. sceneName
    sceneImages[sceneName] = {}

    -- Lister tous les fichiers dans le dossier de la scène
    local files = love.filesystem.getDirectoryItems(imageDir)
    for i, file in ipairs(files) do
        local ext = file:match("%.([^%.]+)$")
        if ext and (ext == "png" or ext == "jpg" or ext == "jpeg") then
            local imagePath = imageDir .. "/" .. file
            local image = love.graphics.newImage(imagePath)
            if image then
                sceneImages[sceneName][file] = image
                _G.globalFunction.log.info("Image chargée: " .. imagePath)
            end
        end
    end
end

-- Obtenir une image d'une scène
local function getSceneImage(sceneName, imageName)
    if sceneImages[sceneName] then
        return sceneImages[sceneName][imageName]
    end
    return nil
end

-- Dessiner un élément de scène
local function drawSceneElement(element, sceneName)
    if not element.visible then return end

    love.graphics.push()

    -- Appliquer les transformations
    love.graphics.translate(element.x, element.y)
    love.graphics.rotate(element.rotation)
    love.graphics.scale(element.scaleX, element.scaleY)

    -- Dessiner selon le type d'élément
    if element.type == "background" then
        if element.properties.image then
            local image = getSceneImage(sceneName, element.properties.image)
            if image then
                if element.properties.stretch then
                    love.graphics.draw(image, 0, 0, 0, element.width / image:getWidth(),
                        element.height / image:getHeight())
                else
                    love.graphics.draw(image, 0, 0)
                end
            else
                -- Fond coloré si pas d'image
                love.graphics.setColor(element.properties.color)
                love.graphics.rectangle("fill", 0, 0, element.width, element.height)
            end
        else
            love.graphics.setColor(element.properties.color)
            love.graphics.rectangle("fill", 0, 0, element.width, element.height)
        end
    elseif element.type == "sprite" then
        if element.properties.image then
            local image = getSceneImage(sceneName, element.properties.image)
            if image then
                love.graphics.setColor(element.properties.color)
                love.graphics.draw(image, 0, 0)
            else
                love.graphics.setColor(element.properties.color)
                love.graphics.rectangle("fill", 0, 0, element.width, element.height)
            end
        else
            love.graphics.setColor(element.properties.color)
            love.graphics.rectangle("fill", 0, 0, element.width, element.height)
        end
    elseif element.type == "text" then
        love.graphics.setColor(element.properties.color)
        love.graphics.setFont(love.graphics.newFont(element.properties.fontSize))
        love.graphics.printf(element.properties.text, 0, 0, element.width, element.properties.align)
    elseif element.type == "button" then
        -- Fond du bouton
        love.graphics.setColor(element.properties.normalColor)
        love.graphics.rectangle("fill", 0, 0, element.width, element.height)

        -- Bordure
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("line", 0, 0, element.width, element.height)

        -- Texte
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf(element.properties.text, 0, element.height / 2 - element.properties.fontSize / 2,
            element.width, "center")
    elseif element.type == "panel" then
        -- Fond du panel
        love.graphics.setColor(element.properties.backgroundColor)
        love.graphics.rectangle("fill", 0, 0, element.width, element.height)

        -- Bordure
        love.graphics.setColor(element.properties.borderColor)
        love.graphics.setLineWidth(element.properties.borderWidth)
        love.graphics.rectangle("line", 0, 0, element.width, element.height)
        love.graphics.setLineWidth(1)
    end

    love.graphics.pop()
end

-- Fonctions publiques
function sceneLoader.loadScene(sceneName)
    if loadedScenes[sceneName] then
        currentScene = loadedScenes[sceneName]
        _G.globalFunction.log.info("Scène déjà chargée: " .. sceneName)
        return currentScene
    end

    local scene = loadSceneFromFile(sceneName .. ".json")
    if scene then
        loadedScenes[sceneName] = scene
        currentScene = scene
        return scene
    end

    return nil
end

function sceneLoader.unloadScene(sceneName)
    if loadedScenes[sceneName] then
        loadedScenes[sceneName] = nil
        sceneImages[sceneName] = nil
        _G.globalFunction.log.info("Scène déchargée: " .. sceneName)

        if currentScene and currentScene.name == sceneName then
            currentScene = nil
        end
    end
end

function sceneLoader.drawScene(sceneName)
    local scene = sceneName and loadedScenes[sceneName] or currentScene
    if not scene then return end

    -- Dessiner les calques dans l'ordre (du fond vers l'avant)
    for i = 1, #scene.layers do
        local layer = scene.layers[i]
        if layer.visible then
            for j, element in ipairs(layer.elements) do
                drawSceneElement(element, scene.name)
            end
        end
    end
end

function sceneLoader.updateScene(sceneName, dt)
    local scene = sceneName and loadedScenes[sceneName] or currentScene
    if not scene then return end

    -- Mise à jour des éléments interactifs (boutons, etc.)
    for i, layer in ipairs(scene.layers) do
        if layer.visible then
            for j, element in ipairs(layer.elements) do
                if element.type == "button" and element.properties.callback then
                    -- Gestion des interactions boutons
                    local mouseX, mouseY = love.mouse.getPosition()
                    if mouseX >= element.x and mouseX <= element.x + element.width and
                        mouseY >= element.y and mouseY <= element.y + element.height then
                        if love.mouse.isDown(1) then
                            element.properties.currentState = "pressed"
                        else
                            element.properties.currentState = "hover"
                        end
                    else
                        element.properties.currentState = "normal"
                    end
                end
            end
        end
    end
end

function sceneLoader.getCurrentScene()
    return currentScene
end

function sceneLoader.setCurrentScene(scene)
    currentScene = scene
end

function sceneLoader.getLoadedScenes()
    return loadedScenes
end

function sceneLoader.getSceneElement(sceneName, layerIndex, elementIndex)
    local scene = loadedScenes[sceneName]
    if scene and scene.layers[layerIndex] then
        return scene.layers[layerIndex].elements[elementIndex]
    end
    return nil
end

function sceneLoader.getSceneSize(sceneName)
    local scene = loadedScenes[sceneName] or currentScene
    if scene then
        return scene.width, scene.height
    end
    return 800, 600 -- Taille par défaut
end

-- Gestion des événements pour les éléments interactifs
function sceneLoader.mousepressed(x, y, button, istouch, presses)
    if not currentScene then return end

    for i = #currentScene.layers, 1, -1 do -- Du calque supérieur vers le bas
        local layer = currentScene.layers[i]
        if layer.visible then
            for j, element in ipairs(layer.elements) do
                if element.type == "button" and element.properties.callback then
                    if x >= element.x and x <= element.x + element.width and
                        y >= element.y and y <= element.y + element.height then
                        element.properties.callback()
                        return true -- Événement traité
                    end
                end
            end
        end
    end

    return false
end

return sceneLoader
