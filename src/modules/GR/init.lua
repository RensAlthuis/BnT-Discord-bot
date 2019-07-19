local https = require("https")
local io = require("io")
local xml = require('xmlSimple.lua').newParser()

local key = ""
local baseUrl = ""

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

    log.info(0, 'Book found with ID:', bookid)
    return bookid
end

local function GoodreadsRequest(searchString, message)
        log.info(0, "Sending request to Goodreads")
        log.print(2, "content:", searchString)

        local url = baseUrl .. searchString
        url = string.gsub(url, '%s', '+')

        local fullResponse = ""

        local req = https.get(baseUrl, function (res)
            res:on('data', function (chunk)
                log.print(2, 'recieved chunk')
                fullResponse = fullResponse .. chunk
            end)

            res:on('end', function()
                log.print(2, "end of request")
                bookid = parseResult(fullResponse)
                if bookid == nil then
                    message.channel.send("Not found")
                else
                    message.channel.send("ID = " .. bookid)
                end
            end)
        end)

        req:done()
end

local function onCreate(option, content, message)
    log.info(0, "ONCREATE")
    GoodreadsRequest(content, message)
end

local function onUpdate(option, content, message)

end

local function onDelete(option, content, message)

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