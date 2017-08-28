local client = nil

function run(message, content)

    print("pong")
    message.channel:sendMessage('pong')
    client:emit('messageFinished')
end

function init(cl)
    client = cl

    return{run = run}
end

return{init = init}
