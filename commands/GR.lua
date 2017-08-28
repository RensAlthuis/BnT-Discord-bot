client = nil
local https = require("https")
local xml = require('../deps/xmlSimple.lua').newParser()
local response = ""

local function GR_chunk(chunk)
    response = response .. chunk
end

--process the result
local function GR_result(channel)

    local response = string.gsub(response, '<name', '<the_name')
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
        searchUrl = host .. '/search.xml?key=EeG9ipXRB8OWxZBFrLYQ&q=' .. content
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


local function init(cl)
    client = cl
    client:on('GR_chunk', GR_chunk)
    client:on('GR_result', GR_result)
    return{
        run = run,
        ['isOn'] = true
    }
end
return { init = init }

