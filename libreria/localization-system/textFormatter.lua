-- =========================================================================
-- TEXT FORMATTER - Formatage Textes avec Variables
-- =========================================================================
-- Auteur: GitHub Copilot
-- Date: 2 septembre 2025
-- Description: Système avancé de formatage de textes avec variables et pluriels
-- =========================================================================

local textFormatter = {}

-- =========================================================================
-- CONFIGURATION
-- =========================================================================

-- Patterns de remplacement
local VARIABLE_PATTERN = "{([^}]+)}"
local PLURAL_PATTERN = "{([^|]+)|([^|]+)|([^}]+)}"         -- {singular|plural|count}
local CONDITIONAL_PATTERN = "{if:([^:]+):([^:]*):([^}]*)}" -- {if:condition:true_text:false_text}

-- =========================================================================
-- FORMATAGE DE BASE
-- =========================================================================

-- Formatage simple avec variables
function textFormatter.format(text, variables)
    if not text or type(text) ~= "string" then
        return text or ""
    end

    if not variables or type(variables) ~= "table" then
        return text
    end

    local result = text

    -- Remplacer toutes les variables {nom}
    result = result:gsub(VARIABLE_PATTERN, function(varName)
        local value = variables[varName]
        if value ~= nil then
            return tostring(value)
        else
            -- Conserver la variable si non trouvée pour debug
            return "{" .. varName .. "}"
        end
    end)

    return result
end

-- =========================================================================
-- FORMATAGE AVANCÉ AVEC PLURIELS
-- =========================================================================

-- Formatage avec gestion des pluriels
function textFormatter.formatWithPlurals(text, variables)
    if not text or type(text) ~= "string" then
        return text or ""
    end

    if not variables or type(variables) ~= "table" then
        return text
    end

    local result = text

    -- D'abord gérer les pluriels
    result = result:gsub(PLURAL_PATTERN, function(singular, plural, countVar)
        local count = variables[countVar]
        if count and type(count) == "number" then
            if count <= 1 then
                return singular
            else
                return plural
            end
        else
            -- Fallback au singulier si count non trouvé
            return singular
        end
    end)

    -- Puis formatage normal des variables
    result = textFormatter.format(result, variables)

    return result
end

-- =========================================================================
-- FORMATAGE CONDITIONNEL
-- =========================================================================

-- Formatage avec conditions
function textFormatter.formatWithConditions(text, variables)
    if not text or type(text) ~= "string" then
        return text or ""
    end

    if not variables or type(variables) ~= "table" then
        return text
    end

    local result = text

    -- Gérer les conditions {if:variable:true_text:false_text}
    result = result:gsub(CONDITIONAL_PATTERN, function(condVar, trueText, falseText)
        local condition = variables[condVar]
        if condition then
            return trueText or ""
        else
            return falseText or ""
        end
    end)

    -- Puis formatage avec pluriels et variables
    result = textFormatter.formatWithPlurals(result, variables)

    return result
end

-- =========================================================================
-- FORMATAGE SPÉCIALISÉ POUR CARTES
-- =========================================================================

-- Formatage spécialisé pour descriptions de cartes
function textFormatter.formatCardDescription(text, cardData, variables)
    if not text or not cardData then
        return text or "[INVALID_CARD_DATA]"
    end

    -- Combiner données carte avec variables externes
    local allVariables = variables or {}

    -- Ajouter données automatiques de la carte
    if cardData.PowerBlow then
        allVariables.damage = cardData.PowerBlow
    end

    if cardData.cost or cardData.PowerBlow then
        allVariables.cost = cardData.cost or cardData.PowerBlow
    end

    if cardData.multiTarget then
        allVariables.target = "tous les ennemis"
        allVariables.target_en = "all enemies"
    else
        allVariables.target = "un ennemi"
        allVariables.target_en = "an enemy"
    end

    -- Ajouter effets spécifiques
    if cardData.Effect then
        if cardData.Effect.target then
            if cardData.Effect.target.attack then
                allVariables.attack = cardData.Effect.target.attack
            end
            if cardData.Effect.target.heal then
                allVariables.heal = cardData.Effect.target.heal
            end
        end

        if cardData.Effect.caster then
            if cardData.Effect.caster.heal then
                allVariables.self_heal = cardData.Effect.caster.heal
            end
            if cardData.Effect.caster.shield then
                allVariables.shield = cardData.Effect.caster.shield
            end
        end
    end

    -- Formatage avec toutes les fonctionnalités
    return textFormatter.formatWithConditions(text, allVariables)
