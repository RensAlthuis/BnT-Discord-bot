client = nil
local https = require("https")
local xml = require('../deps/xmlSimple.lua').newParser()
local response = ""
local fs = require('fs')
GRkey = nil

local function GR_chunk(chunk)
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
local function GR_result(channel)

    response = string.gsub(response, '<name', '<the_name')
    response = string.gsub(response, '</name', '</the_name')

    local parsedXml = xml:ParseXmlText(response)

    local results = parsedXml.GoodreadsResponse.search:children()[7]
    if results:children()[1] ~= nil then
        local bookid = results:children()[1].best_book.id:value()
        if bookid ~= nil then
            print('    book found with bookid: '.. bookid)
            channel:sendMessage("https://www.goodreads.com/book/show/" .. bookid)
            bookid = nil
        end
    else
        channel:sendMessage("No results found")
        print('    no results found')
    end
    response = ""

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
              client:emit('GR_result', message.channel)
          end)
        end)

        req:done()
end

local function del(message)
    local mess = message.channel.getMessageHistoryAfter(message.channel, message, 1)()
    print(mess.author)
    if mess.author.name == 'BooksandTea-Bot' then
        mess.delete(mess)
    end

    client:emit("messageFinished")
end

local function init(cl)
    client = cl
    readGRKey()
    client:on('GR_chunk', GR_chunk)
    client:on('GR_result', GR_result)
    return{
        run = run,
        del = del,
        ['isOn'] = true
    }
end
return { init = init }

