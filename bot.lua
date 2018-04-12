_G.discordia = require('discordia')
_G.client = discordia.Client {
    cacheAllMembers = true
}

local fs = require('fs')

local commandLoader = require("./commandLoader.lua")
local ui = require('./userInputHandler.lua')

local keyfile = args[2]

local function tprint(t)
    if t then
        for k,v in pairs(t) do
            print(k,v)
        end
        print('\n\n')
    else
        print('nil')
    end
end

-- start bot using key read from the file
local function startBot(err, file)

    print('starting bot')
    local mH = require('messageHandler').init(commandLoader.optionList)
    _G.trackedMessages = mH.trackedMessages

    if err ~= nil then
        print(err)
        return
    end

    client:run('Bot ' .. file)
end

client:on('ready', function()
    print('\n')
    fs.readdir('./commands', commandLoader.setupCommands)
    client:setUsername("BooksAndTea-Bot")
    print('Logged in as ' .. client.user.username .. '\n')
end)

fs.readFile(keyfile, startBot)
process.stdin:on("data", ui.userInputHandler)


