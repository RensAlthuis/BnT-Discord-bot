local function run(message, content)

    print("    reply: pong")
    message.channel:send('pong')
    client:emit('messageFinished')
end

return {
    run = run,
    ['isOn'] = false
}
