local log = require("log")

local function loadModule(path, env)
    local chunk, err = loadfile(path, 'bt', env)
    if chunk == nil then
        log.print(0, "[ERR} couldn't load module", path)
        log.print(1, "error message:", err)
        return nil
    end
    chunk()
    return env
end

--Search commands folder for .lua files and load them into optionList
local function loadFolder(path, env)
    if err ~= nil then
        print(err)
        return
    end
    local modules = {}
    for k,v in pairs(file) do
        local mod = loadModule(path .. '/' .. file, env)
        if mod ~= nil then
            modules[v] = mod
        end
    end

    return modules
end

return {
    load = load,
    loadFolder = loadFolder
}