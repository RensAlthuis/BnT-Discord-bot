local function FtoCM(ft, inch)
    n = ft + (inch/12.0)
    return n*(30.48)
end

local function run(message, content)
    ft, inch = string.match(content, "(%d+)'(%d+)''")
    if ft ~= nil then 
	centi = FtoCM(ft, inch)
	message.channel:send(tostring(centi))
    else
        message.channel:send("thats not a number >:C")
    end
    client:emit("messageFinished")
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

    if mess == nil then 
        print('    no message found')
    else
        if mess.author.name == client.user.username then
            --update the message
	    ft, inch = string.match(content, "(%d+)'(%d+)''")
            centi = FtoCM(ft, inch)
            mess:setContent(tostring(centi))
        else
            print('    no message found')
        end
    end
    client:emit("messageFinished")
end

return{
	run = run,
	del = del,
	update = update,
	['trigger'] = "FTtoCM",
	['isOn'] = true
}

