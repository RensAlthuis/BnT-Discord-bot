local fs = require('fs')

-- loading discordia
-- temporarily overwrite stdout so discordia won't flood it with messages
-- alternative is setting logLevel to 0 but I do really want to save those messages somewhere
local stdout = process.stdout.handle
process.stdout.handle = fs.createWriteStream('/dev/null', {flags = 'a'})
_G.discordia = require('discordia')
_G.client = discordia.Client { cacheAllMembers = true, }
_G.log = require('./util/log.lua')
process.stdout.handle = stdout

local keyfile = args[2]

local ui = require('./userInputHandler.lua')
local commandLoader = require("./commandLoader.lua")

-- start bot using key read from the file
local function startBot(err, key)

    log.print('starting bot')

    --local mH = require('messageHandler').init(commandLoader.optionList)
    --_G.trackedMessages = mH.trackedMessages
--
    --if err ~= nil then
        --print(err)
        --return
    --end

    -- client:run('Bot ' .. key)
end

--client:on('ready', function()
    --print('loading commands')
    --fs.readdir('./commands', commandLoader.setupCommands)
    --client:setUsername("BooksAndTea-Bot")
    --print('Bot ready, Logged in as ' .. client.user.username .. '\n')
--end)

fs.readFile(keyfile, startBot)
process.stdin:on("data", ui.onInput)