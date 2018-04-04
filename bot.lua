local discordia = require('discordia')
local fs = require('fs')
client = discordia.Client()
keyfile = args[2]

client:on('ready', function()
    blocked = false
    client:setUsername("BooksAndTea-Bot")
    print('Logged in as ' .. client.user.username .. '\n')
end)

local messQueue = {} -- List of messages still to be handled
local optionList = {} -- List {"command", func} of all commands and corresponding functions

local function funstuff(message)
    -- I LOVE BUTBOTT
    if message.author.name == "Buttbot" then
	local r = math.random(5)
        if r == 1 then
                message:addReaction("\xE2\x9D\xA4")
        end
    end

    -- HAUNTING EMMIE :)
    --if message.author.name == "Emmie" then
    --    local r = math.random(50)
    --    if r == 1 then
    --        message:addReaction("\xF0\x9F\x91\xBB")
    --    end
    --end

    -- THIS IS A DRINKING GAME
    if message.channel.mentionString ~= "<#302884873729867777>" then
    -- 302884873729867777 is the id for cosmere channel
	local wordlist = {"sanderson","cosmere"}
        local tosearch = string.lower(message.content)
        for key, val in ipairs(wordlist) do
            str = "%S*"
            val:gsub(".", function(c)
                str = str .. c .. "%S*"
            end)
            result = string.match(tosearch, str)
            if result ~= nil then
		result = string.find(result, "https?://")
		if result ~= 1 then
		    result = 1
                    break
		else
	            result = nil
		end
            end
        end
        if result ~= nil then
	    if message.author.name ~= "Ralthuis" then
                message:addReaction("\xF0\x9F\x8D\xBA")
            end
        end
    end
end

local function checkMessage(message)

    if string.sub(message.content, 0, 1) == '!' then
        local option, content = string.match(message.content, "(%g*)%s?(.*)", 2)
        if option ~= nil and content ~= nil then
            if optionList[option] ~= nil then
                date, time = string.match(message.timestamp, "(%d+-%d+-%d+)T(%d+:%d+:%d+)")
                print("[" .. time .. " " .. date .. "] command: " .. option .. ", author: " .. message.author.name .. ", content: " .. content)
                if optionList[option].isOn == true then
                    return true, option, content
                else
                    print('     Ignoring Command: disabled')
                    print('end')
                end
            end
        end
    end

    return false
end

--searches messages for command and call corresponding handler if a command is found
function create(message)
    message._handler = create

    ok, option, content = checkMessage(message)

    if ok then
        --Make sure we don't handle multiple messages at once by adding them to a queue while the handler is blocked
        if blocked == false then
            blocked = true
            client:emit(option..'RUN', message, content)
        else
            table.insert(messQueue, 1, message)
        end
    end
    funstuff(message)
end

function delete(message)
    message._handler = delete

    ok, option, content = checkMessage(message)

    if ok then
        --Make sure we don't handle multiple messages at once by adding them to a queue while the handler is blocked
        if blocked == false then
            blocked = true
            date, time = string.match(message.timestamp, "(%d+-%d+-%d+)T(%d+:%d+:%d+)")
            print("[" .. time .. " " .. date .. "] command: " .. option .. ", author: " .. message.author.name .. ", content: " .. content)
            print("    DELETED")
	    if optionList[option].del ~= nil then
                client:emit(option..'DEL', message, content)
            else
                client:emit("messageFinished");
            end
        else
            table.insert(messQueue, 1, message)
        end
    end
end

function update(message)
    message._handler = update

    ok, option, content = checkMessage(message)

    if ok then
        if blocked == false then
            blocked = true
            date, time = string.match(message.timestamp, "(%d+-%d+-%d+)T(%d+:%d+:%d+)")
            print("[" .. time .. " " .. date .. "] command: " .. option .. ", author: " .. message.author.name .. ", content: " .. content)
            print("    UPDATED")
            if optionList[option].update ~= nil then
                client:emit(option..'UPDATE', message, content)
            else
                client:emit("messageFinished");
            end
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
        mess._handler(mess)
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
            cmdObj = require('./commands/' .. v).init(client)

            if cmdObj.trigger == nil then
                print('    Warning: no trigger specified')
                cmdObj.trigger = command
            end

            print('    found command: ' .. cmdObj.trigger .. ', isOn: ' .. tostring(cmdObj.isOn))

            if cmdObj.run ~= nil then
                client:on(cmdObj.trigger .. 'RUN', cmdObj.run)
            end

            if cmdObj.del ~= nil then
                client:on(cmdObj.trigger .. 'DEL', cmdObj.del)
            end

            if cmdObj.update ~= nil then
                client:on(cmdObj.trigger .. 'UPDATE', cmdObj.update)
            end

            optionList[cmdObj.trigger] = cmdObj
        end
    end
    print('end\n')
end

-- start bot using key read from the file
local function startBot(err, file)

    print('starting bot')
    if err ~= nil then
        print(err)
        return
    end

    client:run('Bot ' .. file)
end

fs.readdir('./commands', setupCommands)
fs.readFile(keyfile, startBot)

