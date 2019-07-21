local https = require("https")
local xml = require('xmlSimple.lua').newParser()
local fs = require('fs')
local coroutine = require('coroutine')

--process the result
local function parse()
    local parsedXml = xml:ParseXmlText(response)

    local results = parsedXml.SearchSuggestion.Section
    if results.Item ~= nil then
        results = results.Item.Url:value()
    else
        results = nil
    end

    return results
end

local function sendRequest(content, callback)
    host = "https://en.wikipedia.org"
    url = host .. '/w/api.php?action=opensearch&limit=1&format=xml&search=' .. content
    url = string.gsub(url, '%s', '+')

    local req = https.get(url, function (res)
        response = ""
        res:on('data', function (chunk)
            response = response .. chunk
        end)

        res:on('end', function()
            link = parse(response)
            coroutine.wrap(callback)(link)
        end)
    end)

    req:done()
end

local function onCreate(option, content, message)
    log.info(0, "create_wiki: " .. content)
    sendRequest(content, function(res)
        if res then
            log.print(2, "Found page: " .. res)
            message.channel:send(res)
        else
            message.channel:send("Not found")
        end
    end)
end

local function onUpdate()
    log.info(0, 'update_wiki: ' .. content)

    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil
    for v in res:iter() do
        mess = v
    end

    if mess then
        if mess.author.name == client.user.username then
            sendRequest(content, function(res)
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

local function onDelete()
    log.info(0, 'delete_wiki: ' .. content)
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
    emitter:on("create_wiki", onCreate)
    emitter:on("update_wiki", onUpdate)
    emitter:on("delete_wiki", onDelete)
end

function stop()
    emitter:removeListener("create_wiki", onCreate)
    emitter:removeListener("update_wiki", onUpdate)
    emitter:removeListener("delete_wiki", onDelete)
end