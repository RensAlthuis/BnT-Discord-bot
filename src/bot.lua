local fs = require('fs')
local keyfile = args[2]

--[[
Loading discordia framework
temporarily overwrites stdout so discordia won't flood it with messages
alternative is setting logLevel to 0 but that would prevent the logfile from being created aswell
and I do want to save those messages somewhere
--]]
local stdout = process.stdout.handle
process.stdout.handle = fs.createWriteStream('/dev/null', {flags = 'a'})
_G.discordia = require('discordia')
_G.client = discordia.Client { cacheAllMembers = true, }
_G.log = require('./util/log.lua')("main.log")
process.stdout.handle = stdout

--[[
start bot using key read from the file
]]
local function startBot(err, key)

    log.print(0, "")
    log.print(0, "")
    log.print(0, "")
    log.print(0, "")
    log.info(0, "BOOTING...")

    log.info(0, "Setting up TUI")
    local ui = require('./userInputHandler.lua')
    process.stdin:on("data", ui.onInput)

    log.info(0,'Starting Discordia client')
    client:run('Bot ' .. key)
end

client:on('ready', function()
    log.info(0, 'Client Ready')
    client:setUsername("BooksAndTea-Bot")
    print(2, 'Logged in as: ' .. client.user.username .. '\n')

    -- print('loading commands')
    --fs.readdir('./commands', commandLoader.setupCommands)
end)

fs.readFile(keyfile, startBot)

-- local commandLoader = require("./commandLoader.lua")
--local mH = require('messageHandler').init(commandLoader.optionList)
--_G.trackedMessages = mH.trackedMessages
--if err ~= nil then
    --print(err)
    --return
--end