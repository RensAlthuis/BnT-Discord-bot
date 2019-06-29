local fs = require('fs')
local moduleLoader = require('./util/moduleLoader.lua')
local modules = {}

local function onInput(...)
    local option, content = string.match(..., "(%g*)%s?(.*)\n", 1)
    if modules[option] then
        modules[option](content)
    end
end

modules = moduleLoader.loadFolder("src/ui_commands", {})

return {onInput = onInput}
