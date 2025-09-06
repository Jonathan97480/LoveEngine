--[[ -- Central cursor helper
local M = {}

function M.get()
    local input = require("libreria/tools/inputInterface")
    local _globalFunction = require("libreria/tools/globalFunction")

    if not input then
        _globalFunction.log.error("[cursor.lua] Cursor input interface is not available")
        return 0, 0
    end

    if input == nil or input.getCursor == nil then
        _globalFunction.log.error("[cursor.lua] Cursor input interface is not available")
        return 0, 0
    end

    local m = input.getCursor()
    return m.x, m.y
end

return M
 ]]
