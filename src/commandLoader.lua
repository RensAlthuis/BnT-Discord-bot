local pathLib = require("path")
local fs = require("fs")
local _settings = {}
local modules = {}
local moduleLoader = require('./util/moduleLoader.lua')

local env = {
            log = log,
            print = print,
            require = require,
            client = client,
            tostring = tostring,
            error = error,
}

local function start(settings)
    _settings = settings
    env.emitter = settings.emitter
    if settings.folder then

        modules = moduleLoader.loadFolder(settings.folder, env)
        for k, v in pairs(modules) do
            log.print(3, "Starting:", k)
            local status, err = pcall(v.start)
            if status == false then
                log.err(0, err)
            end
        end
    end
end

local function loadCommand(path)
    local filename = pathLib.basename(path, "")
    log.info(0, "Loading module:", filename)

    local mod = moduleLoader.load(path, env)
    if mod == nil then
        return false
    end

    if modules[filename] then
        log.print(3, "Module already loaded..")
        log.print(3, "stopping old command module")
        modules[filename].stop()
    end

    log.print(3, "starting new command module")
    mod.start()
    modules[filename] = mod

    log.print(2, "End")
    return true
end

return {
    start = start,
    loadCommand = loadCommand
}
