#!/bin/bash

killall luvit
luvit src/bot.lua bnt.key &>> log &
