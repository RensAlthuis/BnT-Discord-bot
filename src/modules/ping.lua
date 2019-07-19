local function handler(option, content, message)
    message.channel:send("pong")
end

function start()
    emitter:on("create_ping", handler)
end

function stop()
    emitter:removeListener("create_ping", handler)
end