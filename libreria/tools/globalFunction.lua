-- globalFunction.lua (renommé de myFunction.lua)
-- Fournit des fonctions utilitaires précédemment exportées sous myFunction.
-- Ce module centralise divers helpers pour le jeu LÖVE2D, incluant animation, souris, logs, maths, tables, chaînes et validation.

local globalFunction = {}

-- Dépendances et configuration
local res = rawget(_G, 'resource_cache')
local okcfg, config = pcall(require, "libreria.config")
config = okcfg and config or { logs = { maxFiles = 10, maxEntries = 200, dir = "gameLogs" } }

-- Assure que la table logs existe
config.logs = config.logs or { maxFiles = 10, maxEntries = 200, dir = "gameLogs" }

-- Préparation du chemin de log de session pour écriture immédiate
local repertoireLogs = config.logs.dir or "gameLogs"
local nomSession = "session_" .. os.date("%Y%m%d_%H%M%S") .. ".log"
local cheminSession = repertoireLogs .. "/" .. nomSession

-- Tentative de création du répertoire (utilise love.filesystem si disponible, sinon os.execute)
pcall(function()
    if type(love) == 'table' and love.filesystem and type(love.filesystem.createDirectory) == 'function' then
        pcall(function() love.filesystem.createDirectory(repertoireLogs) end)
    else
        -- Commande mkdir compatible Windows, ignore les échecs
        pcall(function() os.execute('mkdir "' .. repertoireLogs .. '"') end)
    end
end)

-- Exposition du chemin de session et activation de l'écriture immédiate par défaut (configurable)
globalFunction.log = globalFunction.log or {}
globalFunction.log._sessionPath = cheminSession
globalFunction.log.immediateWrite = (config.logs.immediateWrite == nil) and true or config.logs.immediateWrite



-- =====================================================================
-- ANIMATION ET INTERPOLATION
-- =====================================================================

--- Interpolation stable (corrige les tremblements / oscillations)
-- @param a table {x, y} : Position actuelle
-- @param b table {x, y} : Position cible
-- @param vitesse number : Vitesse d'interpolation (ex: 10). Multipliée par dt si disponible
-- @return boolean : True si un mouvement a eu lieu
globalFunction.lerp = function(a, b, vitesse)
    -- Sécurité des tables
    a.x = a.x or 0
    a.y = a.y or 0
    b.x = b.x or 0
    b.y = b.y or 0

    local dt = (rawget(_G, "Delta") or 0.016)
    local coefficient = (vitesse or 10) * dt
    if coefficient > 1 then coefficient = 1 end

    -- Epsilon pour arrêter proprement sans jitter
    local EPSILON = 0.5
    local mouvement = false

    -- Axe X
    local dx = b.x - a.x
    if math.abs(dx) <= EPSILON then
        if a.x ~= b.x then
            a.x = b.x
            mouvement = true
        end
    else
        a.x = a.x + dx * coefficient
        mouvement = true
    end

    -- Axe Y
    local dy = b.y - a.y
    if math.abs(dy) <= EPSILON then
        if a.y ~= b.y then
            a.y = b.y
            mouvement = true
        end
    else
        a.y = a.y + dy * coefficient
        mouvement = true
    end

    return mouvement
end

--- Interpolation numérique simple pour valeurs scalaires
-- @param a number : Valeur actuelle
-- @param b number : Valeur cible
-- @param t number : Facteur d'interpolation (0 à 1)
-- @return number : Valeur interpolée
globalFunction.lerpNum = function(a, b, t)
    return a + (b - a) * math.max(0, math.min(1, t))
end

-- =====================================================================
-- GESTION DE LA SOURIS
-- =====================================================================

globalFunction.mouse = {}
local verrouClic = false

--- Détection de survol robuste, gère les échelles partielles
-- @param x number : Position X
-- @param y number : Position Y
-- @param largeur number : Largeur
-- @param hauteur number : Hauteur
-- @param echelle table|number : Échelle {x, y} ou nombre
-- @return boolean : True si la souris survole
globalFunction.mouse.hover = function(x, y, largeur, hauteur, echelle)
    local echelleX, echelleY = 1, 1
    if type(echelle) == "table" then
        echelleX = echelle.x or echelle[1] or 1
        echelleY = echelle.y or echelle[2] or 1
    elseif type(echelle) == "number" then
        echelleX = echelle
        echelleY = echelle
    end
    local function obtenirCurseur()
        local okc, curseur = pcall(require, "libreria/tools/inputInterface")
        if okc and curseur and curseur.get then return curseur.get() end
        return 0, 0
    end
    local sourisX, sourisY = obtenirCurseur()
    return (sourisX >= x and sourisX <= x + largeur * echelleX and sourisY >= y and sourisY <= y + hauteur * echelleY)
