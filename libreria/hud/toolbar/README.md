# Module Toolbar

Module pour créer et gérer des barres d'outils avec boutons intégrés dans LÖVE2D.

## Utilisation

```lua
local toolbar = require("libreria.hud.toolbar.toolbar")

-- Créer une nouvelle toolbar
local myToolbar = toolbar.new(0, 0, 800)

-- Définir le titre
myToolbar:setTitle("Mon Éditeur")

-- Ajouter des boutons
myToolbar:addButton("Nouveau", function()
    print("Nouveau projet")
end)

myToolbar:addButton("Sauvegarder", function()
    print("Sauvegarde")
end)

-- Dans love.update
myToolbar:update(love.mouse.getX(), love.mouse.getY())

-- Dans love.draw
myToolbar:draw()

-- Dans love.mousepressed
if myToolbar:mousepressed(x, y, button) then
    -- Un bouton a été cliqué
end
```

## Fonctions

### toolbar.new(x, y, width)
Crée une nouvelle instance de toolbar.

**Paramètres :**
- `x` (number) : Position X (défaut : 0)
- `y` (number) : Position Y (défaut : 0)
- `width` (number) : Largeur (défaut : largeur de l'écran)

**Retour :** Instance de toolbar

### instance:addButton(text, callback, x)
Ajoute un bouton à la toolbar.

**Paramètres :**
- `text` (string) : Texte du bouton
- `callback` (function) : Fonction appelée au clic
- `x` (number, optionnel) : Position X relative

### instance:setTitle(title)
Définit le titre de la toolbar.

### instance:update(mouseX, mouseY)
Met à jour l'état des boutons (hover).

### instance:mousepressed(mouseX, mouseY, button)
Gère les clics sur les boutons.

**Retour :** `true` si un bouton a été cliqué

### instance:draw()
Dessine la toolbar et ses boutons.

## Configuration

Le module utilise une configuration par défaut modifiable :

```lua
toolbar.config = {
    height = 40,           -- Hauteur de la toolbar
    buttonWidth = 60,      -- Largeur des boutons
    buttonHeight = 30,     -- Hauteur des boutons
    buttonSpacing = 10,    -- Espacement entre boutons
    backgroundColor = {0.3, 0.3, 0.3, 1},  -- Couleur de fond
    buttonColor = {0.5, 0.5, 0.5, 1},      -- Couleur des boutons
    textColor = {1, 1, 1, 1}               -- Couleur du texte
}
```
