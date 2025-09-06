# Module DialogueManager

## Description
Le module `dialogueManager.lua` gère la logique des dialogues dans le jeu, incluant l'affichage séquentiel des textes, les choix, et les interactions.

## Fonctions principales
- `dialogueManager.startDialogue(dialogue)` : Démarre un dialogue.
- `dialogueManager.next()` : Passe au texte suivant.
- `dialogueManager.skip()` : Saute le dialogue.

## Exemple d'utilisation
```lua
local dm = require("libreria/dlg/dialogueManager")

dm.startDialogue(myDialogue)
```
