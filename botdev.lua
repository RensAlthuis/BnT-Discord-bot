local discordia = require('discordia')
local fs = require('fs')
--local https = require('https')
client = discordia.Client()
--local xml = require("xmlSimple.lua").newParser()
--local timer = require('timer')

client:on('ready', function()
    blocked = false
	print('Logged in as ' .. client.user.username .. '\n')
end)

local messQueue = {} -- List of messages still to be handled
local optionList = {} -- List {"command", func} of all commands and corresponding functions

--searches messages for command and call corresponding handler if a command is found
function handleMessage(message)

    if string.sub(message.content, 0, 1) == '!' then
        local option, content = string.match(message.content, "(%g*)%s?(.*)", 2)
        if option ~= nil and content ~= nil then
            if optionList[option] ~= nil then
                if optionList[option].isOn == true then
                    --Make sure we don't handle multiple messages at once by adding them to a queue while the handler is blocked
                    if blocked == false then
                        blocked = true
                        date, time = string.match(message.timestamp, "(%d+-%d+-%d+)T(%d+:%d+:%d+)")
                        print("[" .. time .. " " .. date .. "] command: " .. option .. ", author: " .. message.author.name .. ", content: " .. content)
                        client:emit(option, message, content)
                    else
                        table.insert(messQueue, 1, message)
                    end
                end
            end
        end
    end
end

--Unblocks the messageHandler and if necessary calls the next message in the queue
function messageFinished()
    print("end \n")
    blocked = false
    mess = table.remove(messQueue)
    if mess ~= nil then
        handleMessage(mess)
    end
end

client:on('messageCreate', handleMessage)
client:on('messageFinished', messageFinished)



--[[  START OF COMMANDS SET-UP ]]--
--
local function setupCommands(a, b)
    print('loading commands')
    if a ~= nil then
        print(a)
        return
    end

    for k,v in pairs(b) do

        local command = string.match(v, '(.-).lua')
        optionList[command] = require('./commands/' .. v).init(client)
        print('    found command: ' .. command .. ', isOn: ' .. tostring(optionList[command].isOn))

        --set listeners for all commands in optionsList
        if optionList[command].isOn == true then
            client:on(command, optionList[command].run)
        end
    end
    print('end\n')
end

--optionList["GR"] = {require('./commands/GR.lua').init(client), true}
--optionList["ping"] = {require('./commands/pingpong.lua').init(client), false}
--optionList["giveaway"] = {require('./commands/giveaway.lua').init(client), false}

fs.readdir('./commands', setupCommands)
--[[  END OF COMMAND SET-UP  ]]--

--GR-BOT
client:run('MzM4NzY0MTQzOTgzMTk4MjA4.DFf1KQ.sGv0lQCMu02RZmDRY3LDAJq3E7o')
--BooksandTea-bot
--client:run('MzM5MTQ1NjU2MTgwNDA4MzIw.DFfthw.bERJ0hg5iLTtyhqIM6XW58Lk9Jw')
