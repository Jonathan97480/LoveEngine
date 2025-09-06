--- Module PropertiesPanel pour LÖVE2D
-- Gestion des panneaux de propriétés avec champs éditables et contrôles

local propertiesPanel = {}

-- Configuration par défaut
propertiesPanel.config = {
    backgroundColor = { 0.2, 0.2, 0.2, 0.9 },
    textColor = { 1, 1, 1, 1 },
    titleColor = { 1, 1, 1, 1 },
    inputBackgroundColor = { 0.4, 0.4, 0.4, 1 },
    inputBorderColor = { 1, 1, 1, 1 },
    buttonColor = { 0.3, 0.6, 0.3, 1 },
    buttonCancelColor = { 0.6, 0.3, 0.3, 1 },
    checkboxSize = 15,
    sliderHeight = 6,
    padding = 10,
    lineHeight = 25
}

--- Crée un nouveau panneau de propriétés
-- @param x number : Position X
-- @param y number : Position Y
-- @param width number : Largeur
-- @param height number : Hauteur
-- @param title string : Titre du panneau
-- @return table : Instance du panneau
function propertiesPanel.new(x, y, width, height, title)
    local instance = {
        x = x or 0,
        y = y or 0,
        width = width or 300,
        height = height or 400,
        title = title or "Propriétés",
        properties = {},
        config = propertiesPanel.config,
        cursorVisible = true,
        cursorBlinkTimer = 0,
        editingField = nil,
        inputText = ""
    }

    --- Ajoute une propriété texte
    -- @param label string : Label de la propriété
    -- @param value string : Valeur actuelle
    -- @param editable boolean : Si la propriété est éditable
    function instance:addTextProperty(label, value, editable)
        table.insert(self.properties, {
            type = "text",
            label = label,
            value = value or "",
            editable = editable or false
        })
    end

    --- Ajoute une propriété numérique
    -- @param label string : Label de la propriété
    -- @param value number : Valeur actuelle
    -- @param min number : Valeur minimale
    -- @param max number : Valeur maximale
    function instance:addNumberProperty(label, value, min, max)
        table.insert(self.properties, {
            type = "number",
            label = label,
            value = value or 0,
            min = min or -math.huge,
            max = max or math.huge
        })
    end

    --- Ajoute une propriété booléenne (checkbox)
    -- @param label string : Label de la propriété
    -- @param value boolean : Valeur actuelle
    function instance:addBooleanProperty(label, value)
        table.insert(self.properties, {
            type = "boolean",
            label = label,
            value = value or false
        })
    end

    --- Ajoute une propriété couleur
    -- @param label string : Label de la propriété
    -- @param r number : Composante rouge (0-1)
    -- @param g number : Composante verte (0-1)
    -- @param b number : Composante bleue (0-1)
    -- @param a number : Alpha (0-1)
    -- @param callback function : Fonction appelée lors du changement (optionnel)
    function instance:addColorProperty(label, r, g, b, a, callback)
        table.insert(self.properties, {
            type = "color",
            label = label,
            value = { r = r or 0.5, g = g or 0.5, b = b or 0.5, a = a or 1 },
            callback = callback
        })
    end

    --- Ajoute une propriété slider
    -- @param label string : Label de la propriété
    -- @param value number : Valeur actuelle (0-1)
    -- @param callback function : Fonction appelée lors du changement
    function instance:addSliderProperty(label, value, callback)
        table.insert(self.properties, {
            type = "slider",
            label = label,
            value = value or 1.0,
            callback = callback
        })
    end

    --- Ajoute une propriété bouton
    -- @param label string : Label du bouton
    -- @param callback function : Fonction appelée lors du clic
    function instance:addButtonProperty(label, callback)
        table.insert(self.properties, {
            type = "button",
            label = label,
            callback = callback
        })
    end

    --- Met à jour le panneau
    -- @param dt number : Delta time
    function instance:update(dt)
        self.cursorBlinkTimer = self.cursorBlinkTimer + dt
        if self.cursorBlinkTimer >= 0.5 then
            self.cursorVisible = not self.cursorVisible
            self.cursorBlinkTimer = 0
        end
    end

    --- Gère les clics souris
    -- @param mouseX number : Position X du clic
    -- @param mouseY number : Position Y du clic
    -- @param button number : Bouton de souris
    function instance:mousepressed(mouseX, mouseY, button)
        if button ~= 1 then return end

        local propY = self.y + 30
        for i, prop in ipairs(self.properties) do
            if prop.type == "text" and prop.editable then
                -- Zone d'édition du texte
                if mouseX >= self.x + 50 and mouseX <= self.x + self.width - 10 and
                    mouseY >= propY - 2 and mouseY <= propY + 18 then
                    self.editingField = i
                    self.inputText = prop.value
                    return true
                end
            elseif prop.type == "boolean" then
                -- Zone de la checkbox
                if mouseX >= self.x + 10 and mouseX <= self.x + 25 and
                    mouseY >= propY - 2 and mouseY <= propY + 13 then
                    prop.value = not prop.value
                    return true
                end
            elseif prop.type == "slider" then
                -- Zone du slider
                if mouseX >= self.x + 90 and mouseX <= self.x + 90 + 80 and
                    mouseY >= propY - 2 and mouseY <= propY + 4 then
                    local relativeX = mouseX - (self.x + 90)
                    prop.value = math.max(0, math.min(1, relativeX / 80))
                    if prop.callback then
                        prop.callback(prop.value)
                    end
                    return true
                end
            elseif prop.type == "color" then
                -- Zone de la couleur (rectangle coloré)
                if mouseX >= self.x + 50 and mouseX <= self.x + 50 + 30 and
                    mouseY >= propY - 2 and mouseY <= propY + 18 then
                    -- Pour l'instant, cycle à travers quelques couleurs prédéfinies
                    local colors = {
                        { r = 1,   g = 0,   b = 0,   a = 1 }, -- Rouge
                        { r = 0,   g = 1,   b = 0,   a = 1 }, -- Vert
                        { r = 0,   g = 0,   b = 1,   a = 1 }, -- Bleu
                        { r = 1,   g = 1,   b = 0,   a = 1 }, -- Jaune
                        { r = 1,   g = 0,   b = 1,   a = 1 }, -- Magenta
                        { r = 0,   g = 1,   b = 1,   a = 1 }, -- Cyan
                        { r = 0.5, g = 0.5, b = 0.5, a = 1 }, -- Gris
                        { r = 1,   g = 1,   b = 1,   a = 1 }  -- Blanc
                    }
                    -- Trouver la couleur actuelle et passer à la suivante
                    local currentIndex = 1
                    for i, color in ipairs(colors) do
                        if math.abs(prop.value.r - color.r) < 0.1 and
                            math.abs(prop.value.g - color.g) < 0.1 and
                            math.abs(prop.value.b - color.b) < 0.1 then
                            currentIndex = i
                            break
                        end
                    end
                    local nextIndex = (currentIndex % #colors) + 1
                    prop.value = colors[nextIndex]
                    if prop.callback then
                        prop.callback(prop.value.r, prop.value.g, prop.value.b, prop.value.a)
                    end
                    return true
                end
            elseif prop.type == "button" then
                -- Zone du bouton
                if mouseX >= self.x + 50 and mouseX <= self.x + self.width - 10 and
                    mouseY >= propY - 2 and mouseY <= propY + 18 then
                    if prop.callback then
                        prop.callback()
                    end
                    return true
                end
            end
            propY = propY + self.config.lineHeight
        end
        return false
    end

    --- Gère la saisie de texte
    -- @param text string : Texte saisi
    function instance:textinput(text)
        if self.editingField then
            self.inputText = self.inputText .. text
        end
    end

    --- Gère les touches spéciales
    -- @param key string : Touche pressée
    function instance:keypressed(key)
        if self.editingField then
            if key == "return" then
                self.properties[self.editingField].value = self.inputText
                self.editingField = nil
            elseif key == "escape" then
                self.editingField = nil
            elseif key == "backspace" then
                self.inputText = self.inputText:sub(1, -2)
            end
        end
    end

    --- Dessine le panneau
    function instance:draw()
        -- Fond du panneau
        love.graphics.setColor(self.config.backgroundColor)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

        -- Titre
        love.graphics.setColor(self.config.titleColor)
        love.graphics.print(self.title, self.x + self.config.padding, self.y + self.config.padding)

        -- Propriétés
        local propY = self.y + 30
        for i, prop in ipairs(self.properties) do
            love.graphics.setColor(self.config.textColor)

            if prop.type == "text" then
                love.graphics.print(prop.label .. ":", self.x + self.config.padding, propY)

                if self.editingField == i then
                    -- Mode édition
                    love.graphics.setColor(self.config.inputBackgroundColor)
                    love.graphics.rectangle("fill", self.x + 50, propY - 2, self.width - 110, 18)
                    love.graphics.setColor(self.config.inputBorderColor)
                    love.graphics.rectangle("line", self.x + 50, propY - 2, self.width - 110, 18)

                    love.graphics.setColor(self.config.textColor)
                    love.graphics.print(self.inputText, self.x + 55, propY)

                    -- Curseur clignotant
                    if self.cursorVisible then
                        local textWidth = love.graphics.getFont():getWidth(self.inputText)
                        love.graphics.print("|", self.x + 55 + textWidth, propY)
                    end
                else
                    -- Mode affichage
                    if prop.editable then
                        love.graphics.setColor(self.config.inputBackgroundColor)
                        love.graphics.rectangle("fill", self.x + 50, propY - 2, self.width - 60, 18)
                        love.graphics.setColor(self.config.textColor)
                        love.graphics.print(prop.value, self.x + 55, propY)
                    else
                        love.graphics.print(prop.value, self.x + 50, propY)
                    end
                end
            elseif prop.type == "number" then
                love.graphics.print(prop.label .. ":", self.x + self.config.padding, propY)
                love.graphics.print(tostring(prop.value), self.x + 50, propY)
            elseif prop.type == "boolean" then
                love.graphics.print(prop.label .. ":", self.x + self.config.padding, propY)
                love.graphics.setColor(prop.value and { 0.5, 0.8, 0.5, 1 } or { 0.2, 0.2, 0.2, 1 })
                love.graphics.rectangle("fill", self.x + 60, propY - 2, self.config.checkboxSize,
                    self.config.checkboxSize)
                if prop.value then
                    love.graphics.setColor(self.config.textColor)
                    love.graphics.print("✓", self.x + 62, propY - 1)
                end
            elseif prop.type == "color" then
                love.graphics.print(prop.label .. ":", self.x + self.config.padding, propY)
                love.graphics.setColor(prop.value.r, prop.value.g, prop.value.b, prop.value.a)
                love.graphics.rectangle("fill", self.x + 70, propY - 2, 30, 18)
                love.graphics.setColor(self.config.inputBorderColor)
                love.graphics.rectangle("line", self.x + 70, propY - 2, 30, 18)
            elseif prop.type == "slider" then
                love.graphics.setColor(self.config.textColor)
                love.graphics.print(prop.label .. ":", self.x + self.config.padding, propY)
                love.graphics.print(string.format("%.2f", prop.value), self.x + 50, propY)

                -- Slider background
                love.graphics.setColor(0.3, 0.3, 0.3, 1)
                love.graphics.rectangle("fill", self.x + 90, propY - 2, 80, self.config.sliderHeight)

                -- Slider fill
                love.graphics.setColor(0.5, 0.8, 0.5, 1)
                love.graphics.rectangle("fill", self.x + 90, propY - 2, 80 * prop.value, self.config.sliderHeight)

                -- Slider handle
                love.graphics.setColor(self.config.textColor)
                love.graphics.rectangle("line", self.x + 90 + 80 * prop.value - 3, propY - 4, 6, 10)
            elseif prop.type == "button" then
                -- Bouton
                love.graphics.setColor(self.config.buttonColor)
                love.graphics.rectangle("fill", self.x + 50, propY - 2, self.width - 60, 18)
                love.graphics.setColor(self.config.textColor)
                love.graphics.print(prop.label, self.x + 55, propY)
            end

            propY = propY + self.config.lineHeight
        end
    end

    return instance
end

return propertiesPanel
