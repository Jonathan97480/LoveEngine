# Module JSON

## Description
Le module `json.lua` fournit des fonctions pour encoder et décoder des données JSON en Lua. Il supporte l'encodage de tables, chaînes, nombres, booléens et null, ainsi que le décodage de chaînes JSON en tables Lua.

## Fonctions
### `json.encode(val)`
Encode une valeur Lua en chaîne JSON.
- **Paramètres** :
  - `val` : La valeur à encoder (table, string, number, boolean, nil).
- **Retour** : Chaîne JSON.

### `json.decode(str)`
Décode une chaîne JSON en valeur Lua.
- **Paramètres** :
  - `str` : La chaîne JSON à décoder.
- **Retour** : Valeur Lua (généralement une table).

## Exemple d'utilisation
```lua
local json = require("libreria/tools/json")

-- Encoder une table
local data = {name = "John", age = 30}
local jsonStr = json.encode(data)
print(jsonStr)  -- {"name":"John","age":30}

-- Décoder une chaîne JSON
local decoded = json.decode(jsonStr)
print(decoded.name)  -- John
```
