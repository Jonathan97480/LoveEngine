# LoveEngine

[![Love2D](https://img.shields.io/badge/Love2D-11.4-blue.svg)](https://love2d.org/)
[![Lua](https://img.shields.io/badge/Lua-5.1-blue.svg)](https://www.lua.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Un moteur de jeu 2D modulaire développé avec Love2D, offrant un système de bibliothèque complet pour le développement de jeux vidéo.

## 📋 Description

LoveEngine est un framework de développement de jeux 2D basé sur Love2D qui fournit une architecture modulaire et extensible. Le projet inclut un système de gestion de ressources, d'interface utilisateur, de sauvegarde, de localisation et bien plus encore.

## ✨ Fonctionnalités

### 🛠️ Outils de Base
- **Gestionnaire de Ressources** (`resource_cache`) - Cache intelligent avec monitoring mémoire
- **Fonctions Globales** (`globalFunction`) - Utilitaires pour animations, logs, maths, validation
- **Gestionnaire de Scène** (`sceneManager`) - Transitions et gestion d'états de jeu
- **Gestionnaire d'Acteurs** (`actorManager`) - Système d'entités et spawning
- **Configuration Débogage** (`debugConfig`) - Outils de développement et profiling

### 🎮 Interface Utilisateur (HUD)
- **Boutons** - Composants interactifs personnalisables
- **Cases à cocher** - Éléments de formulaire
- **Curseurs** - Contrôles de valeur numérique
- **Panneaux** - Conteneurs pour l'interface
- **Texte** - Rendu de texte avec styles
- **Dessin** - Wrapper autour de Love2D Graphics

### 💾 Système de Sauvegarde
- **Gestionnaire de Sauvegarde** (`saveManager`) - Sauvegarde/chargement JSON
- **Interface Sauvegarde** (`saveUI`) - Interface utilisateur pour les sauvegardes
- **Slots multiples** avec métadonnées
- **Validation automatique** des données

### 🌍 Localisation
- **Gestionnaire de Localisation** (`localizationManager`) - Support multilingue
- **Chargeur de Texte** (`textLoader`) - Chargement des fichiers de langue
- **Formateur de Texte** (`textFormatter`) - Formatage avancé des chaînes
- **Support JSON** pour les fichiers de langue

### 🎯 Entrées Utilisateur
- **Gestionnaire d'Entrées** (`inputManager`) - Capture clavier/souris
- **Interface d'Entrées** (`inputInterface`) - Abstraction unifiée
- **Support manette** et contrôles personnalisés

### 💬 Système de Dialogue
- **Gestionnaire de Dialogue** (`dialogueManager`) - Système de dialogues
- **HUD de Dialogue** (`dialogueHUD`) - Interface de dialogue
- **Échantillons de dialogues** inclus

## 📁 Structure du Projet

```
LoveEngine/
├── main.lua                 # Point d'entrée du jeu
├── globals.lua              # Exposition globale des modules
├── libreria/                # Bibliothèque principale
│   ├── config.lua           # Configuration globale
│   ├── dlg/                 # Système de dialogue
│   │   ├── dialogueHUD.lua
│   │   ├── dialogueManager.lua
│   │   └── sample_dialogues.lua
│   ├── hud/                 # Interface utilisateur
│   │   ├── button/
│   │   ├── checkbox/
│   │   ├── panel/
│   │   ├── slider/
│   │   ├── text/
│   │   ├── draw.lua
│   │   └── hud.lua
│   ├── localization-system/ # Système de localisation
│   │   ├── localizationManager.lua
│   │   ├── textFormatter.lua
│   │   └── textLoader.lua
│   ├── save-system/         # Système de sauvegarde
│   │   ├── saveManager.lua
│   │   └── saveUI.lua
│   └── tools/               # Outils utilitaires
│       ├── actorManager.lua
│       ├── cursor.lua
│       ├── debugConfig.lua
│       ├── globalFunction.lua
│       ├── inputInterface.lua
│       ├── inputManager.lua
│       ├── json.lua
│       ├── resource_cache.lua
│       ├── responsive.lua
│       └── sceneManager.lua
├── localization/            # Fichiers de langue
│   ├── en.json
│   └── fr.json
└── documentation/           # Documentation des modules
```

## 🚀 Installation

### Prérequis
- [Love2D](https://love2d.org/) (version 11.4 ou supérieure)
- Windows/Linux/macOS

### Installation
1. Clonez le dépôt :
```bash
git clone https://github.com/Jonathan97480/LoveEngine.git
cd LoveEngine
```

2. Lancez le jeu :
```bash
love .
```

## 📖 Utilisation

### Chargement des Modules
Tous les modules sont automatiquement chargés via `globals.lua` :

```lua
-- Les modules sont disponibles globalement
_G.globalFunction.log.info("Hello World!")
_G.sceneManager.switch("menu")
```

### Exemple d'Utilisation Basique
```lua
function love.load()
    -- Initialisation du jeu
    _G.globalFunction.log.info("Game started!")
end

function love.update(dt)
    -- Mise à jour du jeu
    _G.sceneManager.update(dt)
end

function love.draw()
    -- Rendu du jeu
    _G.sceneManager.draw()
end
```

### Création d'une Nouvelle Scène
```lua
local menuScene = {
    load = function()
        -- Initialisation de la scène menu
    end,
    update = function(dt)
        -- Logique de mise à jour
    end,
    draw = function()
        -- Rendu de la scène
    end
}

_G.sceneManager.register("menu", menuScene)
_G.sceneManager.switch("menu")
```

## 🛠️ Technologies Utilisées

- **Love2D** - Framework de développement de jeux 2D
- **Lua 5.1** - Langage de programmation
- **JSON** - Format de données pour la sauvegarde et la localisation
- **Git** - Gestion de version

## 🤝 Contribution

Les contributions sont les bienvenues ! Voici comment contribuer :

1. Fork le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Pushez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

### Standards de Code
- Utilisez des noms descriptifs pour les variables et fonctions
- Commentez votre code
- Testez vos changements
- Respectez la structure modulaire existante

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👤 Auteur

**Jonathan97480** - *Développement initial*

## 🙏 Remerciements

- [Love2D Community](https://love2d.org/forums/) - Pour le support et les ressources
- [Lua](https://www.lua.org/) - Pour le langage de programmation
- [GitHub Copilot](https://github.com/features/copilot) - Pour l'assistance au développement

---

⭐ Si ce projet vous plaît, n'hésitez pas à lui donner une étoile !
