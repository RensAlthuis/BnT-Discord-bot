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


--[[
    TODO: Hardcoded Timeout of 5 seconds (SORRY, i'll fix this someday)
]]
local function GoodreadsRequest(message, searchString, callback)

        local url = baseUrl .. searchString
        url = string.gsub(url, '%s', '+')


        log.print(3, "Sending request to Goodreads: " .. url)
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

        req:setTimeout(5000, function()
            req:destroy()
            log.err(0, "Timeout on request to: " .. url)
            coroutine.wrap (function ()
                message.channel:send("Timeout while requesting information, Goodreads might be offline. If it is not, I guess you could contact your admins?")
            end)()
        end)

        req:on('error', function(e)
            log.err(0, "Unknown error on goodreads request: " .. e)
            coroutine.wrap (function ()
                message.channel:send("Unknown error while requesting information from goodreads... not sure what you did to get this answer but please tell my creator about it!") 
            end)()
        end)

        req:done()
end

local function onCreate(option, content, message)
    GoodreadsRequest(message, content, function(bookid)
        if bookid then
            log.info(0, "Posting result - From: " .. message.author.name .. ", Request: " .. content .. ", Result: " .. bookid)
            message.channel:send("https://www.goodreads.com/book/show/" .. bookid)
        else
            message.channel:send("Not found")
        end
    end)
end

local function onUpdate(option, content, message)

    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil

    for v in res:iter() do
        mess = v
    end

    if mess then
        if mess.author.name == client.user.username then
            message:setContent("requesting new book")
            GoodreadsRequest(message, content, function(bookid)
                if bookid then
                    log.info(0, "Updating result - From: " .. message.author.name .. ", Request: " .. content .. ", Result: " .. bookid)
                    mess:setContent("https://www.goodreads.com/book/show/" .. bookid)
                else
                    mess:setContent("No results found")
                end
            end)
        else
            log.print(3, 'no message found')
        end
    else
        log.print(3, 'no message found')
    end
end

local function onDelete(option, content, message)
    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil

    for v in res:iter() do
        mess = v
    end

    if mess == nil then
        log.info(0, 'No message found')
    else
        if mess.author.name == client.user.username then
            log.info(0, "Removing result - From: " .. message.author.name .. "Content: " .. content)
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
    baseUrl = "https://www.ggggoodreads.com" .. "/search.xml?key=" .. key .. "&q="
end

function stop()
    emitter:removeListener("create_GR", onCreate)
    emitter:removeListener("update_GR", onUpdate)
    emitter:removeListener("delete_GR", onDelete)
end