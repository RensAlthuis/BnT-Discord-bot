local io = require('io')
local json = require('json')

birthdays = {}

local function jsonRead()
    local jsfile, err = io.open(PATH .. "birthdays.json", "r")
    if not jsfile then
        return {}
    end

    local jsonString = jsfile:read()
    local data = json.parse(jsonString)
    return data
end

local function jsonStore(data)
    local jsfile, err = io.open(PATH .. "birthdays.json", "w+")
    if not jsfile then
        error("Couldn't create json file")
    end

    local jsonString = json.stringify(birthdays)
    jsfile:write(jsonString)
end

function start()
    birthdays = jsonRead()
    log.debug(0, "BIRTHDAYS")
    print(birthdays)

    emitter:on("create_newBirthday", newBirthday)
    emitter:on("create_deleteBirthday", newBirthday)
end

function stop()
    emitter:removeListener("create_newBirthday", newBirthday)
    emitter:removeListener("create_deleteBirthday", newBirthday)
end