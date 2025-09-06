# Module GlobalFunction

## Description
Le module `globalFunction.lua` fournit une collection de fonctions utilitaires pour le jeu LÖVE2D, incluant l'animation, la gestion de la souris, les logs, les maths, les tables, les chaînes et la validation.

## Fonctions principales
### Animation et Interpolation
- `globalFunction.lerp(a, b, vitesse)` : Interpolation linéaire entre deux points.
- `globalFunction.lerpNum(a, b, t)` : Interpolation linéaire entre deux nombres.

### Gestion de la souris
- `globalFunction.mouse.hover(x, y, largeur, hauteur, echelle)` : Vérifie le survol d'une zone.
- `globalFunction.mouse.click()` : Détecte un clic.

### Logs
- `globalFunction.log` : Table pour les fonctions de logging (avec niveaux comme info, error, etc.).

### Autres utilitaires
Le module inclut de nombreuses autres fonctions pour les maths, tables, chaînes, etc.

## Exemple d'utilisation
```lua
local gf = require("libreria/tools/globalFunction")

-- Interpolation
local pos = gf.lerp({x=0, y=0}, {x=100, y=100}, 0.1)

-- Log
gf.log.info("Message d'information")

-- Survol souris
if gf.mouse.hover(10, 10, 50, 50) then
    -- Code
end
```
