local Date = discordia.Date

local trackedMessages = {}

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

local function reaction(reaction, userId)
    if trackedMessages[reaction.message] ~= nil then
        if reaction.emojiName == '✔' then
            log.info(0, 'Kicking user:', reaction.message._user.name)
            reaction.message._user:kick("BnT-bot did some bouncing here")
            reaction.message:delete()
        elseif reaction.emojiName == '✖' then
            reaction.message:delete()
        end
   end
end

local function onCreate(option, content, message)
    local guild = message.guild
    local role, time = string.match(content, "(.*)%s(%d*)")
    time = tonumber(time)
    log.info(0, "checking: " .. role)
    log.info(0, "time: " .. time)
    local count = 0
    for k,v in pairs(guild.members) do
        local userHasRole = hasrole(guild, v, role)
        if v.joinedAt ~= nil then
            local date = Date.fromISO(v.joinedAt)
            local curdate = Date.fromSeconds(os_time())
            local x = curdate - date
            if userHasRole and x:toDays() > time then
                log.info(0, '    found: ' .. v.name)
                count = count + 1
                mess = message.channel:send(v.name .. ", joined " .. tostring(curdate - date) .. " ago")
                mess._user = v
                mess:addReaction('✖')
                mess:addReaction('✔')
                trackedMessages[mess] = true
	    end
        end
    end
    if count == 0 then
        message.channel:send("I'd like to do that, but there is no one left to kick. Chill maybe")
    end
end

function start()
   emitter:on("create_bouncer", onCreate);
   emitter:on("reaction_add", reaction);
end

function stop()
   emitter:removeListener("create_bouncer", onCreate);
   emitter:removeListener("reaction_add", reaction);
end
