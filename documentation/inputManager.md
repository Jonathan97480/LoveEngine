# Module InputManager

## Description
Le module `inputManager.lua` centralise la gestion des entrées utilisateur (souris et clavier) pour le projet. Il fournit des fonctions pour détecter les clics, les survols, les états des actions, etc., en utilisant une interface d'entrée sous-jacente.

## Fonctions
### `input.update(dt)`
Met à jour l'état des entrées.
- **Paramètres** :
  - `dt` : Delta time.
- **Retour** : Aucun.

### `input.hover(x, y, width, height, scale)`
Vérifie si la souris survole une zone rectangulaire.
- **Paramètres** :
  - `x, y` : Position du rectangle.
  - `width, height` : Dimensions du rectangle.
  - `scale` : Échelle (table ou nombre).
- **Retour** : Booléen (true si survol).

### `input.click()`
Détecte un clic (action juste pressée).
- **Paramètres** : Aucun.
- **Retour** : Booléen ou nil.

### `input.state()`
Retourne l'état actuel de l'action (idle, pressed, held, released).
- **Paramètres** : Aucun.
- **Retour** : Chaîne d'état.

### `input.justPressed()`
Vérifie si l'action vient d'être pressée.
- **Paramètres** : Aucun.
- **Retour** : Booléen.

### `input.justReleased()`
Vérifie si l'action vient d'être relâchée.
- **Paramètres** : Aucun.
- **Retour** : Booléen.

## Exemple d'utilisation
```lua
local inputManager = require("libreria/tools/inputManager")

-- Mettre à jour dans love.update
inputManager.update(dt)

-- Vérifier un survol
if inputManager.hover(100, 100, 200, 50) then
    -- Code pour survol
end

-- Détecter un clic
if inputManager.click() then
    -- Code pour clic
end
```
