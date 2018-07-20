
local messQueue = {} -- List of messages still to be handled
local blocked = false
local trackedMessages = {}

-- Adding some memes to messages
local function funstuff(message)
    -- I LOVE BUTBOTT
    if message.author.name == "Buttbot" then
	local r = math.random(5)
        if r == 1 then
                message:addReaction("\xE2\x9D\xA4")
        end
    end

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
                result = string.find(result, "https?://") -- exlude links
                if result ~= 1 then
                    result = 1
                    break
                else
                    result = nil
                end
            end
        end

        if result ~= nil then
            message:addReaction("\xF0\x9F\x8D\xBA")
        end
    end

    if message.channel.mentionString ~= "<#457246895392292874>" then
        -- 457246895392292874 is the id for Dune channel
        local wordlist = {"dune","arrakis"}
        local tosearch = string.lower(message.content)

        for key, val in ipairs(wordlist) do
            str = "%S*"
            val:gsub(".", function(c)
                str = str .. c .. "%S*"
            end)
            result = string.match(tosearch, str)

            if result ~= nil then
                result = string.find(result, "https?://") -- exlude links
                if result ~= 1 then
                    result = 1
                    break
                else
                    result = nil
                end
            end
        end

        if result ~= nil then
            message:addReaction("\xF0\x9F\xA5\x83")
        end
    end
end

--parses a message then logs and returns the command with its content
local function checkMessage(message)

    if string.sub(message.content, 0, 1) == '!' then
        local option, content = string.match(message.content, "(%g*)%s?(.*)", 2)

        if option ~= nil and content ~= nil then

            if optionList[option] ~= nil then
                date, time = string.match(message.timestamp, "(%d+-%d+-%d+)T(%d+:%d+:%d+)")
                print("[" .. time .. " " .. date .. "] command: " .. option .. ", author: " .. message.author.name .. ", content: " .. content)

                if optionList[option].isOn then
                    return true, option, content
                else
                    print('     Ignoring Command: disabled')
                    print('end\n')
                end
            end
        end
    end

    return false
end

-- When new message is created and checkmessage return true, add the call to the create handler to the queue.
local function create(message)
    message._handler = create
    ok, option, content = checkMessage(message)

    if ok then
        --Make sure we don't handle multiple messages at once by adding them to a queue while the handler is blocked
        if blocked == false then
            blocked = true
            client:emit(option, optionList[option].run, message, content)
        else
            table.insert(messQueue, 1, message)
        end
    end

    funstuff(message)
end

-- When new message is created and checkmessage return true, add the call to the delete handler to the queue.
local function delete(message)
    message._handler = delete
    ok, option, content = checkMessage(message)

    if ok then
        --Make sure we don't handle multiple messages at once by adding them to a queue while the handler is blocked
        if blocked == false then
            blocked = true
            client:emit(option, optionList[option].del, message, content)
        else
            table.insert(messQueue, 1, message)
        end
    end
end

-- When new message is created and checkmessage return true, add the call to the update handler to the queue.
local function update(message)
    message._handler = update
    ok, option, content = checkMessage(message)

    if ok then
        if blocked == false then
            blocked = true
            client:emit(option, optionList[option].update, message, content)
        else
            table.insert(messQueue, 1, message)
        end
    end
end

--Unblocks the messageHandler and if necessary calls the next message in the queue
local function messageFinished()
    print("end \n")
    blocked = false
    mess = table.remove(messQueue)
    if mess ~= nil then
        mess._handler(mess)
    end
end

local function reactionAdd(reaction, userId)
    -- Call all handlers for tracked messages
    if client:getUser(userId) ~= client.user then
        if trackedMessages[reaction[1]] then
            for k, v in pairs(trackedMessages[reaction[1]]) do
                client:emit(k, v, reaction)
            end
        end
    end

    -- Call handlers for generic reaction handlers
    for k, v in pairs(optionList) do
        if v.reaction then
            client:emit(k, v.reaction, reaction)
        end
    end
end

client:on('messageDelete', delete)
client:on('messageUpdate', update)
client:on('messageCreate', create)
client:on('messageFinished', messageFinished)
client:on('reactionAdd', reactionAdd)

local function init(opt)
    optionList = opt
    return {trackedMessages = trackedMessages}
end

return{
    init = init
}
