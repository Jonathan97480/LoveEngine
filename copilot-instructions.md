# Instructions pour Copilot - Projet Editeur Love 2D

## Architecture du Projet

Le projet est organisé comme suit :

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

Ces instructions doivent être suivies pour maintenir la structure modulaire et éviter les conflits de noms ou les chargements redondants.
