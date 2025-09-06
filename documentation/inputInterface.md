# Module InputInterface

## Description
Le module `inputInterface.lua` fournit une interface unifiée pour gérer les entrées utilisateur, supportant la souris et les manettes. Il gère le curseur, les actions, et détecte automatiquement la source d'entrée active.

## Fonctions
### `I.init()`
Initialise l'interface d'entrée et le curseur.
- **Paramètres** : Aucun.
- **Retour** : Aucun.

### `I.update(dt)`
Met à jour l'état des entrées et du curseur.
- **Paramètres** :
  - `dt` : Delta time.
- **Retour** : Aucun.

### `I.getCursor()`
Retourne la position actuelle du curseur.
- **Paramètres** : Aucun.
- **Retour** : Table {x, y}.

### `I.isActionDown()`
Vérifie si l'action est enfoncée.
- **Paramètres** : Aucun.
- **Retour** : Booléen.

### `I.justPressedAction()`
Vérifie si l'action vient d'être pressée.
- **Paramètres** : Aucun.
- **Retour** : Booléen.

### `I.justReleasedAction()`
Vérifie si l'action vient d'être relâchée.
- **Paramètres** : Aucun.
- **Retour** : Booléen.

### `I.getActiveSource()`
Retourne la source d'entrée active (mouse ou joystick).
- **Paramètres** : Aucun.
- **Retour** : Chaîne.

### `I.GetKeyPressed()`
Retourne la touche pressée (si applicable).
- **Paramètres** : Aucun.
- **Retour** : Valeur de la touche.

## Exemple d'utilisation
```lua
local inputInterface = require("libreria/tools/inputInterface")

inputInterface.init()

-- Dans love.update
inputInterface.update(dt)

-- Obtenir le curseur
local cursor = inputInterface.getCursor()
print(cursor.x, cursor.y)

-- Vérifier une action
if inputInterface.isActionDown() then
    -- Code pour action
end
```
