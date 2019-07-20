local pathLib = require("path")
local fs = require("fs")
local _settings = {}
local modules = {}
local env = {}

local moduleLoader = require('./util/moduleLoader.lua')

local function start(settings)
    _settings = settings

    if settings.folder then
        env = {
            log = log,
            emitter = _settings.emitter,
            print = print,
            require = require,
            client = client
        }

        modules = moduleLoader.loadFolder(settings.folder, env)
        for k, v in pairs(modules) do
            log.print(3, "Starting:", k)
            v.start()
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
