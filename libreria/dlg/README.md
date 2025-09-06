Dialogue system (dlg)
=====================

Ce module fournit un manager de dialogue minimal et un HUD léger.

Usage:

local dm = require("my-librairie.dlg.dialogueManager")
dm.initialize()
local sample = require("my-librairie.dlg.sample_dialogues")
dm.start(sample.hub_greeting)

API:
- start(dialogueTable) : démarre un tableau de messages
- next() : passe au message suivant
- close() : ferme le dialogue
- isActive() : retourne true si un dialogue est en cours

Le module expose aussi un HUD minimal dans `dialogueHUD.lua` et s'intègre à `_G.hud` si disponible.
