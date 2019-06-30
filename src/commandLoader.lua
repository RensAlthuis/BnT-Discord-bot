local pathLib = require("path")
local _settings = {}
local modules = {}

local moduleLoader = require('./util/moduleLoader.lua')
local fs = require("fs")

local function start(settings)
    _settings = settings

    if settings.folder then
        local env = {
            log = log,
            emitter = _settings.emitter,
            print=print
        }

        modules = moduleLoader.loadFolder(settings.folder, env)
        for k, v in pairs(modules) do
            log.print(3, "Starting:", k)
            v.start()
        end
    end

end

local function loadCommand(path)
    local env = {
        log = log,
        emitter = _settings.emitter
    }

    local mod = moduleLoader.loadModule(path, env)
    if mod == nil then
        return false
    end

    local filename = pathLib.basename(path, "")
    if modules[filename] then
        log.info(0, "stopping command module:", filename)
        modules[filename].stop()
    end

    log.info(0, "loading command module:", filename)
    mod.start()
    modules[filename] = mod

    return true
end

return {
    start = start,
    loadCommand = loadCommand
}
