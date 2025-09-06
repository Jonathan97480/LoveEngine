# Module ActorManager

## Description
Le module `actorManager.lua` gère les acteurs du jeu, principalement les ennemis, avec des fonctions de spawn et de gestion.

## Fonctions principales
- `actorManager.spawnEnemy(type, position)` : Fait apparaître un ennemi.
- `actorManager.clearAllEnemies()` : Efface tous les ennemis.

## Exemple d'utilisation
```lua
local actorManager = require("libreria/tools/actorManager")

actorManager.spawnEnemy("goblin", {x=100, y=100})
```
