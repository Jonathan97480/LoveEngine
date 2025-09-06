# Module Text (Interne)

## Description
Le module `text.lua` gère l'affichage du texte dans l'interface HUD. C'est un module interne à `libreria`.

## Note
Ce module est utilisé en interne par d'autres modules et n'est pas exposé globalement. Ne pas accéder directement depuis l'extérieur de `libreria`.

## Fonctions principales
- `text.draw(x, y, content)` : Dessine du texte à une position.

## Exemple d'utilisation (Interne uniquement)
```lua
local text = require("libreria/hud/text/text")

text.draw(100, 100, "Hello World")
```
