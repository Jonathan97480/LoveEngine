# Module PropertiesPanel

Module pour créer et gérer des panneaux de propriétés avec différents types de contrôles (texte, nombres, booléens, couleurs, sliders) dans LÖVE2D.

## Utilisation

```lua
local propertiesPanel = require("libreria.hud.propertiesPanel.propertiesPanel")

-- Créer un panneau de propriétés
local panel = propertiesPanel.new(500, 50, 300, 400, "Propriétés du calque")

-- Ajouter des propriétés
panel:addTextProperty("Nom", "Calque 1", true)  -- Éditable
panel:addBooleanProperty("Visible", true)
panel:addNumberProperty("Alpha", 1.0, 0, 1)
panel:addColorProperty("Couleur", 0.5, 0.5, 0.5, 1)
panel:addSliderProperty("Transparence", 0.8, function(value)
    print("Nouvelle valeur:", value)
end)

-- Dans love.update
panel:update(dt)

-- Dans love.draw
panel:draw()

-- Dans love.mousepressed
panel:mousepressed(x, y, button)

-- Dans love.textinput
panel:textinput(text)

-- Dans love.keypressed
panel:keypressed(key)
```

## Types de propriétés supportés

### Texte (`addTextProperty`)
- Affichage et édition de texte
- Mode édition avec curseur clignotant
- Validation avec Entrée, annulation avec Échap

### Nombre (`addNumberProperty`)
- Affichage de valeurs numériques
- Support des valeurs min/max (non implémenté dans l'interface pour l'instant)

### Booléen (`addBooleanProperty`)
- Cases à cocher avec indicateur visuel
- Clic pour basculer l'état

### Couleur (`addColorProperty`)
- Aperçu de couleur avec rectangle coloré
- Support RGBA

### Slider (`addSliderProperty`)
- Contrôle glissant pour valeurs 0-1
- Callback automatique lors des changements
- Indicateur visuel de la position

## Fonctions principales

### propertiesPanel.new(x, y, width, height, title)
Crée un nouveau panneau de propriétés.

**Paramètres :**
- `x, y` (number) : Position du panneau
- `width, height` (number) : Dimensions
- `title` (string) : Titre du panneau

### instance:addTextProperty(label, value, editable)
Ajoute une propriété texte.

### instance:addBooleanProperty(label, value)
Ajoute une propriété booléenne (checkbox).

### instance:addNumberProperty(label, value, min, max)
Ajoute une propriété numérique.

### instance:addColorProperty(label, r, g, b, a)
Ajoute une propriété couleur.

### instance:addSliderProperty(label, value, callback)
Ajoute une propriété slider avec callback.

### instance:update(dt)
Met à jour l'état du panneau (curseur clignotant).

### instance:draw()
Dessine le panneau et toutes ses propriétés.

### instance:mousepressed(x, y, button)
Gère les interactions souris.

### instance:textinput(text)
Gère la saisie de texte (en mode édition).

### instance:keypressed(key)
Gère les touches spéciales (Entrée, Échap, etc.).

## Configuration

Le module utilise une configuration par défaut modifiable :

```lua
propertiesPanel.config = {
    backgroundColor = {0.2, 0.2, 0.2, 0.9},
    textColor = {1, 1, 1, 1},
    inputBackgroundColor = {0.4, 0.4, 0.4, 1},
    buttonColor = {0.3, 0.6, 0.3, 1},
    checkboxSize = 15,
    sliderHeight = 6,
    padding = 10,
    lineHeight = 25
}
```

## Intégration avec hud.lua

Ce module est conçu pour être intégré dans le système `hud.lua` principal :

```lua
-- Dans hud.lua
local propertiesPanel = require("libreria.hud.propertiesPanel.propertiesPanel")

function hud.createPropertiesPanel(...)
    return propertiesPanel.new(...)
end
```