end

-- =========================================================================
-- FORMATAGE POUR INTERFACE UTILISATEUR
-- =========================================================================

-- Formatage pour éléments UI avec couleurs
function textFormatter.formatUIText(text, variables, colorTheme)
    if not text then
        return ""
    end

    local result = textFormatter.formatWithConditions(text, variables)

    -- Ajouter couleurs si thème fourni
    if colorTheme then
        -- Pattern pour couleurs: [color:nom]texte[/color]
        result = result:gsub("%[color:([^%]]+)%]([^%[]+)%[/color%]", function(colorName, content)
            local color = colorTheme[colorName]
            if color then
                -- Format RGB hex ou tableau
                if type(color) == "string" then
                    return string.format('<color="%s">%s</color>', color, content)
                elseif type(color) == "table" and #color >= 3 then
                    return string.format('<color="rgb(%d,%d,%d)">%s</color>',
                        color[1] * 255, color[2] * 255, color[3] * 255, content)
                end
            end
            return content -- Fallback sans couleur
        end)
    end

    return result
end

-- =========================================================================
-- UTILITAIRES DE VALIDATION
-- =========================================================================

-- Extraire toutes les variables d'un texte
function textFormatter.extractVariables(text)
    if not text or type(text) ~= "string" then
        return {}
    end

    local variables = {}

    -- Variables simples {nom}
    for varName in text:gmatch(VARIABLE_PATTERN) do
        variables[varName] = true
    end

    -- Variables dans pluriels
    text:gsub(PLURAL_PATTERN, function(singular, plural, countVar)
        variables[countVar] = true
    end)

    -- Variables dans conditions
    text:gsub(CONDITIONAL_PATTERN, function(condVar, trueText, falseText)
        variables[condVar] = true
    end)

    -- Convertir en liste
    local result = {}
    for var, _ in pairs(variables) do
        table.insert(result, var)
    end

    return result
end

-- Valider qu'un texte peut être formaté avec les variables données
function textFormatter.validateFormatting(text, variables)
    if not text then
        return true, {}
    end

    local requiredVars = textFormatter.extractVariables(text)
    local missingVars = {}

    for _, varName in ipairs(requiredVars) do
        if not variables or variables[varName] == nil then
            table.insert(missingVars, varName)
        end
    end

    return #missingVars == 0, missingVars
end

-- =========================================================================
-- FORMATAGE SÉCURISÉ
-- =========================================================================

-- Formatage avec gestion d'erreur
function textFormatter.safeFormat(text, variables, options)
    local success, result = pcall(function()
        options = options or {}

        if options.useConditions then
            return textFormatter.formatWithConditions(text, variables)
        elseif options.usePlurals then
            return textFormatter.formatWithPlurals(text, variables)
        else
            return textFormatter.format(text, variables)
        end
    end)

    if success then
        return result
    else
        -- En cas d'erreur, retourner texte original avec indication d'erreur
        if _G.globalFunction and _G.globalFunction.log then
            _G.globalFunction.log.error("Erreur formatage texte: " .. tostring(result))
        end

        return text or "[FORMAT_ERROR]"
    end
end

-- =========================================================================
-- HELPERS POUR INTÉGRATION
-- =========================================================================

-- Formatage rapide pour système de localisation
function textFormatter.quickFormat(text, ...)
    local variables = {}
    local args = { ... }

    -- Support multiple signatures:
    -- quickFormat(text, {variables})
    -- quickFormat(text, key1, value1, key2, value2, ...)
    if #args == 1 and type(args[1]) == "table" then
        variables = args[1]
    else
        -- Convertir paires clé-valeur en table
        for i = 1, #args, 2 do
            if args[i] and args[i + 1] then
                variables[args[i]] = args[i + 1]
            end
        end
    end

    return textFormatter.safeFormat(text, variables, { useConditions = true })
end

-- =========================================================================
-- EXPORT DU MODULE
-- =========================================================================

return textFormatter
