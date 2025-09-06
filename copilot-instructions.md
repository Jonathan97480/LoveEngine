# Instructions pour Copilot - Projet Editeur Love 2D

## Architecture du Projet

Le projet est organisé com### Correction Automatique
- **Détecter et corriger** automatiquement tout nommage non conforme aux conventions Lua
- **Variables avec underscores inappropriés** : Convertir `my_variable` → `myVariable`
- **Fonctions PascalCase** : Convertir `MyFunction` → `myFunction` (sauf constructeurs)
- **Constantes camelCase** : Convertir `maxSize` → `MAX_SIZE`
- **Fichiers avec underscores** : Préférer `myModule.lua` à `my_module`

## Règles d'Utilisation du Système de Logging

### Utilisation Systématique des Logs
- **Toujours utiliser le système de logging** au lieu de `print()` direct
- **Préférer les logs structurés** avec niveaux appropriés :
  - `_G.globalFunction.log.info()` pour informations générales
  - `_G.globalFunction.log.warn()` pour avertissements
  - `_G.globalFunction.log.error()` pour erreurs
  - `_G.globalFunction.log.ok()` pour confirmations de succès

### Gestion du Spam de Logs
- **Éviter le spam** : Ne pas logger à chaque frame dans love.update()
- **Utiliser des timers** pour limiter la fréquence des logs répétitifs
- **Logs conditionnels** : Vérifier avant de logger si nécessaire

### Patterns de Logging Recommandés
```lua
-- AVANT (spam possible)
function love.update(dt)
    globalFunction.log.info("Position: " .. player.x .. ", " .. player.y) -- SPAM !
end

-- APRÈS (avec timer)
local logTimer = 0
function love.update(dt)
    logTimer = logTimer + dt
    if logTimer >= 1.0 then -- Log chaque seconde maximum
        globalFunction.log.info("Position: " .. player.x .. ", " .. player.y)
        logTimer = 0
    end
end
```

### Bonnes Pratiques
- **Logs dans love.load()** : `_G.globalFunction.log.info("Module initialisé")`
- **Logs d'erreurs** : `_G.globalFunction.log.error("Erreur critique: " .. err)`
- **Logs de debug** : Utiliser `warn` pour debug temporaire
- **Éviter print()** : Remplacer par le système de logging approprié

### Correction Automatique des Logs
- **Détecter `print()`** et proposer conversion vers système de logging
- **Ajouter timers automatiquement** pour logs potentiellement spammeurs
- **Vérifier la fréquence** des logs répétitifs dans les bouclest :

- **Racine** :
  - `globals.lua` : Définit les variables globales en chargeant les modules de `libreria`.
  - `main.lua` : Point d'entrée principal du projet.
  - `localization/` : Dossier pour la localisation.
    - `en.json`
    - `fr.json`

