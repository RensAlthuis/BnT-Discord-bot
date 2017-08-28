--set timer
--register contestants
--random winner
--edit message for timer
--end time
local timer = require('timer')
local timerList = {}
local client = nil

local function timerCallback()
    for k,v in pairs(timerList) do
        if v[1] <= 0 then
            print(k .. ' finished')
            table.remove(timerList, k)
        else
            print(k .. ': ' .. v[1])
            timerList[k][1] = v[1] - 1
            client:emit('updatemessage', k)
        end
    end
end

local function updateMessage(k)
    timerList[k][2].content = 'timer: ' .. timerList[k][1]
end

local function run(message, content)

    mess = message.channel:sendMessage('timer: 20')
    table.insert(timerList, {20, mess})

    client:emit('messageFinished')
end

function init(cl)
    client = cl
    client:on('updatemessage', updateMessage)

    timer.setInterval(1000, timerCallback)
    return { run = run }
end

return { init = init }
