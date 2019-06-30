local function run(message, content)

    print("    reply: pong")
    client:emit('messageFinished')
end

return {
    run = run,
    ['isOn'] = false
}
