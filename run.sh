#!/bin/bash

killall luvit
luvit bot.lua bnt.key &>> log &
