# Module DebugConfig

## Description
Le module `debugConfig.lua` centralise tous les flags de debug du projet, remplaçant les variables dispersées par un namespace unifié.

## Variables
- `DebugConfig.FLAGS` : Table contenant tous les flags de debug (GLOBAL_DEBUG, VERBOSE_MODE, GAMEPLAY, etc.).

## Fonctions
- `DebugConfig.migrateLegacyFlags()` : Migre les anciens flags vers le nouveau système.

## Exemple d'utilisation
```lua
local debugConfig = require("libreria/tools/debugConfig")

if debugConfig.FLAGS.GLOBAL_DEBUG then
    print("Debug activé")
end
```
