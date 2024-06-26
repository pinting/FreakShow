#!/bin/bash

export PATH=$PATH:$(pwd)/bin

ffmpeg -i *Circle\ of\ Light* Assets/Music/Part00.ogg
rm *Circle\ of\ Light*

if [ ! -f Assets/Music/Part00.ogg ]; then
    cp Assets/Music/Part00.ogg.sample Assets/Music/Part00.ogg
fi

ffmpeg -i *Wehrmut* Assets/Music/Part01.ogg
rm *Wehrmut*

if [ ! -f Assets/Music/Part01.ogg ]; then
    cp Assets/Music/Part01.ogg.sample Assets/Music/Part01.ogg
fi

ffmpeg -y -i  *Grosses\ Wasser* Assets/Music/Part01.ogg
rm *Grosses\ Wasser*

if [ ! -f Assets/Music/Part01.ogg ]; then
    cp Assets/Music/Part01.ogg.sample Assets/Music/Part01.ogg
fi

ffmpeg -y -i  *Your\ Only\ Friend* Assets/Music/Part03.ogg
rm *Your\ Only\ Friend*

if [ ! -f Assets/Music/Part03.ogg ]; then
    cp Assets/Music/Part03.ogg.sample Assets/Music/Part03.ogg
fi