# Module TextFormatter

## Description
Le module `textFormatter.lua` formate les textes pour l'affichage.

## Fonctions principales
- `textFormatter.format(text, params)` : Formate un texte avec des paramètres.

## Exemple d'utilisation
```lua
local textFormatter = require("libreria/localization-system/textFormatter")

local formatted = textFormatter.format("Hello {name}", {name="World"})
```
