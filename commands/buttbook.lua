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
    local r = math.random(20)

    if results:children()[r] ~= nil then
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
        channel:send("https://www.goodreads.com/book/show/" .. bookid)
    else
        channel:send("No results found")
    end

    client:emit("messageFinished")
end

--initiates the websearch then sends the result on to GR_result
local function run(message, content)
        local r = math.random(100)
        host = "https://www.goodreads.com"
        searchUrl = host .. '/search.xml?key=' .. GRkey .. '&q=butt' .. '&page=' .. r
        searchUrl = string.gsub(searchUrl, '%s', '+')

        print("    url: " .. searchUrl)

        local req = https.get(searchUrl, function (res)
            res:on('data', function (chunk)

                client:emit('BB_chunk', chunk)

            end)

            res:on('end', function()
                bookid = result()
                client:emit('BB_postMess', bookid, message.channel)
            end)
        end)

        req:done()
end

local function del(message)
    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil

    for v in res:iter() do
        mess = v
    end

    if mess == nil then
        print("    No message found")
    else
        if mess.author.name == 'BooksandTea-Bot' then
            mess.delete(mess)
        end
    end

    client:emit("messageFinished")
end

local function init(cl)
    client = cl
    readGRKey()
    client:on('BB_chunk', chunk)
    client:on('BB_postMess', postMess)
    math.randomseed(os.time())
    return{
        run = run,
        del = del,
        ['isOn'] = false
    }
end
return { init = init }

