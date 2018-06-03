local trigger = "stars"
local servers = {}

local function reaction(r)
    local s = servers[r.message.guild]
    local emoji = ''
    if r.emojiId ~= nil then
        emoji = '<:' .. r.emojiName .. ':' .. r.emojiId .. '>'
    else
        emoji = r.emojiName
    end
    if r.count == s.count and s.emoji == emoji then
        s.channel:send(r.message)
    end
    client:emit("messageFinished")
end

local function run(message, content)
    if servers[message.guild] == nil then
        servers[message.guild] = {}
    end

    a, b = string.match(content, "(.*) (.*)")

    if a == 'emoji' then
        servers[message.guild].emoji = b
        message.channel:send('setting star emoji to: ' .. b)
    elseif a == 'count' then
        count = tonumber(b)
        if count ~= nil then
            servers[message.guild].count = count
            message.channel:send('setting star count to: ' .. b)
        else
            print('    Not a number')
            message.channel:send('    Not a number: ' .. b)
        end
    elseif a == 'channel' then
        channelId = string.match(b, '<#(.*)>')
        print("    " .. channelId)
        if channelId ~= nil then
            channel = message.guild:getChannel(channelId)

            if channel ~= nil then
                servers[message.guild].channel = channel
                message.channel:send('setting star channel to: ' .. b)
            else
                print('    invalid channel')
                message.channel:send('    invalid channel: ' .. b)
            end
        else
            print('    invalid channel')
            message.channel:send('    invalid channel: ' .. b)
        end
    else
        message.channel:send("stars only recognises 'channel' or 'emoji'")
    end
    client:emit("messageFinished")
end
return {
        run = run,
        reaction = reaction,
        ['trigger'] = trigger,
        ['isOn'] = true
    }
