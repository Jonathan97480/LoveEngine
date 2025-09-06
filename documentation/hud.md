# Module HUD

## Description
Le module `hud.lua` gère l'interface utilisateur générale (HUD), incluant l'ajout de panneaux, boutons, labels, etc.

## Fonctions principales
- `hud.addPanel(name, config)` : Ajoute un panneau.
- `hud.addButton(name, config)` : Ajoute un bouton.
- `hud.addLabel(name, config)` : Ajoute un label.

## Exemple d'utilisation
```lua
local hud = require("libreria/hud/hud")

hud.addPanel("main", {x=0, y=0, w=800, h=600})
```
