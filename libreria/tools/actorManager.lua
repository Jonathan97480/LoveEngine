-- libreria/tools/actorManager.lua

-- Module + alias public (compat)
local actor = {}
local actorManager = actor -- alias retourné par require
local res = require("libreria/tools/resource_cache")
-- Alias global de compat au cas où certains scripts utilisent _G.actorManager directement
rawset(_G, "actorManager", actor)

-- Enemy registry helper (spawn API) - resolved lazily to avoid circular requires
local EnemiesMod = nil

-- init actor manager runtime fields
function actor:init()
    _G.globalFunction.log.info("[actorManager] Initialisation du module Enemy")
    local Enemy = _G.Enemies or require("libreria/entities/Enemy/Enemies")
    if Enemy then
        Enemy.listeEnemies = {}
        Enemy.curentEnemy = nil
    end
end

function actor:clearEnemies()
    _G.globalFunction.log.info("[actorManager] Effacement de tous les Ennemis")
    local Enemies = _G.Enemies or require("libreria/entities/Enemy/Enemies")
    if Enemies then
        Enemies.listeEnemies = {}
        Enemies.curentEnemy = nil
    end
end

----------------------------------------------------------------------
-- Spawn d'ennemis avec gestion de doublons et sélection aléatoire
----------------------------------------------------------------------
function actor:spawnEnemy(spawnPosition, poolEnemies, options)
    -- Validation des paramètres d'entrée
    if not spawnPosition or not spawnPosition.type then
        _G.globalFunction.log.error("[actorManager:spawnEnemy] spawnPosition invalide ou manque type")
        return nil
    end

    if not poolEnemies or type(poolEnemies) ~= "table" or #poolEnemies == 0 then
        _G.globalFunction.log.error("[actorManager:spawnEnemy] poolEnemies vide ou invalide")
        return nil
    end

    -- Options par défaut
    options = options or {}
    local allowDuplicates = options.allowDuplicates ~= false -- true par défaut
    local shufflePool = options.shufflePool or false

    -- Lazy loading du module Enemies pour éviter les require circulaires
    local Enemies = require("libreria/entities/enemy/enemy")
    if not Enemies then
        _G.globalFunction.log.error("[actorManager:spawnEnemy] Module Enemies introuvable")
        return nil
    end

    -- Vérification des doublons si non autorisés
    if not allowDuplicates and Enemies.listeEnemies then
        for _, enemy in ipairs(Enemies.listeEnemies) do
            if enemy.type == spawnPosition.type then
                _G.globalFunction.log.warn(("[actorManager:spawnEnemy] Spawn annulé: Ennemi type '%s' déjà présent (doublons interdits)")
                    :format(spawnPosition.type))
                return enemy
            end
        end
    end

    -- Mélange de la pool si demandé (copie pour éviter mutation)
    local workingPool = poolEnemies
    if shufflePool then
        workingPool = {}
        for i, enemy in ipairs(poolEnemies) do
            workingPool[i] = enemy
        end

        -- Shuffle Fisher-Yates optimisé
        math.randomseed(os.time())
        for i = #workingPool, 2, -1 do
            local j = math.random(i)
            workingPool[i], workingPool[j] = workingPool[j], workingPool[i]
        end
    end

    -- Sélection des ennemis correspondant au type demandé
    local candidates = {}
    for _, enemyTemplate in ipairs(workingPool) do
        if enemyTemplate.data and enemyTemplate.data.type == spawnPosition.type then
            table.insert(candidates, enemyTemplate.data)
        end
    end

    -- Validation de la sélection
    if #candidates == 0 then
        _G.globalFunction.log.error(("[actorManager:spawnEnemy] Aucun ennemi de type '%s' trouvé dans la pool")
            :format(spawnPosition.type))
        return nil
    end

    -- Sélection aléatoire parmi les candidats
    local selectedData = candidates[math.random(#candidates)]

    -- Création de l'ennemi
    local spawnData = {
        x = spawnPosition.x or 0,
        y = spawnPosition.y or 0,
        enemyData = selectedData
    }

    local newEnemy = Enemies.create and Enemies.create(spawnData)
    if not newEnemy then
        _G.globalFunction.log.error(("[actorManager:spawnEnemy] Échec création ennemi type '%s'")
            :format(spawnPosition.type))
        return nil
    end

    -- Ajout à la liste des ennemis
    Enemies.listeEnemies = Enemies.listeEnemies or {}
    table.insert(Enemies.listeEnemies, newEnemy)

    _G.globalFunction.log.info(("[actorManager:spawnEnemy] Ennemi '%s' spawné en (%d,%d)")
        :format(spawnPosition.type, spawnPosition.x or 0, spawnPosition.y or 0))

    return newEnemy
end

----------------------------------------------------------------------
-- Crée un acteur
----------------------------------------------------------------------
function actor.create(p_name, p_animation, p_vector2)
    local newActor           = {}

    newActor.name            = p_name or ""
    newActor.nameDeck        = ""
    newActor.vector2         = { x = (p_vector2 and p_vector2.x) or 0, y = (p_vector2 and p_vector2.y) or 0 }

    newActor.animation       = { isPlay = false }
    newActor.curentAnimation = 'idle'

    newActor.width           = 0
    newActor.height          = 0

    newActor.state           = {
        life           = 80,
        maxLife        = 80,
        power          = 8,
        powerMax       = 8,
        degat          = 0,
        shield         = 0,
        dead           = false,
        epine          = 0,
        chancePassTour = 0,
    }

    newActor.sound           = { sfx = {}, music = {} }

    actor.addAnimation(newActor.animation, p_animation or {})
    actor.get.size(newActor)
    actor.ensureStateDefaults(newActor) -- normalise les nombres

    return newActor
end

actor.get, actor.set = {}, {}

----------------------------------------------------------------------
-- Taille depuis la première frame dispo
----------------------------------------------------------------------
function actor.get.size(p_actor)
    if not p_actor or not p_actor.animation then return end
    for _, frames in pairs(p_actor.animation) do
        if type(frames) == "table" and frames[1] and frames[1].getDimensions then
            p_actor.width, p_actor.height = frames[1]:getDimensions()
            return
        end
    end
end

----------------------------------------------------------------------
-- Ajout d’animations depuis des chemins
----------------------------------------------------------------------
function actor.addAnimation(p_animTable, p_animation)
    if type(p_animTable) ~= "table" or type(p_animation) ~= "table" then return end
    for state, paths in pairs(p_animation) do
        p_animTable[state] = {}
        for _, path in ipairs(paths) do
            local ok, img = pcall(res.image, path)
            if ok and img then table.insert(p_animTable[state], img) end
        end
    end
end

----------------------------------------------------------------------
-- Suppression d’animations
----------------------------------------------------------------------
function actor.removeAnimation(p_animTable, p_animation)
    if type(p_animTable) ~= "table" or type(p_animation) ~= "table" then return end
    for state, flag in pairs(p_animation) do
        if flag and p_animTable[state] then p_animTable[state] = nil end
    end
end

----------------------------------------------------------------------
-- Bascule d’animation
----------------------------------------------------------------------
function actor.playAnimation(p_actor, p_animation)
    if not p_actor or not p_actor.animation then return end
    if p_actor.animation[p_animation] then
        p_actor.animation.isPlay = true
        p_actor.curentAnimation  = p_animation
    end
end

----------------------------------------------------------------------
-- Outils d’état (normalisation + power)
----------------------------------------------------------------------
function actor.ensureStateDefaults(p_actor)
    if not p_actor or not p_actor.state then return end
    local st   = p_actor.state
    st.life    = tonumber(st.life) or 0
    st.maxLife = tonumber(st.maxLife) or st.life or 0
    if st.maxLife <= 0 then st.maxLife = 1 end
    st.life     = math.max(0, math.min(st.life, st.maxLife))
    st.power    = tonumber(st.power) or 0
    st.powerMax = tonumber(st.powerMax) or st.power or 0
    if st.powerMax < 0 then st.powerMax = 0 end
    st.power          = math.max(0, math.min(st.power, st.powerMax))
    st.degat          = tonumber(st.degat) or 0
    st.shield         = tonumber(st.shield) or 0
    st.epine          = tonumber(st.epine) or 0
    st.chancePassTour = tonumber(st.chancePassTour) or 0
    st.dead           = not not st.dead
end

function actor.canAfford(p_actor, cost)
    if not p_actor or not p_actor.state then return false end
    local c = math.max(0, tonumber(cost) or 0)
    return (p_actor.state.power or 0) >= c
end

function actor.consumePower(p_actor, cost)
    if not p_actor or not p_actor.state then return 0 end
    local c = math.max(0, tonumber(cost) or 0)
    local p = tonumber(p_actor.state.power) or 0
    local used = math.min(p, c)
    p_actor.state.power = p - used
    return used
end

----------------------------------------------------------------------
-- Effets simples
-- kind: "damage" | "heal" | "shield" | "epine" | "thorns" | "skip"
----------------------------------------------------------------------
function actor.applyEffect(target, kind, value, opts)
    if not target or type(target) ~= "table" or not target.state then return end
    kind = tostring(kind or ""):lower()
    local v = tonumber(value or 0) or 0
    local st = target.state

    -- S’assure que l’état est sain
    actor.ensureStateDefaults(target)

    if kind == "damage" then
        local remain = math.max(0, v)
        local shield = st.shield or 0
        if shield > 0 and remain > 0 then
            local absorb = math.min(shield, remain)
            st.shield = shield - absorb
            remain = remain - absorb
        end
        if remain > 0 then
            st.life = math.max(0, (st.life or 0) - remain)
            if st.life <= 0 then st.dead = true end
        end
    elseif kind == "heal" then
        local maxLife = st.maxLife or st.life or 0
        if maxLife < 0 then maxLife = 0 end
        st.life = math.min(maxLife, (st.life or 0) + math.abs(v))
    elseif kind == "shield" then
        st.shield = (st.shield or 0) + math.abs(v)
    elseif kind == "epine" or kind == "thorns" then
        st.epine = (st.epine or 0) + math.abs(v)
    elseif kind == "skip" then
        local nv = math.max(0, math.min(100, math.abs(v)))
        st.chancePassTour = math.max(0, math.min(100, (st.chancePassTour or 0) + nv))
    end
end

return actor
