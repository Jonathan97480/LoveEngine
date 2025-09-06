# Module Responsive

## Description
Le module `responsive.lua` gère la responsivité de l'écran et les positions de la souris dans un jeu LÖVE. Il calcule les ratios d'échelle basés sur la résolution du jeu (1920x1080) et la taille actuelle de la fenêtre, et ajuste les positions de la souris en conséquence.

## Variables
- `screenManager.gameReso` : Résolution de base du jeu (width: 1920, height: 1080).
- `screenManager.ratioScreen` : Ratios d'échelle actuels (width, height).
- `screenManager.Syncro` : Booléen pour la synchronisation verticale (vsync).
- `screenManager.FullScreen` : Booléen pour le mode plein écran.
- `screenManager.resizable` : Booléen pour la redimensionnabilité de la fenêtre.
- `screenManager.mouse` : Table contenant les positions de la souris ajustées (X, Y).

## Fonctions
### `screenManager.getRatio()`
Retourne les ratios d'échelle actuels.
- **Paramètres** : Aucun.
- **Retour** : width, height (nombres).

### `screenManager.UpdateRatio(dt)`
Met à jour les ratios d'échelle et les positions de la souris basés sur la taille actuelle de la fenêtre.
- **Paramètres** :
  - `dt` : Delta time (non utilisé dans la fonction).
- **Retour** : Aucun.

## Exemple d'utilisation
```lua
local responsive = require("libreria/tools/responsive")

-- Obtenir les ratios
local w, h = responsive.getRatio()

-- Mettre à jour les ratios (appeler dans love.update)
responsive.UpdateRatio(dt)

-- Utiliser la position de la souris ajustée
local mouseX = responsive.mouse.X
local mouseY = responsive.mouse.Y
```
