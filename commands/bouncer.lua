local Date = discordia.Date
local trigger = "bouncer"

local function hasrole(guild, user, role)
    if user[7] then 
        for k,v in pairs(user[7]) do
            if guild:getRole(v)[9] == role then
                return true
            end
        end
    end
    return false
end

local function reaction(r)
    if r.emojiName == '✔' then
        print('check', r.message._user)
        r.message:delete()
    elseif r.emojiName == '✖' then
        print('cross', r.message._user)
        r.message:delete()
    end
end

local function run(message, content)
    local guild = client:getGuild('311229289536290823')
    for k,v in pairs(guild.members) do
        local userHasRole= hasrole(guild, v, "Hatchling")
        local date = Date.fromISO(v[4])
        local curdate = Date.fromSeconds(os.time())
        local x = curdate - date
        if userHasRole and x:toWeeks() > 2 then
            mess = message.channel:send(v[6].name .. ", joined " .. tostring(curdate - date) .. " ago")
            mess._user = v[6]
            mess:addReaction('✖')
            mess:addReaction('✔')

            if trackedMessages[mess] == nil then
                trackedMessages[mess] = {}
            end
            trackedMessages[mess][trigger] = reaction
        end
    end
    client:emit('messageFinished')
end

return {
        run = run,
        ['trigger'] = trigger,
        ['isOn'] = true
    }
