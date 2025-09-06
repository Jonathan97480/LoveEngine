# Module SaveUI

## Description
Le module `saveUI.lua` gère l'interface utilisateur pour les fonctionnalités de sauvegarde, incluant l'affichage des menus de sauvegarde, chargement, et suppression de fichiers de sauvegarde.

## Fonctions principales
- `saveUI.show(mode)` : Affiche l'interface de sauvegarde.
- `saveUI.hide()` : Masque l'interface.
- `saveUI.saveToSlot(slotId)` : Sauvegarde dans un slot.
- `saveUI.loadFromSlot(slotId)` : Charge depuis un slot.
- `saveUI.refreshSaveList()` : Rafraîchit la liste des sauvegardes.

## Exemple d'utilisation
```lua
local saveUI = require("libreria/save-system/saveUI")

saveUI.show("save")
```
