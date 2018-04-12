local commandLoader = require('./commandLoader.lua')
local funcList ={}

funcList['triggers'] = function(content)
    for k, v in pairs(optionList) do
        print(k)
    end
end

funcList['loadCommand'] = function(content)
   commandLoader.loadCommand(content)
   print("end\n")
end
funcList['l'] = funcList['loadCommand']


funcList['exec'] = function(content)
    if #content  == 0 then
        for k,v in pairs(optionList) do
            print(k,v)
        end
    else
        if optionList[content] then
            if optionList[content].run then
                status, res = pcall(optionList[content].run)
                if not status then
                    print(res)
                end
            end
        end
    end
end

local function userInputHandler(...)
    local option, content = string.match(..., "(%g*)%s?(.*)\n", 1)
    if funcList[option] then
        funcList[option](content)
    end
end

return {userInputHandler = userInputHandler}
