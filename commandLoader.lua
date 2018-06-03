local optionList = {}
local triggers = {}
local pathjoin = require("pathjoin")
local fs = require("fs")

local function pcallFunctionWrapper(f, ...)
     status, err = pcall(f, ...)
     if not status then
         print("    ", err)
         client:emit("messageFinished")

     end
end

local function loadModule(path, ...)
    local name= table.remove(pathjoin.splitPath(args[1])):match('(.*).lua')
    local arg = {...}

    local status, res = pcall(function()
        local code = assert(fs.readFileSync(path))

        local env = setmetatable({
            require = require, -- luvit custom require
        }, {__index = _G})
        local func = assert(loadstring(code, "@"..name, 't', env))
        return func(unpack(arg))
    end)
    return status, res
end

local function loadCommand(filename)
        local command = string.match(filename, '(.-).lua')
        if command ~= nil then
            print('    found command: ' .. filename)
            local status, cmdObj = loadModule('./commands/' .. filename)
            if status then
                if cmdObj.trigger == nil then
                    print('        Warning: no trigger specified using default..')
                    cmdObj.trigger = command
                end
                print('        Trigger: '.. cmdObj.trigger)

                if triggers[filename] then
                    print('    Command already loaded, replacing')
                    client:removeListener(triggers[filename], pcallFunctionWrapper)
                    optionList[triggers[filename]] = nil
                    for k, v in pairs(trackedMessages) do
                        v[triggers[filename]] = nil
                    end
                end

                client:on(cmdObj.trigger, pcallFunctionWrapper)
                triggers[filename] = cmdObj.trigger
                optionList[cmdObj.trigger] = cmdObj
            else
                print(status, cmdObj)
            end
        end
end

--Search commands folder for .lua files and load them into optionList
local function setupCommands(err, file)
    print('loading commands')
    if err ~= nil then
        print(err)
        return
    end

    for k,v in pairs(file) do
        loadCommand(v)
    end

    print('end\n')

end

return {
    loadCommand = loadCommand,
    setupCommands = setupCommands,
    optionList = optionList
}
