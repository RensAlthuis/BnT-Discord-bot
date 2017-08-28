local client = nil

function run(message, content)

    print("    reply: pong")
    message.channel:sendMessage('pong')
    client:emit('messageFinished')
end

function init(cl)
    client = cl

    return {
        run = run,
        ['isOn'] = false
    }
end

return{init = init}
