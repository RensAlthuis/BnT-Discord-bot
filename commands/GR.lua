client = nil
local https = require("https")
local xml = require('../deps/xmlSimple.lua').newParser()
local response = ""
local fs = require('fs')
GRkey = nil

local function chunk(chunk)
    response = response .. chunk
end

local function readGRKey()
    if err ~= nil then
        print(err)
        return
    end

    fs.readFile('./commands/GR.key', function(err, file)
	if err ~= nil then
            print(err)
        end
        GRkey = file
    end)
end

--process the result
local function result()

    response = string.gsub(response, '<name', '<the_name')
    response = string.gsub(response, '</name', '</the_name')

    local parsedXml = xml:ParseXmlText(response)

    local bookid = nil
    local results = parsedXml.GoodreadsResponse.search:children()[7]

    if results:children()[1] ~= nil then
        bookid = results:children()[1].best_book.id:value()
        if bookid ~= nil then
            print('    book found with bookid: '.. bookid)
        end
    else
        print('    no results found')
    end
    response = ""
    return bookid
end

local function postMess(bookid, channel)
    if bookid ~= nil then
        channel:sendMessage("https://www.goodreads.com/book/show/" .. bookid)
    else
        channel:sendMessage("No results found")
    end

    client:emit("messageFinished")
end

local function updateMess(bookid, message)
    local mess = message.channel.getMessageHistoryAfter(message.channel, message, 1)()
    if mess == nil then
        print("    WARNING: No message found")
    else
        if mess.author.name == 'BooksandTea-Bot' then
            if bookid ~= nil then
                mess.content = "https://www.goodreads.com/book/show/" .. bookid
            else
                mess.content = "No results found"
            end
        end
    end

    client:emit("messageFinished")
end

--initiates the websearch then sends the result on to GR_result
local function run(message, content)
        host = "https://www.goodreads.com"
        searchUrl = host .. '/search.xml?key=' .. GRkey .. '&q=' .. content
        searchUrl = string.gsub(searchUrl, '%s', '+')

        print("    url: " .. searchUrl)

        local req = https.get(searchUrl, function (res)
            res:on('data', function (chunk)

                client:emit('GR_chunk', chunk)

            end)

            res:on('end', function()
                bookid = result()
                client:emit('GR_postMess', bookid, message.channel)
            end)
        end)

        req:done()
end

local function del(message)
    local mess = message.channel.getMessageHistoryAfter(message.channel, message, 1)()
    if mess == nil then
        print("    WARNING: No message found")
    else
        if mess.author.name == 'BooksandTea-Bot' then
            mess.delete(mess)
        end
    end

    client:emit("messageFinished")
end

local function update(message, content)
    local mess = message.channel.getMessageHistoryAfter(message.channel, message, 1)()
    if mess.author.name == 'BooksandTea-Bot' then
        host = "https://www.goodreads.com"
        searchUrl = host .. '/search.xml?key=' .. GRkey .. '&q=' .. content
        searchUrl = string.gsub(searchUrl, '%s', '+')

        print("    url: " .. searchUrl)

        local req = https.get(searchUrl, function (res)
            res:on('data', function (chunk)
                client:emit('GR_chunk', chunk)
            end)

            res:on('end', function()
                bookid = result()
                client:emit('GR_updateMess', bookid, message)
            end)
        end)

        req:done()

    end
end

local function init(cl)
    client = cl
    readGRKey()
    client:on('GR_chunk', chunk)
    client:on('GR_postMess', postMess)
    client:on('GR_updateMess', updateMess)
    return{
        run = run,
        del = del,
        update = update,
        ['isOn'] = true
    }
end
return { init = init }

