# LoveEngine

[![Love2D](http**Interface :**
- Fond gris
- Jeu normal sans outils de développement
- ESC pour retourner au mode développement

## 🔄 Changements Récents

### v1.0.1 - Correction de stabilité
- ✅ **Correction critique** : Résolution de l'erreur `ipairs` dans la détection de mode
- ✅ **Amélioration robustesse** : Gestion sécurisée des arguments Love2D
- ✅ **Système de modes stable** : Modes développement et jeu entièrement fonctionnels
- ✅ **Logs optimisés** : Messages de debug nettoyés pour la production

## �📋 Descriptiong.shields.io/badge/Love2D-11.4-blue.svg)](https://love2d.org/)
[![Lua](https://img.shields.io/badge/Lua-5.1-blue.svg)](https://www.lua.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Un moteur de jeu 2D modulaire développé avec Love2D, offrant un système de bibliothèque complet pour le développement de jeux vidéo.

## � Lancement

LoveEngine supporte deux modes distincts :

### Mode Développement (Par défaut)
```bash
love .
# ou explicitement
love . --dev
```

**Interface :**
- Fond bleu foncé
- Outils de développement intégrés
- Console de debug (F1)
- Éditeur de scènes (F2)
- Inspecteur d'objets (F3)

### Mode Éditeur de Scènes
```bash
./run_editor.bat
# ou
love . --mode=dev
```

**Fonctionnalités :**
- Création et modification de scènes
- Système de calques (layers)
- Éléments : Backgrounds, Sprites, Texte, Boutons, Panneaux
- Redimensionnement et repositionnement des éléments
- Sauvegarde automatique en JSON
- Explorateur d'images intégré
- Gestion des assets par scène

**Raccourcis :**
- `Ctrl+N` : Nouvelle scène
- `Ctrl+S` : Sauvegarder
- `F1` : Panneau des calques
- `F2` : Propriétés des éléments
- `Clic droit` : Ajouter un élément
- `Molette` : Zoom
- `G` : Afficher/Masquer la grille

## �📋 Description

LoveEngine est un framework de développement de jeux 2D basé sur Love2D qui fournit une architecture modulaire et extensible. Le projet inclut un système de gestion de ressources, d'interface utilisateur, de sauvegarde, de localisation et bien plus encore.

## ✨ Fonctionnalités

### 🎮 Système de Modes
- **Mode Développement** - Interface d'outils avec débogage intégré
- **Mode Jeu** - Expérience de jeu pure sans outils de développement
- **Détection automatique** des arguments de ligne de commande
- **Basculement fluide** entre les modes (ESC en mode jeu)

### 🎨 Éditeur de Scènes
- **Création de scènes** - Interface WYSIWYG pour créer des scènes
- **Système de calques** - Organisation des éléments par calques
- **Éléments visuels** - Sprites, textes, boutons, panneaux, backgrounds
- **Gestion d'assets** - Import d'images avec explorateur Windows
- **Sauvegarde JSON** - Export des scènes au format JSON
- **Rechargement dynamique** - Chargement des scènes sauvegardées

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
# Mode développement (par défaut)
love .
# ou
./run.bat dev

# Mode jeu
./run.bat game
# ou
love . --game
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

### Utilisation de l'Éditeur de Scènes
```lua
-- Créer une nouvelle scène
local scene = _G.sceneEditor.newScene("MaScene")

-- Ajouter des éléments
_G.sceneEditor.addElement("background", 0, 0)
_G.sceneEditor.addElement("sprite", 100, 100)
_G.sceneEditor.addElement("text", 200, 50)

-- Sauvegarder la scène
_G.sceneEditor.saveCurrentScene()

-- Charger une scène dans le jeu
_G.sceneLoader.loadScene("MaScene")
_G.sceneLoader.drawScene("MaScene")
```

### Structure d'une Scène JSON
```json
{
  "name": "MaScene",
  "width": 800,
  "height": 600,
  "layers": [
    {
      "name": "Background",
      "elements": [
        {
          "type": "background",
          "x": 0, "y": 0,
          "width": 800, "height": 600,
          "properties": {
            "color": [0.5, 0.7, 1, 1]
          }
        }
      ]
    }
  ]
}
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
