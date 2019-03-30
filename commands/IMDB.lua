--https://www.omdbapi.com/?apikey=a56ec13e&t=arrival

local https = require("https")
local json = require('json')
local response = ""
local fs = require('fs')
APIkey = nil

local function chunk(chunk)
    response = response .. chunk
end

local function readAPIKey()
    if err ~= nil then
        print(err)
        return
    end

    fs.readFile('./commands/IMDB.key', function(err, file)
	if err ~= nil then
            print(err)
        end
        APIkey = file
    end)
end

--process the result
local function result()
    local res = json.parse(response)
    response = ""

    if res.Response=="True" then
        if res.Search[1] ~= nil then
            return res.Search[1].imdbID
        end
    end

    return nil
end

local function postMess(id, message)
    if id ~= nil then
        message.channel:send("https://www.imdb.com/title/" .. id)
    else
        message.channel:send("No results found")
    end

    client:emit("messageFinished")
end

local function updateMess(id, message)
    local res = message.channel:getMessagesAfter(message, 1)
    local mess = nil

    for v in res:iter() do
        mess = v
    end

    if mess == nil then
        print('    no message found')
    else
        if mess.author.name == client.user.username then
            if id ~= nil then
                mess:setContent("https://www.imdb.com/title/" .. id)
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

local function httpsearch(content, callback, message)
    host = "https://www.omdbapi.com/"
    searchUrl = host .. '?apikey=' .. APIkey .. '&s=' .. content
    searchUrl = string.gsub(searchUrl, '%s', '+')

    print("    url: " .. searchUrl)

    return https.get(searchUrl, function (res)
        res:on('data', function (chunk)

            client:emit('IMDB_chunk', chunk)

        end)

        res:on('end', function()
            id = result()
            client:emit(callback, id, message)
        end)
    end)

end
--initiates the websearch then sends the result on to result
local function run(message, content)
        local req = httpsearch(content, 'IMDB_postMess', message);
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
            local req = httpsearch(content, 'GR_updateMess', message)
            req:done()
        else
            print('    no message found')
            client:emit("messageFinished")
        end
    end
end

readAPIKey()

local x = client:getListenerCount("IMDB_chunk")
if x ~= 0 then
    client:removeAllListeners('IMDB_chunk')
    client:removeAllListeners('IMDB_postMess')
    client:removeAllListeners('IMDB_updateMess')
end

client:on('IMDB_chunk', chunk)
client:on('IMDB_postMess', postMess)
client:on('IMDB_updateMess', updateMess)

return{
	run = run,
	del = del,
	update = update,
	['trigger'] = "IMDB",
	['isOn'] = true
}

