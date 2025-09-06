local sample = {}

-- Dialogue simple pour narration
sample.intro_narration = {
    { character = "Narrateur", text = _G and _G.t and _G.t("dialogue.intro.line1") or "Il était une fois..." },
    { character = "Narrateur", text = _G and _G.t and _G.t("dialogue.intro.line2") or "Une aventure commence." },
}

-- Dialogue avec portraits pour interaction entre personnages
sample.hub_greeting = {
    { character = "Villageois", text = "Bonjour, voyageur.",               portrait = "img/Actor/Enemy/Enemy-1.png" },
    { character = "Joueur",     text = "Salut. Vous avez des nouvelles ?", portrait = "img/Actor/hero/Hero.png" },
}

-- Exemple avec audio synchronisé
sample.intro_with_audio = {
    {
        character = "Narrateur",
        text = "Dans un royaume lointain, une prophétie ancienne se réveille...",
        audio = "audio/narration/intro_line1.ogg",
        audioDuration = 4.5, -- fallback si fichier audio inaccessible
        revealMode = "word"  -- Révélation mot par mot pour narration
    },
    {
        character = "Narrateur",
        text = "Un héros doit se lever pour sauver le monde.",
        audio = "audio/narration/intro_line2.ogg",
        audioDuration = 3.2,
        revealMode = "word"
    }
}

-- Dialogue de combat avec durées courtes
sample.combat_taunt = {
    {
        character = "Gobelin",
        text = "Tu vas le payer !",
        portrait = "img/Actor/Enemy/Enemy-2.png",
        duration = 1.5 -- Rapide pour le combat
    },
    {
        character = "Héros",
        text = "On verra bien !",
        portrait = "img/Actor/hero/Hero.png",
        duration = 1.2
    }
}

-- Dialogue avec pauses dramatiques
sample.dramatic_revelation = {
    {
        character = "Oracle",
        text = "...",
        duration = 2.0 -- Pause silencieuse
    },
    {
        character = "Oracle",
        text = "L'élu... c'est toi.",
        portrait = "img/Actor/npc/oracle.png",
        duration = 3.5,
        revealMode = "word" -- Révélation mot par mot
    },
    {
        character = "Héros",
        text = "Moi ? Mais... je ne comprends pas !",
        portrait = "img/Actor/hero/Hero.png",
        revealMode = "char" -- Révélation caractère par caractère
    }
}

-- Dialogue multilingue avec variables
sample.shop_interaction = {
    {
        character = _G and _G.t and _G.t("characters.merchant") or "Marchand",
        text = _G and _G.t and _G.t("dialogue.shop.greeting") or "Bienvenue dans ma boutique !",
        portrait = "img/Actor/npc/merchant.png"
    },
    {
        character = _G and _G.t and _G.t("characters.player") or "Joueur",
        text = _G and _G.t and _G.t("dialogue.shop.inquiry") or "Que vendez-vous ?",
        portrait = "img/Actor/hero/Hero.png"
    },
    {
        character = _G and _G.t and _G.t("characters.merchant") or "Marchand",
        text = _G and _G.t and _G.t("dialogue.shop.offers") or "J'ai des potions et des armes !",
        portrait = "img/Actor/npc/merchant.png"
    }
}

-- Exemple avec métadonnées pour logique de jeu
sample.quest_start = {
    {
        character = "Garde du Roi",
        text = "Le roi souhaite vous voir immédiatement !",
        portrait = "img/Actor/npc/royal_guard.png",
        meta = {
            questId = "main_quest_01",
            flagToSet = "met_king",
            importance = "high"
        }
    },
    {
        character = "Héros",
        text = "J'y vais de ce pas.",
        portrait = "img/Actor/hero/Hero.png",
        meta = {
            flagToSet = "accepted_king_summons"
        }
    }
}

-- Nouveau : Exemple avec événements personnalisés
sample.tutorial_with_events = {
    {
        character = "Guide",
        text = "Bienvenue ! Je vais vous expliquer les commandes.",
        portrait = "img/Actor/npc/guide.png",
        meta = {
            onStart = function()
                -- Déclencher mode tutoriel
                if _G.gameState then
                    _G.gameState.tutorialMode = true
                end
            end
        }
    },
    {
        character = "Guide",
        text = "Utilisez les flèches pour vous déplacer.",
        portrait = "img/Actor/npc/guide.png"
    },
    {
        character = "Guide",
        text = "Parfait ! Vous maîtrisez les bases.",
        portrait = "img/Actor/npc/guide.png",
        meta = {
            onComplete = function()
                -- Fin du tutoriel
                if _G.gameState then
                    _G.gameState.tutorialMode = false
                    _G.gameState.tutorialCompleted = true
                end
            end
        }
    }
}

return sample
