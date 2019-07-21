local math = require('math')

local function CMtoFT(option, content, message)
    local cm = string.match(content, "(%d+)")
    if cm then
        feet = cm/30.48
        ft = feet - (feet % 1)
        inch = math.floor(((feet%1) * 12) +0.5)
        res = feet .. "'" .. inch .. "''"
        message.channel:send(res)
        log.info(0, "CMtoFT: " .. tostring(cm) .. " -> " .. res)
    else
        message.channel:send("Invalid number")
    end
end

local function FTtoCM(option, content, message)
    local ft, inch = string.match(content, "(%d+)'(%d+)''")
    if ft and inch then
        res = tostring((ft + (inch/12.0))*(30.48))
        message.channel:send(res)
        log.info(0, "FTtoCM: " .. feet .. "'" .. inch .. "''" .. " -> " .. res)
    else
        message.channel:send("Invalid number")
    end
end


local function CtoF(option, content, message)
    local num = string.match(content, "(-?%d+)")
    if num then
        res = tostring(num*9/5 + 32)
        message.channel:send(res)
        log.info(0, "CtoF: " .. num .. " -> " .. res)
    else
        message.channel:send("Invalid number")
    end
end

local function FtoC(option, content, message)
    num = string.match(content, "(-?%d+)")
    if num then
        res = tostring((num-32)*5/9)
        message.channel:send(res)
        log.info(0, "CtoF: " .. num .. " -> " .. res)
    else
        message.channel:send("Invalid number")
    end
end


local function CMtoARIA(option, content, message)
    num = string.match(content, "(%d+)")
    if num then
        res = tostring(cm/160.545849385802850)
        message.channel:send(res)
        log.info(0, "CMtoARIA: " .. num .. " -> " .. res)
    else
        message.channel:send("Invalid number")
    end
end

function start()
    emitter:on("create_CMtoFT", CMtoFT)
    emitter:on("create_FTtoCM", FTtoCM)
    emitter:on("create_CtoF", CtoF)
    emitter:on("create_FtoC", FtoC)
    emitter:on("create_CMtoAria", CMtoAria)
end

function stop()
    emitter:removeListener("create_CMtoFT", CMtoFT)
    emitter:removeListener("create_FTtoCM", FTtoCM)
    emitter:removeListener("create_CtoF", CtoF)
    emitter:removeListener("create_FtoC", FtoC)
    emitter:removeListener("create_CMtoAria", CMtoAria)
end