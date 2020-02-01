local fs = require('fs')
local libpath = require('path')

local xml = require('xmlSimple.lua').newParser()

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--[[
    load lua file with a sandboxed environment
    returns the new environment as module

    TODO: maybe give some default functions/variables that every module might need to the environment
]]
local function load(path, environment)
    local env = shallowcopy(environment)
    env._G = _G
    env.pairs = pairs
    env.string = string

    local stat = fs.statSync(path)
    if not stat then
        log.err(0, "non existent path: " .. path)
        return nil
    end

    if stat.type == "directory" then
        env.PATH = path .. "/"
        path = path .. "/init.lua"
    else
        env.PATH = libpath.dirname(path) .. "/"
    end

    local chunk, err = loadfile(path, 'bt', env)
    if not chunk then
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

--[[
    Load a folder by calling moduleLoader:Load() on each subfolder.
    This is not a recursive function.
    returns a table where
        key:filename
        value:module
]]
local function loadFolder(path, env)
    if fs.existsSync(path) == false then
        log.err(0, "non exitent path: " .. path)
        return {}
    end

    local files, err = fs.readdirSync(path)
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