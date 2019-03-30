local function CMtoF(cm)
    feet = cm/30.48
    ft = feet - (feet % 1)
    inch = math.floor(((feet%1) * 12) +0.5)
    return ft, inch
end

local function run(message, content)
    cm = string.match(content, "(%d+)")
    if cm ~= nil then 
	feet, inch = CMtoF(cm)
	message.channel:send(tostring(feet .. "'" .. inch .. "''"))
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
                feet, inch = FtoCM(cm)
                mess:setContent(tostring(feet .. "'" .. inch .. "''"))
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
	['trigger'] = "CMtoF",
	['isOn'] = true
}

