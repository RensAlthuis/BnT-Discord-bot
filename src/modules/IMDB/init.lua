local https = require("https")
local io = require("io")
local json = require('json')
local coroutine = require('coroutine')

key = nil

local function parse()
    local res = json.parse(response)
    response = ""

    if res.Response=="True" then
        if res.Search[1] ~= nil then
            return res.Search[1].imdbID
        end
    end

    return nil
end

local function sendRequest(message, content, callback)
    host = "https://www.omdbapi.com/"
    url = host .. '?apikey=' .. key .. '&s=' .. content
    url = string.gsub(url, '%s', '+')

    local req = https.get(url, function (res)
        response = ""
        res:on('data', function (chunk)
            response = response .. chunk
        end)

        res:on('end', function()
            res = parse(response)
            coroutine.wrap(callback)("https://www.imdb.com/title/" .. res)
        end)
    end)
    req:setTimeout(5000, function()
        req:destroy()
        log.err(0, "Timeout on request to: " .. url)
        coroutine.wrap (function ()
            message.channel:send("Timeout while requesting information, IMDB might be offline. If it is not, I guess you could contact your admins?")
        end)()
    end)

    req:on('error', function(e)
        log.err(0, "Unknown error on goodreads request: " .. e)
        coroutine.wrap (function ()
            message.channel:send("Unknown error while requesting information from IMDB... not sure what you did to get this answer but please tell my creator about it!") 
        end)()
    end)

    req:done()
end

local function onCreate(option, content, message)
    log.info(0, "create_imdb: " .. content)
    sendRequest(message, content, function(res)
        if res then
            log.print(2, "Found page: " .. res)
            message.channel:send(res)
        else
            message.channel:send("Not found")
        end
    end)
end

local function onUpdate(option, content, message)
    log.info(0, 'update_imdb: ' .. content)

    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil
    for v in res:iter() do
        mess = v
    end

    if mess then
        if mess.author.name == client.user.username then
            sendRequest(message, content, function(res)
                if res then
                    log.print(2, "Found page: " .. res)
                    mess:setContent(res)
                else
                    mess:setContent("No results found")
                end
            end)
        else
            log.print(2, 'no message found')
        end
    else
        log.print(2, 'no message found')
    end
end

local function onDelete(option, content, message)
    log.info(0, 'delete_imdb: ' .. content)
    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil

    for v in res:iter() do
        mess = v
    end

    if mess == nil then
        log.info(0, 'No message found')
    else
        if mess.author.name == client.user.username then
            mess.delete(mess)
        end
    end
end

function start()
    local keyfile, err = io.open(PATH .. "IMDB.key", "r")
    if keyfile then
        key = keyfile:read()
    else
        error("Error while reading keyfile")
    end

    emitter:on("create_imdb", onCreate)
    emitter:on("update_imdb", onUpdate)
    emitter:on("delete_imdb", onDelete)
end

function stop()
    emitter:removeListener("create_imdb", onCreate)
    emitter:removeListener("update_imdb", onUpdate)
    emitter:removeListener("delete_imdb", onDelete)
end
