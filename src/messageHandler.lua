local _settings = {}
local SafeEmitter = require('./util/safeEmitter')
local emitter = SafeEmitter:new()

--[[
    parses messages and returns the command with its content
    returns falses otherwise
]]
local function parseMessage(message)
    local marker = string.sub(message.content, 0, 1)
    marked = false
    for k,v in pairs(_settings.markers) do
        if v == marker then marked = true end
    end

    if marked == false then
        return false
    end

    local option, content = string.match(message.content, "(%g*)%s?(.*)", 2)
    if option == nil or content == nil then
        return false
    end

    return true, option, content
end

--[[
    gets triggered if any message is created
]]
local function onCreate(message)
    message._handler = onCreate

    emitter:emit("create_any", message)

    if message.guild then
        emitter:emit("guild_" .. message.guild.id, message)
    end

    ok, option, content = parseMessage(message)
    if ok then
        emitter:emit("create_" .. option, option, content, message)
    end
end

--[[
    gets triggered if any message is deleted
]]
local function onDelete(message)
    message._handler = onDelete
    emitter:emit("delete_any", message)

    if message.guild then
        emitter:emit("guild_" .. message.guild.id, message)
    end

    ok, option, content = parseMessage(message)
    if ok then
        emitter:emit("delete_" .. option, option, content, message)
    end
end

--[[
    gets triggered if any message is edited
    TODO: fix marker events should only trigger if this was a previously marked message
]]
local function onUpdate(message)
    message._handler = onUpdate

    emitter:emit("update_any", message)

    if message.guild then
        emitter:emit("guild_" .. message.guild.id, message)
    end

    ok, option, content = parseMessage(message)
    if ok then
        emitter:emit("update_" .. option, option, content, message)
    end

end

--[[
    gets triggered if any reaction is added to a message
]]
local function onReactionAdd(reaction, userId)
    emitter:emit("reaction_add")
end

local function start(settings)
    _settings = settings

    client:on('messageCreate', onCreate)
    client:on('messageDelete', onDelete)
    client:on('messageUpdate', onUpdate)
    client:on('reactionAdd', onReactionAdd)

    return emitter
end

return {
    start = start
}

-- -- Adding some memes to messages
-- local function funstuff(message)
--     -- I LOVE BUTBOTT
--     if message.author.name == "Buttbot" then
-- 	local r = math.random(5)
--         if r == 1 then
--                 message:addReaction("\xE2\x9D\xA4")
--         end
--     end

--     -- THIS IS A DRINKING GAME
--     if message.channel.mentionString ~= "<#302884873729867777>" then
--         -- 302884873729867777 is the id for cosmere channel
--         local wordlist = {"sanderson","cosmere"}
--         local tosearch = string.lower(message.content)

--         for key, val in ipairs(wordlist) do
--             str = "%S*"
--             val:gsub(".", function(c)
--                 str = str .. c .. "%S*"
--             end)
--             result = string.match(tosearch, str)

--             if result ~= nil then
--                 result = string.find(result, "https?://") -- exlude links
--                 if result ~= 1 then
--                     result = 1
--                     break
--                 else
--                     result = nil
--                 end
--             end
--         end

--         if result ~= nil then
--             message:addReaction("\xF0\x9F\x8D\xBA")
--         end
--     end

-- end