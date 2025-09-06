# Module SaveManager

## Description
Le module `saveManager.lua` gère la logique de sauvegarde et chargement des données de jeu, incluant la sérialisation, la gestion des slots, et les opérations sur les fichiers.

## Fonctions principales
- `saveManager.saveToSlot(slotId)` : Sauvegarde les données dans un slot.
- `saveManager.loadFromSlot(slotId)` : Charge les données depuis un slot.
- `saveManager.getSaveSlots()` : Retourne la liste des slots de sauvegarde.

## Exemple d'utilisation
```lua
local saveManager = require("libreria/save-system/saveManager")

saveManager.saveToSlot(1)
```
