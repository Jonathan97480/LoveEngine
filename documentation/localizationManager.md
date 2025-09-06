# Module LocalizationManager

## Description
Le module `localizationManager.lua` gère la localisation du jeu, incluant le chargement des fichiers de langue et la traduction des textes.

## Fonctions principales
- `localizationManager.loadLanguage(lang)` : Charge une langue.
- `localizationManager.getText(key)` : Retourne le texte traduit pour une clé.

## Exemple d'utilisation
```lua
local loc = require("libreria/localization-system/localizationManager")

loc.loadLanguage("fr")
print(loc.getText("hello"))
```
