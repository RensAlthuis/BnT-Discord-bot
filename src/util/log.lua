return function(path)

local io = require('io')
local logfile = io.open(path, "a+")

p = print
local function print(indent, ...)
    assert(type(indent) == "number", "tprint expects a number as first argument")

    local date = os.date("| %c | ")
    io.write(date)
    logfile:write(date)

    for x=1, indent do
        io.write('\t')
        logfile:write('\t')
    end

    local s = table.concat({...}, '\t') .. "\n"
    io.write(s)
    logfile:write(s)

    logfile:flush()
end

local function info(indent, ...)
    print(indent, "[INFO]", ...)
end

local function err(indent, ...)
    print(indent, "[ERR]", ...)
end

local function tprint(indent, table)
    assert(type(indent) == "number", "tprint expects a number as first argument")
    for k,v in pairs(table) do
        for x=0, indent do
            io.write('  ')
        end
        print(k,v)
    end
end

return {
    print = print,
    info = info,
    err = err,
    tprint = tprint
}

end