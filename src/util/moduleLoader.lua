local fs = require('fs')

local function load(path, env)
    local chunk, err = loadfile(path, 'bt', env)
    if chunk == nil then
        log.err(0, "couldn't load module:", path)
        log.print(2, "error message:", err)
        return nil
    end
    local status, err = pcall(chunk)
    if status == false then
        log.err(0, "couldn't execute module:", path)
        log.print(2, "error message:", err)
        return nil
    end
    return env
end

--Search commands folder for .lua files and load them into optionList
local function loadFolder(path, env)
    if fs.existsSync(path) == false then
        log.err(0, "non exitent path: " .. path)
        return {}
    end

    local files = fs.readdirSync(path)
    if err ~= nil then
        log.err(0, err)
    end

    local modules = {}
    for k,v in pairs(files) do
        local mod = load(path .. '/' .. v, env)
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