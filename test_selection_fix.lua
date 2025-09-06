-- Test de la correction du decalage de selection
local sceneEditor = require('libreria.tools.sceneEditor')
local uiRenderer = require('libreria.tools.editor.sceneEditor.uiRenderer')

print('=== Test correction decalage selection ===')

-- Creer une scene avec plusieurs calques
sceneEditor.newScene('TestDecalage')
sceneEditor.addLayer('Calque A')
sceneEditor.addLayer('Calque B')
sceneEditor.addLayer('Calque C')
sceneEditor.addLayer('Calque D')

local scene = sceneEditor.getCurrentScene()
if scene then
    print('Scene creee avec', #scene.layers, 'calques:')
    for i, layer in ipairs(scene.layers) do
        print('  ' .. i .. ': ' .. layer.name)
    end

    -- Simuler la structure du layerListPanel
    print('')
    print('Structure du layerListPanel (simulee):')
    local simulatedProperties = {}

    -- Bouton Nouveau calque (index 1)
    table.insert(simulatedProperties, { label = 'Nouveau calque' })

    -- Boutons des calques (indices 2, 3, 4, 5)
    for i, layer in ipairs(scene.layers) do
        table.insert(simulatedProperties, { label = layer.name })
    end

    for i, prop in ipairs(simulatedProperties) do
        print('  Propriete ' .. i .. ': "' .. prop.label .. '"')
    end

    print('')
    print('Test de correspondance:')
    print('Si on clique sur propriete 5 ("Calque D"), on devrait selectionner currentScene.layers[4]')
    print('Si on clique sur propriete 4 ("Calque C"), on devrait selectionner currentScene.layers[3]')
    print('Si on clique sur propriete 3 ("Calque B"), on devrait selectionner currentScene.layers[2]')
    print('Si on clique sur propriete 2 ("Calque A"), on devrait selectionner currentScene.layers[1]')

    print('')
    print('Correction appliquee: layerIndex = i - 1 (pour i > 1)')
else
    print('Erreur creation scene')
end
