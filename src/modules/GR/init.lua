local https = require("https")
local io = require("io")
local xml = require('xmlSimple.lua').newParser()
local coroutine = require('coroutine')

local key = ""
local baseUrl = ""

client = _G.client

--process the result
local function parseResult(response)

    response = string.gsub(response, '<name', '<the_name')
    response = string.gsub(response, '</name', '</the_name')

    local parsedXml = xml:ParseXmlText(response)
    local bookid = nil

    local results = parsedXml.GoodreadsResponse.search:children()[7]
    if results:children()[1] == nil then
        log.info(0, "Couldn't find book")
        return nil
    end

    bookid = results:children()[1].best_book.id:value()
    if bookid == nil then
        log.info(0, "Couldn't find book")
        return nil
    end
    return bookid
end

local function GoodreadsRequest(searchString, callback)
        log.print(2, "Sending request to Goodreads")

        local url = baseUrl .. searchString
        url = string.gsub(url, '%s', '+')


        local req = https.get(url, function (res)
            local fullResponse = ""
            res:on('data', function (chunk)
                fullResponse = fullResponse .. chunk
            end)

            res:on('end', function()
                bookid = parseResult(fullResponse)
                coroutine.wrap(callback)(bookid)
            end)
        end)

        req:done()
end

local function onCreate(option, content, message)
    log.info(0, "create_GR: " .. content)
    GoodreadsRequest(content, function(bookid)
        if bookid then
            log.print(2, "Found book with id: " .. bookid)
            message.channel:send("https://www.goodreads.com/book/show/" .. bookid)
        else
            message.channel:send("Not found")
        end
    end)
end

local function onUpdate(option, content, message)
    log.info(0, 'update_GR: ' .. content)

    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil

    for v in res:iter() do
        mess = v
    end

    if mess then
        if mess.author.name == client.user.username then
            message:setContent("requesting new book")
            GoodreadsRequest(content, function(bookid)
                if bookid then
                    mess:setContent("https://www.goodreads.com/book/show/" .. bookid)
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
    log.info(0, 'delete_GR: ' .. content)
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
    emitter:on("create_GR", onCreate)
    emitter:on("update_GR", onUpdate)
    emitter:on("delete_GR", onDelete)

    local keyfile, err = io.open(PATH .. "GR.key", "r")
    key = keyfile:read()
    baseUrl = "https://www.goodreads.com" .. "/search.xml?key=" .. key .. "&q="
end

function stop()
    emitter:removeListener("create_GR", onCreate)
    emitter:removeListener("update_GR", onUpdate)
    emitter:removeListener("delete_GR", onDelete)
end