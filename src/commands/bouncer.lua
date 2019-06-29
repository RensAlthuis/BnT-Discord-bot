local Date = discordia.Date
local trigger = "bouncer"

local function hasrole(guild, user, role)
    if user.roles then 
        for k,v in pairs(user.roles) do
            if guild:getRole(v)[9] == role then
                return true
            end
        end
    end
    return false
end

local function trackedReaction(r)
    if r.emojiName == '✔' then
        print('Kicking user:', r.message._user.name)
        r.message._user:kick("BnT-bot did some bouncing here")
        r.message:delete()
    elseif r.emojiName == '✖'then
        r.message:delete()
    end
end

local function run(message, content)
    local guild = message.guild
    local role, time = string.match(content, "(.*)%s(%d*)")
    time = tonumber(time)
    print("    checking: " .. role)
    print("    time: " .. time)
    local count = 0
    for k,v in pairs(guild.members) do
        local userHasRole= hasrole(guild, v, role)
        if v.joinedAt ~= nil then
            local date = Date.fromISO(v.joinedAt)
            local curdate = Date.fromSeconds(os.time())
            local x = curdate - date
            if userHasRole and x:toDays() > time then
                print('    found: ' .. v.name)
                count = count + 1
                mess = message.channel:send(v.name .. ", joined " .. tostring(curdate - date) .. " ago")
                mess._user = v
                mess:addReaction('✖')
                mess:addReaction('✔')

                if trackedMessages[mess] == nil then
                    trackedMessages[mess] = {}
                end
                trackedMessages[mess][trigger] = trackedReaction
            end
        end
    end
    if count == 0 then
        message.channel:send("I'd like to do that, but there is no one left to kick. Chill maybe")
    end
    client:emit('messageFinished')
end

return {
        run = run,
        trackedReaction = trackedReaction,
        ['trigger'] = trigger,
        ['isOn'] = true
    }
