
function run(message, content)
    print("    YES")
    client:emit('messageFinished')
    return("hello!?")
end

return {
        run = run,
        ['trigger'] = "cheese",
        ['isOn'] = true
    }
