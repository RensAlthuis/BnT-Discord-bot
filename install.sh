curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh &&
./lit install SinisterRectus/discordia

curl -L https://raw.githubusercontent.com/Cluain/Lua-Simple-XML-Parser/master/xmlSimple.lua > deps/xmlSimple.lua.temp
tail -n +2 deps/xmlSimple.lua.temp > deps/xmlSimple.lua
echo "
return {
    newParser = newParser,
    newNode = newNode
}
" >> deps/xmlSimple.lua
rm deps/xmlSimple.lua.temp