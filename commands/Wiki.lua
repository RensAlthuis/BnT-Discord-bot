local https = require("https")
local xml = require('xmlSimple.lua').newParser()
local response = ""
local fs = require('fs')
GRkey = nil

local function chunk(chunk)
    response = response .. chunk
end

--process the result
local function result()

    local parsedXml = xml:ParseXmlText(response)

    local results = parsedXml.SearchSuggestion.Section.Item.Url:value()
    response = ""
    return results
end

local function postMess(result, channel)
    if result ~= nil then
        channel:send(result)
    else
        channel:send("No results found")
    end

    client:emit("messageFinished")
end

local function updateMess(result, message)
    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil

    for v in res:iter() do
        mess = v
    end

    if mess == nil then
        print('    no message found')
    else
        if mess.author.name == client.user.username then
            if result ~= nil then
                mess:setContent(result)
            else
                mess:setContent("No results found")
            end
        else
            print('    no message found')
            client:emit("messageFinished")
        end
    end

    client:emit("messageFinished")
end

--initiates the websearch then sends the result on to GR_result
local function run(message, content)
        host = "https://en.wikipedia.org"
        searchUrl = host .. '/w/api.php?action=opensearch&limit=1&format=xml&search=' .. content
        searchUrl = string.gsub(searchUrl, '%s', '+')
        print("    url: " .. searchUrl)

        local req = https.get(searchUrl, function (res)
            res:on('data', function (chunk)
                client:emit('Wiki_chunk', chunk)
            end)

            res:on('end', function()
                link = result()
                client:emit('Wiki_postMess', link, message.channel)
            end)
        end)

        req:done()
end

local function del(message, content)
    print('    Deleting message')
    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil

    for v in res:iter() do
        mess = v
    end

    if mess == nil then
        print('    no message found')
    else
	print('    message found: ' .. mess.content)
        if mess.author.name == client.user.username then
            mess.delete(mess)
        end

    end

    client:emit("messageFinished")
end

local function update(message, content)
    print('    Updating message')
    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil

    for v in res:iter() do
        mess = v
    end
    if mess == nil then print('    no message found')
        client:emit('messageFinished')
	return
    else

        if mess.author.name == client.user.username then
            host = "https://en.wikipedia.org"
            searchUrl = host .. '/w/api.php?action=opensearch&limit=1&format=xml&search=' .. content
            searchUrl = string.gsub(searchUrl, '%s', '+')
            print("    url: " .. searchUrl)

            local req = https.get(searchUrl, function (res)
                res:on('data', function (chunk)
                    client:emit('Wiki_chunk', chunk)
                end)

                res:on('end', function()
                    link = result()
                    client:emit('Wiki_updateMess', link, message)
                end)
            end)

            req:done()
	else
	    print('    no message found')
            client:emit("messageFinished")
        end
    end
end

local x = client:getListenerCount("Wiki_chunk")
if x ~= 0 then
    client:removeAllListeners('Wiki_chunk')
    client:removeAllListeners('Wiki_postMess')
    client:removeAllListeners('Wiki_updateMess')
end

client:on('Wiki_chunk', chunk)
client:on('Wiki_postMess', postMess)
client:on('Wiki_updateMess', updateMess)

return{
	run = run,
	del = del,
	update = update,
	['trigger'] = "Wiki",
	['isOn'] = true
}

