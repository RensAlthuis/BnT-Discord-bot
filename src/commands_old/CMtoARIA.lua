local function CMtoARIA(cm)
    return cm/160.545849385802850
end

local function run(message, content)
    cm = string.match(content, "(%d+)")
    if cm ~= nil then 
	aria = CMtoARIA(cm)
	message.channel:send(tostring(aria))
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
	    cm = string.match(content, "(%d+)")
	    if cm ~= nil then
                aria = CMtoARIA(cm)
                mess:setContent(tostring(aria))
	    end
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
	['trigger'] = "CMtoAria",
	['isOn'] = true
}

