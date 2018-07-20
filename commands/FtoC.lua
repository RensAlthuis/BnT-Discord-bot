local function FtoC(n)
    return (n-32)*5/9
end

local function run(message, content)
    num = string.match(content, "(%d+)")
    if num ~= nil then 
        celcius = FtoC(num)
        message.channel:send(tostring(celcius))
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
            num = string.match(content, "(%d+)")
            celcius = FtoC(num)
            mess:setContent(tostring(celcius))
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
	['trigger'] = "FtoC",
	['isOn'] = true
}

