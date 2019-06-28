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