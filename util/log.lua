local io = require('io')

p = print
local function print(indent, ...)
    for x=0, indent do
        io.write('  ')
    end
    p(...)
end

local function tprint(indent, table)

    for k,v in pairs(table) do
        for x=0, indent do
            io.write('  ')
        end
        print(k,v)
    end
end

return {
    print = print,
    tprint = tprint
}
