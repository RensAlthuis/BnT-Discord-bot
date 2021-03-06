--set timer
--register contestants
--random winner
--edit message for timer
--end time
local timer = require('timer')
local timerList = {}

local function timerCallback()
    for k,v in pairs(timerList) do
        if v[1] <= 0 then
            print('timer: ' .. k .. ' finished')
            table.remove(timerList, k)
        else
            timerList[k][1] = v[1] - 1
        end
    end

    client:emit('updatemessages')
end

local function updateMessages()
    for k,v in pairs(timerList) do
        if v[1] <= 0 then
            timerList[k][2].content = 'timer: finished'
        else
            timerList[k][2].content = 'timer: ' .. timerList[k][1]
        end

    end
end

local function run(message, content)

    t = tonumber(content)
    print('    Started new timer with: ' .. t .. 's')
    mess = message.channel:send('timer: ' .. t)
    table.insert(timerList, {t, mess})

    client:emit('messageFinished')
end

local x = client:getListenerCount("updateMessages")
if x ~= 0 then
    client:removeAllListeners('updatemessages')
end

client:on('updatemessages', updateMessages)
timer.setInterval(1000, timerCallback)

return {
	run = run,
	['isOn'] = false
}
