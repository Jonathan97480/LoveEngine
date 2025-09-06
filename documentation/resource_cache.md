# Module Resource Cache

## Description
Le module `resource_cache.lua` fournit un cache amélioré pour les ressources (images, polices, audio) avec monitoring et gestion de la mémoire.

## Fonctions principales
- `res.image(path)` : Charge et cache une image.
- `res.font(path_or_size, size)` : Charge et cache une police.
- `res.audio(path, audioType)` : Charge et cache un fichier audio.
- `res.cleanup()` : Nettoie le cache automatiquement.

## Exemple d'utilisation
```lua
local res = require("libreria/tools/resource_cache")

local img = res.image("path/to/image.png")
local font = res.font("path/to/font.ttf", 12)
```