end

--- Clic en front-edge (compatible avec l'existant)
-- @return boolean|nil : True uniquement lors de la première pression
globalFunction.mouse.click = function()
    local enfonce = false
    local okInp, gestionnaireEntree = pcall(require, "libreria/tools/inputManager")
    if okInp and gestionnaireEntree and gestionnaireEntree.state then
        local etat = gestionnaireEntree.state()
        enfonce = (etat == 'pressed' or etat == 'held')
    else
        local okI, interface = pcall(require, "libreria/tools/inputInterface")
        if okI and interface and interface.isActionDown then
            enfonce = interface.isActionDown()
        else
            enfonce = false
        end
    end
    if enfonce and not verrouClic then
        verrouClic = true
        return true -- Front-edge (pression)
    elseif not enfonce and verrouClic then
        -- Fin du clic : relâche le verrou mais ne renvoie rien
        verrouClic = false
        return nil -- Évite de renvoyer false
    end
    return nil
end

--- États de clic (pressed/held/released/idle)
-- @return string : État actuel
globalFunction.mouse.state = function()
    local enfonce = false
    local okInp, gestionnaireEntree = pcall(require, "libreria/tools/inputManager")
    if okInp and gestionnaireEntree and gestionnaireEntree.state then
        local etat = gestionnaireEntree.state()
        if etat == 'pressed' or etat == 'held' then enfonce = true end
    else
        local okI, interface = pcall(require, "libreria/tools/inputInterface")
        if okI and interface and interface.isActionDown then
            enfonce = interface.isActionDown()
        else
            enfonce = false
        end
    end
    if enfonce and not verrouClic then
        verrouClic = true
        return "pressed"
    elseif enfonce and verrouClic then
        return "held"
    elseif not enfonce and verrouClic then
        verrouClic = false
        return "released"
    else
        return "idle"
    end
end

--- Bouton souris pressé (front-edge)
-- @return boolean : True uniquement lors de la première pression
globalFunction.mouse.justPressed = function()
    local etat = globalFunction.mouse.state()
    return etat == "pressed"
end

--- Bouton souris relâché (front-edge)
-- @return boolean : True uniquement lors de la première relâche
globalFunction.mouse.justReleased = function()
    local etat = globalFunction.mouse.state()
    return etat == "released"
end



-- =====================================================================
-- MANIPULATION DE TABLES
-- =====================================================================

--- Copie profonde d'une table
-- @param original table : Table d'origine
-- @param vues table : Table pour suivre les références circulaires (optionnel)
-- @return table : Nouvelle table clonée
local function clonerTable(original, vues)
    if type(original) ~= "table" then
        return original
    end
    if vues and vues[original] then
        return vues[original]
    end

    local copie = {}
    vues = vues or {}
    vues[original] = copie

    for cle, valeur in pairs(original) do
        copie[clonerTable(cle, vues)] = clonerTable(valeur, vues)
    end

    return setmetatable(copie, getmetatable(original))
end

-- Exposition du clone via le module
globalFunction.clone = clonerTable

-- Assure la compatibilité avec le code legacy utilisant table.clone
if type(table) == 'table' and type(table.clone) ~= 'function' then
    table.clone = clonerTable
end

-- =====================================================================
-- LOGGING CENTRALISÉ
-- =====================================================================

-- Configuration des logs
globalFunction.log.maxEntries = config.logs.maxEntries or 200
globalFunction.log.show = false -- Bascule on/off
globalFunction.log.entries = {} -- Buffer circulaire

local NIVEAU = { OK = 0, INFO = 1, WARN = 2, ERROR = 3 }
local NOM_NIVEAU = { [0] = "OK", [1] = "INFO", [2] = "WARN", [3] = "ERROR" }
local COULEUR_NIVEAU = {
    [0] = { 1, 1, 1 },       -- OK = blanc
    [1] = { 0.6, 0.9, 0.6 }, -- INFO = verdâtre
    [2] = { 1, 0.65, 0 },    -- WARN = orange
    [3] = { 1, 0.2, 0.2 }    -- ERROR = rouge
}

--- Ajoute une entrée de log
-- @param niveau number : Niveau de log (0=OK, 1=INFO, 2=WARN, 3=ERROR)
-- @param texte string : Texte du message
local function pousserLog(niveau, texte)
    local info = debug.getinfo(3, "nSl") or {}
    local source = tostring(info.short_src or info.source or "?")
    local fonction = tostring(info.name or "?")
    local entree = { t = os.time(), niveau = niveau, texte = tostring(texte), source = source, fonction = fonction }
    table.insert(globalFunction.log.entries, entree)
    -- Tronque si nécessaire
    if #globalFunction.log.entries > globalFunction.log.maxEntries then
        table.remove(globalFunction.log.entries, 1)
    end
    -- Affiche aussi dans la console
    local prefixe = string.format("[%s][%s:%s] ", NOM_NIVEAU[niveau], source, fonction)
    if niveau == NIVEAU.ERROR then
        print(prefixe .. "ERROR: " .. tostring(texte))
    else
        print(prefixe .. tostring(texte))
    end
    -- Écriture immédiate dans le fichier de session si configuré
    if globalFunction.log and globalFunction.log.immediateWrite and globalFunction.log._sessionPath then
        local okf, fh = pcall(function()
            return io.open(globalFunction.log._sessionPath, "a")
        end)
        if okf and fh then
            pcall(function()
                local heure = os.date('%Y-%m-%d %H:%M:%S', entree.t)
                local ligne = string.format("%s [%s] [%s:%s] %s\n", heure, NOM_NIVEAU[niveau], source, fonction,
                    tostring(texte))
                fh:write(ligne)
                fh:close()
            end)
        end
    end
end

--- Log OK
-- @param texte string : Message à logger
globalFunction.log.ok = function(texte) pousserLog(NIVEAU.OK, texte) end

--- Log INFO
-- @param texte string : Message à logger
globalFunction.log.info = function(texte) pousserLog(NIVEAU.INFO, texte) end

--- Log WARN
-- @param texte string : Message à logger
globalFunction.log.warn = function(texte) pousserLog(NIVEAU.WARN, texte) end

--- Log ERROR
-- @param texte string : Message à logger
globalFunction.log.error = function(texte) pousserLog(NIVEAU.ERROR, texte) end

--- Vide les logs
globalFunction.log.clear = function() globalFunction.log.entries = {} end

--- Bascule l'affichage des logs
globalFunction.log.toggle = function() globalFunction.log.show = not globalFunction.log.show end

--- Dessine les logs à l'écran
-- @param options table : Options d'affichage {x, y, w, h, bg, lineHeight}
globalFunction.drawLogs = function(options)
    options = options or {}
    if not globalFunction.log.show then return end

    -- Préfère la résolution de jeu si disponible
    local ecran = rawget(_G, 'screen')
    local largeurJeu = (ecran and ecran.gameReso and ecran.gameReso.width) or 800
    local hauteurJeu = (ecran and ecran.gameReso and ecran.gameReso.height) or 600

    local x = options.x or 10
    local y = options.y or 40
    local w = options.w or (largeurJeu - 20)
    local h = options.h or math.min(300, hauteurJeu - y - 20)
    local bg = options.bg or { 0, 0, 0, 0.6 }

    love.graphics.push()
    -- Fond
    love.graphics.setColor(bg)
    love.graphics.rectangle("fill", x - 6, y - 6, w + 12, h + 12)
    love.graphics.setColor(1, 1, 1)

    -- Police mise en cache pour les logs
    globalFunction._logFont = globalFunction._logFont or res.font(16)
    local policeAncienne = love.graphics.getFont()
    love.graphics.setFont(globalFunction._logFont)

    local hauteurLigne = options.lineHeight or globalFunction._logFont:getHeight()
    local lignesMax = math.floor(h / hauteurLigne)
    local debut = math.max(1, #globalFunction.log.entries - lignesMax + 1)
    local idx = 0
    for i = debut, #globalFunction.log.entries do
        idx = idx + 1
        local e = globalFunction.log.entries[i]
        local couleur = COULEUR_NIVEAU[e.niveau] or { 1, 1, 1 }
        love.graphics.setColor(couleur)
        local heure = os.date('%H:%M:%S', e.t)
        local texte = string.format("%s [%s:%s] %s", heure, e.source, e.fonction, e.texte)
        love.graphics.print(texte, x, y + (idx - 1) * hauteurLigne)
    end

    love.graphics.setFont(policeAncienne)
    love.graphics.setColor(1, 1, 1)
    love.graphics.pop()
end

--- Exporte les logs vers un fichier
-- @param chemin string : Chemin du fichier (optionnel, généré automatiquement si nil)
-- @return boolean : True si l'export a réussi
globalFunction.log.exportToFile = function(chemin)
    -- Assure que le répertoire cible existe
    local repertoire = config.logs.dir or "gameLogs"
    pcall(function()
        if type(love) == 'table' and love.filesystem and type(love.filesystem.createDirectory) == 'function' then
            love.filesystem.createDirectory(repertoire)
        end
    end)

    chemin = chemin or (repertoire .. "/" .. "game_logs_" .. os.date("%Y%m%d_%H%M%S") .. ".log")

    -- Supprime les anciens fichiers : garde au plus 10, sinon supprime la moitié la plus ancienne
    local function nettoyerLogsJeu()
        local ok, fichiers
        ok, fichiers = pcall(function()
            local t = {}
            for nomFichier in io.popen('dir "' .. repertoire .. '" /b 2>nul'):lines() do
                table.insert(t, nomFichier)
            end
            return t
        end)
        if not ok or not fichiers then
            -- Fallback : utilise love.filesystem
            if type(love) == 'table' and love.filesystem and type(love.filesystem.getDirectoryItems) == 'function' then
                local succes, elements = pcall(love.filesystem.getDirectoryItems, repertoire)
                if succes and type(elements) == 'table' then fichiers = elements end
            end
        end
        if not fichiers or #fichiers == 0 then return end

        -- Trie par nom (suffixe timestamp supposé) pour obtenir les plus anciens en premier
        table.sort(fichiers)
        local fichiersMax = config.logs.maxFiles or 10
        if #fichiers > fichiersMax then
            local aSupprimer = math.floor(#fichiers / 2)
            for i = 1, aSupprimer do
                local nomFichier = fichiers[i]
                local cheminFichier = repertoire .. "/" .. nomFichier
                pcall(function()
                    os.remove(cheminFichier)
                end)
                -- Fallback avec love.filesystem
                if type(love) == 'table' and love.filesystem and type(love.filesystem.remove) == 'function' then
                    pcall(function() love.filesystem.remove(cheminFichier) end)
                end
            end
        end
    end

    nettoyerLogsJeu()

    -- Essaie io.open d'abord
    local ok, f = pcall(function() return io.open(chemin, "w") end)
    if not ok or not f then
        -- Fallback vers love.filesystem.write
        if type(love) == 'table' and love.filesystem and type(love.filesystem.write) == 'function' then
            local contenu = {}
            for i = 1, #globalFunction.log.entries do
                local e = globalFunction.log.entries[i]
                local heure = os.date('%Y-%m-%d %H:%M:%S', e.t)
                local ligne = string.format("%s [%s] [%s:%s] %s\n", heure, NOM_NIVEAU[e.niveau], e.source, e.fonction,
                    e.texte)
                contenu[#contenu + 1] = ligne
            end
            local concatene = table.concat(contenu)
            local succes, erreur = pcall(function() love.filesystem.write(chemin, concatene) end)
            if succes then
                print("[LOG] exporté " .. tostring(#globalFunction.log.entries) .. " entrées vers " .. tostring(chemin))
                return true
            else
                print("[LOG] impossible d'écrire dans le fichier via love.filesystem: " .. tostring(erreur))
                return false
            end
        end
        print("[LOG] impossible d'ouvrir le fichier en écriture: " .. tostring(chemin))
        return false
    end

    for i = 1, #globalFunction.log.entries do
        local e = globalFunction.log.entries[i]
        local heure = os.date('%Y-%m-%d %H:%M:%S', e.t)
        local ligne = string.format("%s [%s] [%s:%s] %s\n", heure, NOM_NIVEAU[e.niveau], e.source, e.fonction, e.texte)
        f:write(ligne)
    end
    f:close()
    print("[LOG] exporté " .. tostring(#globalFunction.log.entries) .. " entrées vers " .. tostring(chemin))
    return true
end

-- =====================================================================
-- UTILITAIRES MATHÉMATIQUES
-- =====================================================================

--- Force une valeur dans un intervalle [min, max]
-- @param valeur number : Valeur à clamper
-- @param min number : Minimum
-- @param max number : Maximum
-- @return number : Valeur clampée
globalFunction.clamp = function(valeur, min, max)
    return math.max(min, math.min(max, valeur))
end

--- Transforme une valeur d'un intervalle à un autre
-- @param valeur number : Valeur à mapper
-- @param entreeMin number : Min de l'intervalle d'entrée
-- @param entreeMax number : Max de l'intervalle d'entrée
-- @param sortieMin number : Min de l'intervalle de sortie
-- @param sortieMax number : Max de l'intervalle de sortie
-- @return number : Valeur mappée
globalFunction.mapRange = function(valeur, entreeMin, entreeMax, sortieMin, sortieMax)
    local intervalleEntree = entreeMax - entreeMin
    if intervalleEntree == 0 then return sortieMin end
    return sortieMin + (valeur - entreeMin) * (sortieMax - sortieMin) / intervalleEntree
end

--- Clamp delta time : protège contre nil et limite les gros dt
-- @param dt number : Delta time
-- @return number : Dt clampé
globalFunction.clampDt = function(dt)
    if not dt or type(dt) ~= "number" then return 0 end
    return (dt > 0.05) and 0.05 or dt
end

--- Progression sécurisée (évite division par zéro)
-- @param actuel number : Valeur actuelle
-- @param maximum number : Valeur maximale
-- @return number : Progression (0 à 1)
globalFunction.progress = function(actuel, maximum)
    if maximum <= 0 then return 0 end
    return math.max(0, math.min(1, actuel / maximum))
end

--- Distance rapide sans racine carrée (pour comparaisons)
-- @param x1 number : X1
-- @param y1 number : Y1
-- @param x2 number : X2
-- @param y2 number : Y2
-- @return number : Distance au carré
globalFunction.distSqr = function(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return dx * dx + dy * dy
end

-- =====================================================================
-- UTILITAIRES DE TABLES
-- =====================================================================

--- Vérifie si une table contient une valeur
-- @param tbl table : Table à vérifier
-- @param valeur any : Valeur à chercher
-- @return boolean : True si trouvée
globalFunction.contains = function(tbl, valeur)
    if type(tbl) ~= "table" then return false end
    for _, v in pairs(tbl) do
        if v == valeur then return true end
    end
    return false
end

--- Trouve l'index d'une valeur dans une table array
-- @param tbl table : Table array
-- @param valeur any : Valeur à chercher
-- @return number|nil : Index ou nil
globalFunction.indexOf = function(tbl, valeur)
    if type(tbl) ~= "table" then return nil end
    for i = 1, #tbl do
        if tbl[i] == valeur then return i end
    end
    return nil
end

--- Filtre une table avec un prédicat
-- @param tbl table : Table à filtrer
-- @param predicat function : Fonction (valeur, index) -> boolean
-- @return table : Table filtrée
globalFunction.filter = function(tbl, predicat)
    local resultat = {}
    if type(tbl) ~= "table" then return resultat end
    for i, v in ipairs(tbl) do
        if predicat(v, i) then
            table.insert(resultat, v)
        end
    end
    return resultat
end

--- Map une table avec une fonction de transformation
-- @param tbl table : Table à mapper
-- @param transformation function : Fonction (valeur, index) -> nouvelle valeur
-- @return table : Table transformée
globalFunction.map = function(tbl, transformation)
    local resultat = {}
    if type(tbl) ~= "table" then return resultat end
    for i, v in ipairs(tbl) do
        resultat[i] = transformation(v, i)
    end
    return resultat
end

-- =====================================================================
-- UTILITAIRES DE CHAÎNES
-- =====================================================================

--- Split une chaîne sur un délimiteur
-- @param chaine string : Chaîne à splitter
-- @param delimiteur string : Délimiteur (défaut : espaces)
-- @return table : Table des parties
globalFunction.split = function(chaine, delimiteur)
    if type(chaine) ~= "string" then return {} end
    delimiteur = delimiteur or "%s"
    local resultat = {}
    for partie in string.gmatch(chaine, "([^" .. delimiteur .. "]+)") do
        table.insert(resultat, partie)
    end
    return resultat
end

--- Trim les espaces en début/fin
-- @param chaine string : Chaîne à trimmer
-- @return string : Chaîne trimmée
globalFunction.trim = function(chaine)
    if type(chaine) ~= "string" then return "" end
    return chaine:match("^%s*(.-)%s*$")
end

--- Pad une chaîne à gauche ou droite
-- @param chaine string : Chaîne à padder
-- @param longueur number : Longueur cible
-- @param caractere string : Caractère de padding (défaut : espace)
-- @param droite boolean : True pour padding à droite
-- @return string : Chaîne paddée
globalFunction.pad = function(chaine, longueur, caractere, droite)
    chaine = tostring(chaine)
    caractere = caractere or " "
    local padding = string.rep(caractere, math.max(0, longueur - #chaine))
    return droite and (chaine .. padding) or (padding .. chaine)
end

-- =====================================================================
-- UTILITAIRES DE VALIDATION
-- =====================================================================

--- Vérifie si une valeur est un nombre valide
-- @param valeur any : Valeur à vérifier
-- @return boolean : True si nombre valide (pas NaN)
globalFunction.isNumber = function(valeur)
    return type(valeur) == "number" and valeur == valeur -- Exclut NaN
end

--- Vérifie si une table a des champs requis
-- @param tbl table : Table à vérifier
-- @param champs table : Liste des champs requis
-- @return boolean : True si tous présents
globalFunction.hasFields = function(tbl, champs)
    if type(tbl) ~= "table" then return false end
    for _, champ in ipairs(champs) do
        if tbl[champ] == nil then return false end
    end
    return true
end

--- Retourne une valeur par défaut si nil
-- @param valeur any : Valeur à tester
-- @param defaut any : Valeur par défaut
-- @return any : Valeur ou défaut
globalFunction.default = function(valeur, defaut)
    return valeur ~= nil and valeur or defaut
end

-- =====================================================================
-- REQUIRE SÉCURISÉ CENTRALISÉ
-- =====================================================================

--- Require sécurisé avec gestion d'erreur centralisée
-- @param name string : Nom du module à charger
-- @return any : Module chargé ou nil en cas d'erreur
globalFunction._safeRequire = function(name)
    if type(name) ~= "string" or name == "" then
        globalFunction.log.warn("_safeRequire: nom de module invalide '" .. tostring(name) .. "'")
        return nil
    end

    local ok, mod = pcall(require, name)
    if ok then
        -- Log optionnel pour debug (peut être verbeux)
        -- globalFunction.log.info("_safeRequire: module '" .. name .. "' chargé avec succès")
        return mod
    else
        globalFunction.log.warn("_safeRequire: échec du chargement de '" .. name .. "': " .. tostring(mod))
        return nil
    end
end

-- Alias pour compatibilité avec le code existant
globalFunction.safeRequire = globalFunction._safeRequire

-- =====================================================================
-- UTILITAIRES GÉNÉRAUX
-- =====================================================================

--- Debug rapide pour afficher le contenu d'une table
-- @param tbl table : Table à afficher
-- @return string : Représentation string de la table
globalFunction.tstr = function(tbl)
    if type(tbl) ~= "table" then
        return tostring(tbl)
    end
    local parties = {}
    for cle, valeur in pairs(tbl) do
        parties[#parties + 1] = tostring(cle) .. "=" .. tostring(valeur)
    end
    return "{" .. table.concat(parties, ", ") .. "}"
end

--- Appel sécurisé avec log d'erreur
-- @param fn function : Fonction à appeler de manière sécurisée
-- @param ... any : Arguments à passer à la fonction
-- @return any : Résultat de la fonction ou nil en cas d'erreur
globalFunction.safecall = function(fn, ...)
    local status, resultat = pcall(fn, ...)
    if not status then
        globalFunction.log.error("Erreur dans safecall: " .. tostring(resultat))
    end
    return resultat
end

-- Tentative de chargement du gestionnaire d'entrée centralisé et délégation des helpers souris
local ok, gestionnaireEntree = pcall(require, "libreria/tools/inputManager")
if ok and type(gestionnaireEntree) == 'table' then
    globalFunction.mouse = globalFunction.mouse or {}
    globalFunction.mouse.hover = gestionnaireEntree.hover
    globalFunction.mouse.click = gestionnaireEntree.click
    globalFunction.mouse.state = gestionnaireEntree.state
    globalFunction.mouse.justPressed = gestionnaireEntree.justPressed
    globalFunction.mouse.justReleased = gestionnaireEntree.justReleased
    globalFunction.endTurnHotkeys = gestionnaireEntree.endTurnHotkeys
end

-- Alias globaux pour compatibilité (certains scripts utilisent "myFonction")
rawset(_G, "globalFunction", globalFunction)
rawset(_G, "myFunction", globalFunction)
rawset(_G, "myFonction", globalFunction)

-- Initialisation du log
globalFunction.log.info("Logger initialisé")

return globalFunction
