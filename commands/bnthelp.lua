local function run(message, content)

    print("    send help")
    message.channel:send("BnT-Bot searches Goodreads so you don't have too.\
Use:\
!GR what you want to search\
and it'll pull the top search result from goodreads. Yes it can search author and book title, separately or together.\
Did it pull the wrong item? If you delete your search the bot will delete its response, or you could edit your search and it'll search again and change its response.");
    client:emit('messageFinished')
end

return {
    run = run,
    ['isOn'] = true
}

