mkdir temp
cd temp

git clone --recursive https://github.com/luvit/luvi.git
cd luvi
make regular
make test

curl https://lit.luvit.io/packages/luvit/lit/latest.zip > lit.zip
./build/luvi lit.zip -- make lit.zip

./lit make github://luvit/luvit

cp build/luvi ../../
cp lit ../../
cp luvit ../../

cd ../..

rm -rf temp

./lit install SinisterRectus/discordia

curl -L https://raw.githubusercontent.com/Cluain/Lua-Simple-XML-Parser/master/xmlSimple.lua > deps/xmlSimple.lua.temp
tail -n +2 deps/xmlSimple.lua.temp > deps/xmlSimple.lua
echo "
return {
    newParser = newParser,
    newNode = newNode
}
" >> deps/xmlSimple.lua
#rm deps/xmlSimple.lua.temp

