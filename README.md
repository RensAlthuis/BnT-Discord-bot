# BnT-Discord-bot
BnT bot was made for the BooksAndTea discord server. If you like books you are most welcome to join (just google us!)<br/>
If you just like the functionality, feel free to host a copy of the bot on your own. Although the code is a work in progress, expect bugs.

## How to Use
Based on SinisterRectus' Discordia API: https://github.com/SinisterRectus/Discordia

Run ``./install.sh``
Run with: ``./luvit bot.lua keyfile``

where keyfile is a file containing your bots client-secret.
Make sure it's all on 1 line and ends on a newline


### TODO
- Reimplement UI
- Extract need for emitter from modules, prefer return list of functions/events
- Key loader utility
- Add json settings
- settings will allow for: max log length, separate errorlog, no more file Discord key, etc.
- maybe some meta data for modules as a file?
