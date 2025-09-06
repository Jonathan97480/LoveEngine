# Module Sample Dialogues (Interne)

## Description
Le module `sample_dialogues.lua` contient des exemples de dialogues pour le jeu. C'est un module interne à `libreria`.

## Note
Ce module est utilisé en interne par d'autres modules et n'est pas exposé globalement. Ne pas accéder directement depuis l'extérieur de `libreria`.

## Contenu
- Table de dialogues d'exemple.

## Exemple d'utilisation (Interne uniquement)
```lua
local sample_dialogues = require("libreria/dlg/sample_dialogues")

print(sample_dialogues[1].text)
```
