local timer = require('timer')
local reminderList = {}

local function sendmess(channel, str)
    channel:send(str)
end

local function timerCallback(channel, str)
    print("Handling callback")
    sendmess(channel, "hey")
end

local function run(message, content)

    t = tonumber(content)
    timer.setTimeout(t*1000, timerCallback, message.channel, content)
    sendmess(message.channel, "hi")

    print('    ', 'timeout on', t, 'seconds')

    client:emit('messageFinished')
end

return {
    run = run,
    ['trigger']='reminder',
    ['isOn'] = false
}
