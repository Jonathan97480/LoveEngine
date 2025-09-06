# Module DialogueHUD

## Description
Le module `dialogueHUD.lua` gère l'interface utilisateur pour l'affichage des dialogues, incluant les panneaux, les textes, et les boutons.

## Fonctions principales
- `dialogueHUD.show(entry)` : Affiche une entrée de dialogue.
- `dialogueHUD.update(entry)` : Met à jour l'affichage.
- `dialogueHUD.hide()` : Masque l'interface.

## Exemple d'utilisation
```lua
local dh = require("libreria/dlg/dialogueHUD")

dh.show({text = "Hello", character = "NPC"})
```
