# Module SceneManager

## Description
Le module `sceneManager.lua` gère les scènes du jeu, permettant de pousser, popper et gérer une pile de scènes avec des options de debug et de mode stack.

## Fonctions principales
- `scene:push(sc)` : Ajoute une scène à la pile.
- `scene:pop()` : Retire la scène du sommet.
- `scene:clear()` : Vide la pile de scènes.
- `scene:top()` : Retourne la scène au sommet.
- `scene:update(dt, ...)` : Met à jour toutes les scènes.
- `scene:draw(...)` : Dessine toutes les scènes.

## Exemple d'utilisation
```lua
local sceneManager = require("libreria/tools/sceneManager")

sceneManager:push(myScene)
sceneManager:update(dt)
sceneManager:draw()
```
