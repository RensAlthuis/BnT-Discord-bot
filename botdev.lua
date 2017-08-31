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

--Search commands folder for .lua files and load them into optionList
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

fs.readdir('./commands', setupCommands)

-- start bot using key read from the file ./key
local function startBot(err, file)

    print('starting bot')
    if a ~= nil then
        print(err)
        return
    end

    client:run(file)
end

fs.readFile('./key', startBot)
