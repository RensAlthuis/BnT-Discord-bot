local discordia = require('discordia')
local https = require('https')
local client = discordia.Client()
local xml = require("xmlSimple.lua").newParser()

client:on('ready', function()
    blocked = false
	print('Logged in as '.. client.user.username)
end)

local messQueue = {}
local response = ""

function handleMessage(message)
    if blocked == false then
        blocked = true
            --print("start " .. start .. " finish " .. finish)
            start, finish = string.find(message.content, "!GR ")
            if string.len(message.content) > finish then
                host = "https://www.goodreads.com"
                search = string.sub(message.content, finish+1)
                searchUrl = host .. '/search.xml?key=EeG9ipXRB8OWxZBFrLYQ&q=' .. search
                searchUrl = string.gsub(searchUrl, '%s', '+')

                print("url: " .. searchUrl)

                local req = https.get(searchUrl, function (res)
                    local bookid = nil
                    res:on('data', function (chunk)

                    client:emit('chunkRecieved', chunk)

                  end)

                  res:on('end', function()
                      client:emit('bookfound', message.channel, bookid)
                  end)
                end)

                req:done()
            end
    else
        print("blocked, message added to queue")
        table.insert(messQueue, 1, message)
    end
end

client:on('messageCreate', function(message)
    start, finish = string.find(message.content, "!GR ")
    if start == 1 then
        print(message)
        handleMessage(message)
    end
end)
client:on('chunkRecieved', function(chunk)
    response = response .. chunk
end)

client:on('bookfound', function(channel, bookid)

    response = string.gsub(response, '<name', '<the_name')
    response = string.gsub(response, '</name', '</the_name')

    parsedXml = xml:ParseXmlText(response)
    results = parsedXml.GoodreadsResponse.search:children()[7]
    if results:children()[1] ~= nil then
        bookid = results:children()[1].best_book.id:value()
        if bookid ~= nil then
            print('book found with bookid: '.. bookid)
            channel:sendMessage("https://www.goodreads.com/book/show/" .. bookid)
            bookid = nil
        end
    else
        channel:sendMessage("No results found")
        print('no results found')
    end
    response = ""
    blocked = false

    mess = table.remove(messQueue)
    if mess ~= nil then
        print("handling queued message")
        handleMessage(mess)
    end
end)

--GR-BOT
--client:run('MzM4NzY0MTQzOTgzMTk4MjA4.DFf1KQ.sGv0lQCMu02RZmDRY3LDAJq3E7o')
--BooksandTea-bot
client:run('MzM5MTQ1NjU2MTgwNDA4MzIw.DFfthw.bERJ0hg5iLTtyhqIM6XW58Lk9Jw')
