local discordia = require('discordia')
local fs = require('fs')
client = discordia.Client()
keyfile = args[2]

client:on('ready', function()
    blocked = false
	print('Logged in as ' .. client.user.username .. '\n')
end)

local messQueue = {} -- List of messages still to be handled
local optionList = {} -- List {"command", func} of all commands and corresponding functions

local function checkMessage(message)

    if string.sub(message.content, 0, 1) == '!' then
        local option, content = string.match(message.content, "(%g*)%s?(.*)", 2)
        if option ~= nil and content ~= nil then
            if optionList[option] ~= nil then
                if optionList[option].isOn == true then
                    return true, option, content
                end
            end
        end
    end

    return false
end

--searches messages for command and call corresponding handler if a command is found
function create(message)
    message.handler = create

    ok, option, content = checkMessage(message)

    if ok then
        --Make sure we don't handle multiple messages at once by adding them to a queue while the handler is blocked
        if blocked == false then
            blocked = true
            date, time = string.match(message.timestamp, "(%d+-%d+-%d+)T(%d+:%d+:%d+)")
            print("[" .. time .. " " .. date .. "] command: " .. option .. ", author: " .. message.author.name .. ", content: " .. content)
            client:emit(option..'RUN', message, content)
        else
            table.insert(messQueue, 1, message)
        end
    end
end

function delete(message)
    message.handler = delete

    ok, option, content = checkMessage(message)

    if ok then
        --Make sure we don't handle multiple messages at once by adding them to a queue while the handler is blocked
        if blocked == false then
            blocked = true
            date, time = string.match(message.timestamp, "(%d+-%d+-%d+)T(%d+:%d+:%d+)")
            print("[" .. time .. " " .. date .. "] command: " .. option .. ", author: " .. message.author.name .. ", content: " .. content)
            print("    DELETED")
            client:emit(option..'DEL', message, content)
        else
            table.insert(messQueue, 1, message)
        end
    end
end

function update(message)
    message.handler = update

    ok, option, content = checkMessage(message)

    if ok then
        if blocked == false then
            blocked = true
            date, time = string.match(message.timestamp, "(%d+-%d+-%d+)T(%d+:%d+:%d+)")
            print("[" .. time .. " " .. date .. "] command: " .. option .. ", author: " .. message.author.name .. ", content: " .. content)
            print("    UPDATED")
            client:emit(option..'UPDATE', message, content)
        else
            table.insert(messQueue, 1, message)
        end
    end
end
--Unblocks the messageHandler and if necessary calls the next message in the queue
function messageFinished()
    print("end \n")
    blocked = false
    mess = table.remove(messQueue)
    if mess ~= nil then
        mess.handler(mess)
    end
end

client:on('messageDelete', delete)
client:on('messageUpdate', update)
client:on('messageCreate', create)
client:on('messageFinished', messageFinished)

--Search commands folder for .lua files and load them into optionList
local function setupCommands(err, file)
    print('loading commands')
    if err ~= nil then
        print(err)
        return
    end

    for k,v in pairs(file) do

        local command = string.match(v, '(.-).lua')
	if command ~= nil then
		optionList[command] = require('./commands/' .. v).init(client)
		print('    found command: ' .. command .. ', isOn: ' .. tostring(optionList[command].isOn))

		--set listeners for all commands in optionsList
		if optionList[command].isOn == true then
            if optionList[command].run ~= nil then
                client:on(command .. 'RUN', optionList[command].run)
            end

            if optionList[command].del ~= nil then
                client:on(command .. 'DEL', optionList[command].del)
            end

            if optionList[command].update ~= nil then
                client:on(command .. 'UPDATE', optionList[command].update)
            end
		end
	end
    end
    print('end\n')
end

fs.readdir('./commands', setupCommands)

-- start bot using key read from the file
local function startBot(err, file)

    print('starting bot')
    if err ~= nil then
        print(err)
        return
    end

    client:run(file)
end

fs.readFile(keyfile, startBot)