- **libreria/** : Bibliothèque de modules Lua pour le projet.
  - `dlg/` : Modules pour les dialogues.
    - `config.lua`
    - `dialogueHUD.lua`
    - `dialogueManager.lua`
    - `README.md`
    - `sample_dialogues.lua`
  - `hud/` : Modules pour l'interface utilisateur (HUD).
    - `draw.lua`
    - `hud.lua`
    - `button/`
      - `button.lua`
      - `README.md`
    - `checkbox/`
      - `checkbox.lua`
      - `README.md`
    - `panel/`
      - `panel.lua`
      - `README.md`
    - `slider/`
      - `README.md`
      - `slider.lua`
    - `text/`
      - `README.md`
      - `text.lua`
  - `localization-system/` : Système de localisation.
    - `localizationManager.lua`
    - `textFormatter.lua`
    - `textLoader.lua`
  - `save-system/` : Système de sauvegarde.
    - `saveManager.lua`
    - `saveUI.lua`
  - `tools/` : Outils utilitaires.
    - `cursor.lua`
    - `globalFunction.lua`
    - `inputInterface.lua`
    - `inputManager.lua`
    - `json.lua`
    - `responsive.lua`

## Variables Globales

Les variables globales suivantes sont définies dans `globals.lua` et doivent être utilisées automatiquement dans tous les fichiers hors du dossier `libreria` :

- `_G.responsive` : Module pour la responsivité.
- `_G.json` : Module pour la manipulation JSON.
- `_G.inputManager` : Gestionnaire d'entrée.
- `_G.inputInterface` : Interface d'entrée.
- `_G.globalFunction` : Fonctions globales utilitaires.
- `_G.sceneManager` : Gestionnaire de scènes.
- `_G.resource_cache` : Cache de ressources avec monitoring.
- `_G.debugConfig` : Configuration centralisée des flags de debug.
- `_G.actorManager` : Gestionnaire d'acteurs (ennemis, etc.).
- `_G.textLoader` : Chargeur de texte pour la localisation.
- `_G.textFormatter` : Formateur de texte.
- `_G.config` : Configuration des dialogues.
- `_G.saveUI` : Interface utilisateur pour les sauvegardes.
- `_G.saveManager` : Gestionnaire de sauvegardes.
- `_G.localizationManager` : Gestionnaire de localisation.
- `_G.dialogueManager` : Gestionnaire de dialogues.
- `_G.dialogueHUD` : Interface HUD pour les dialogues.
- `_G.hud` : Module principal pour l'interface HUD.

## Modules Internes (Non Exposés Globalement)

Les modules suivants sont internes à `libreria` et ne doivent pas être utilisés ou accessibles hors de ce dossier. Ils sont chargés localement par les autres modules selon les besoins :

- `cursor` : Gestion du curseur.
- `text` : Module pour le texte HUD.
- `sample_dialogues` : Exemples de dialogues.
- Autres modules utilitaires internes.
- `_G.saveManager` : Gestionnaire de sauvegardes.
- `_G.localizationManager` : Gestionnaire de localisation.
- `_G.dialogueManager` : Gestionnaire de dialogues.
- `_G.dialogueHUD` : Interface HUD pour les dialogues.
- `_G.hud` : Module principal pour l'interface HUD.

## Règles d'Utilisation

- **Référence à la documentation** : Avant d'implémenter des fonctionnalités ou de faire des corrections, toujours se référencer à la documentation dans le dossier `documentation/` pour comprendre les modules existants et leur utilisation.
- **Pour les fichiers dans `libreria/`** : Utiliser des `require` internes locaux pour charger les dépendances, sans utiliser les variables globales `_G`. Exemple : `local hud = require("libreria/hud/hud")`.
- **Pour les fichiers hors de `libreria/`** : Utiliser automatiquement les variables globales définies dans `globals.lua` au lieu de faire des `require` directs. Cela assure une cohérence et évite les duplications de chargement.

## Conventions de Nommage Lua

**Respecter strictement les conventions de nommage Lua recommandées :**

### Variables et Fonctions
- **Variables locales** : `camelCase` (ex: `local myVariable = 42`)
- **Variables globales** : `PascalCase` ou préfixées (ex: `MyGlobalVar`)
- **Fonctions** : `camelCase` (ex: `function myFunction()`)
- **Constantes** : `SCREAMING_SNAKE_CASE` (ex: `MAX_SIZE = 100`)

### Modules et Fichiers
- **Noms de fichiers** : `camelCase.lua` (ex: `myModule.lua`)
- **Noms de modules** : `camelCase` (ex: `local myModule = {}`)
- **Fonctions d'export** : `camelCase` (ex: `function module.initGame()`)

### Correction Automatique
- **Détecter et corriger** automatiquement tout nommage non conforme aux conventions Lua
- **Variables avec underscores inappropriés** : Convertir `my_variable` → `myVariable`
- **Fonctions PascalCase** : Convertir `MyFunction` → `myFunction` (sauf constructeurs)
- **Constantes camelCase** : Convertir `maxSize` → `MAX_SIZE`
- **Fichiers avec underscores** : Préférer `myModule.lua` à `my_module.lua`

### Exemples de Corrections
```lua
-- AVANT (incorrect)
local my_variable = 42
function My_Function()
local MAX_size = 100

-- APRÈS (correct)
local myVariable = 42
function myFunction()
local MAX_SIZE = 100
```

## Documentation des Fonctions

**Toutes les fonctions doivent être documentées selon le standard LDoc :**

### Format Obligatoire
```lua
--- Description courte de la fonction
-- @param nomParam type : Description du paramètre
-- @param autreParam type : Description de l'autre paramètre
-- @return type : Description de la valeur de retour
function monModule.maFonction(param1, param2)
    -- code
end
```

### Règles de Documentation
- **Toujours commencer par `---`** (triple tiret)
- **Première ligne** : Description courte et claire
- **@param** : Un par paramètre avec type et description
- **@return** : Type et description de la valeur retournée
- **Types courants** : `number`, `string`, `table`, `boolean`, `function`
- **Paramètres optionnels** : Indiquer `(optionnel)` dans la description

### Exemples Complets
```lua
--- Interpolation stable pour éviter les tremblements
-- @param a table : Position actuelle {x, y}
-- @param b table : Position cible {x, y}
-- @param vitesse number : Vitesse d'interpolation (optionnel, défaut 10)
-- @return boolean : True si un mouvement a eu lieu
function monModule.lerp(a, b, vitesse)
    -- code
end

--- Vérifie si une valeur est dans un intervalle
-- @param valeur number : Valeur à tester
-- @param min number : Borne inférieure
-- @param max number : Borne supérieure
-- @return boolean : True si valeur ∈ [min, max]
function monModule.clamp(valeur, min, max)
    -- code
end
```

### Correction Automatique
- **Détecter les fonctions non documentées** et ajouter la documentation
- **Corriger les documentations incomplètes** (paramètres manquants, etc.)
- **Respecter les types** et descriptions précises
- **Ajouter des exemples** quand nécessaire

Ces instructions doivent être suivies pour maintenir la structure modulaire et éviter les conflits de noms ou les chargements redondants.
