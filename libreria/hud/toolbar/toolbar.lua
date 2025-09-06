--- Module Toolbar pour LÖVE2D
-- Gestion des barres d'outils avec boutons intégrés

local toolbar = {}

-- Configuration par défaut
toolbar.config = {
    height = 40,
    buttonWidth = 60,
    buttonHeight = 30,
    buttonSpacing = 10,
    backgroundColor = { 0.3, 0.3, 0.3, 1 },
    buttonColor = { 0.5, 0.5, 0.5, 1 },
    textColor = { 1, 1, 1, 1 },
    buttonPadding = {
        left = 10,
        right = 10,
        top = 5,
        bottom = 5
    }
}

--- Crée une nouvelle instance de toolbar
-- @param x number : Position X
-- @param y number : Position Y
-- @param width number : Largeur de la toolbar
-- @return table : Instance de toolbar
function toolbar.new(x, y, width)
    local instance = {
        x = x or 0,
        y = y or 0,
        width = width or love.graphics.getWidth(),
        buttons = {},
        title = "",
        config = toolbar.config
    }

    --- Ajoute un bouton à la toolbar
    -- @param text string : Texte du bouton
    -- @param callback function : Fonction appelée au clic
    -- @param x number : Position X relative (optionnel)
    function instance:addButton(text, callback, x)
        -- Calculer la taille du texte avec la fonte actuelle
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()

        -- Calculer la taille du bouton avec padding
        local padding = self.config.buttonPadding
        local buttonWidth = textWidth + padding.left + padding.right
        local buttonHeight = textHeight + padding.top + padding.bottom

        -- Calculer la position X : utiliser la position spécifiée ou calculer automatiquement
        local buttonX
        if x then
            buttonX = x
        else
            -- Positionner après le dernier bouton avec une marge de 4 pixels
            if #self.buttons > 0 then
                local lastButton = self.buttons[#self.buttons]
                buttonX = lastButton.x + lastButton.width + 4
            else
                buttonX = 300 -- Position de départ
            end
        end

        local button = {
            text = text,
            callback = callback,
            x = buttonX,
            y = self.y + 5,
            width = buttonWidth,
            height = buttonHeight,
            hovered = false
        }
        table.insert(self.buttons, button)
        return button
    end

    --- Définit le titre de la toolbar
    -- @param title string : Nouveau titre
    function instance:setTitle(title)
        self.title = title
    end

    --- Met à jour l'état des boutons (hover)
    -- @param mouseX number : Position X de la souris
    -- @param mouseY number : Position Y de la souris
    function instance:update(mouseX, mouseY)
        for _, button in ipairs(self.buttons) do
            button.hovered = mouseX >= button.x and mouseX <= button.x + button.width and
                mouseY >= button.y and mouseY <= button.y + button.height
        end
    end

    --- Gère les clics sur les boutons
    -- @param mouseX number : Position X du clic
    -- @param mouseY number : Position Y du clic
    -- @param button number : Bouton de souris
    -- @return boolean : True si un bouton a été cliqué
    function instance:mousepressed(mouseX, mouseY, button)
        if button ~= 1 then return false end

        for _, btn in ipairs(self.buttons) do
            if mouseX >= btn.x and mouseX <= btn.x + btn.width and
                mouseY >= btn.y and mouseY <= btn.y + btn.height then
                if btn.callback then
                    btn.callback()
                end
                return true
            end
        end
        return false
    end

    --- Dessine la toolbar
    function instance:draw()
        -- Fond de la toolbar
        love.graphics.setColor(self.config.backgroundColor)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.config.height)

        -- Titre
        love.graphics.setColor(self.config.textColor)
        love.graphics.print(self.title, self.x + 10, self.y + 10)

        -- Boutons
        for _, button in ipairs(self.buttons) do
            -- Fond du bouton
            if button.hovered then
                love.graphics.setColor(0.6, 0.6, 0.6, 1)
            else
                love.graphics.setColor(self.config.buttonColor)
            end
            love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

            -- Texte du bouton
            love.graphics.setColor(self.config.textColor)
            local textWidth = love.graphics.getFont():getWidth(button.text)
            local textHeight = love.graphics.getFont():getHeight()

            -- Centrer le texte dans la zone de contenu (sans padding)
            local padding = self.config.buttonPadding
            local contentX = button.x + padding.left
            local contentY = button.y + padding.top
            local contentWidth = button.width - padding.left - padding.right
            local contentHeight = button.height - padding.top - padding.bottom

            local textX = contentX + (contentWidth - textWidth) / 2
            local textY = contentY + (contentHeight - textHeight) / 2
            love.graphics.print(button.text, textX, textY)
        end
    end

    return instance
end

return toolbar
