#!/bin/bash

ffmpeg -i *Wehrmut* Assets/Music/Part01.ogg > /dev/null 2>&1
rm *Wehrmut* > /dev/null 2>&1

if [ ! -f Assets/Music/Part01.ogg ]; then
    cp Assets/Music/Part01.ogg.sample Assets/Music/Part01.ogg
fi

ffmpeg -y -i  *Grosses\ Wasser* Assets/Music/Part01.ogg > /dev/null 2>&1
rm *Grosses\ Wasser* > /dev/null 2>&1

if [ ! -f Assets/Music/Part01.ogg ]; then
    cp Assets/Music/Part01.ogg.sample Assets/Music/Part01.ogg
fi

ffmpeg -y -i  *Your\ Only\ Friend* Assets/Music/Part03.ogg > /dev/null 2>&1
rm *Your\ Only\ Friend* > /dev/null 2>&1

if [ ! -f Assets/Music/Part03.ogg ]; then
    cp Assets/Music/Part03.ogg.sample Assets/Music/Part03.ogg
fi

ffmpeg -y -i  *Sonderangebot* Assets/Music/Part04.ogg > /dev/null 2>&1
rm *Sonderangebot* > /dev/null 2>&1

if [ ! -f Assets/Music/Part04.ogg ]; then
    cp Assets/Music/Part04.ogg.sample Assets/Music/Part04.ogg
fi

ffmpeg -y -i  *Pong\ Pang* Assets/Music/Part05.ogg > /dev/null 2>&1
rm *Pong\ Pang* > /dev/null 2>&1

if [ ! -f Assets/Music/Part05.ogg ]; then
    cp Assets/Music/Part05.ogg.sample Assets/Music/Part05.ogg
fi

ffmpeg -y -i  *Sleep\ Games* Assets/Music/Part06.ogg > /dev/null 2>&1
rm *Pong\ Pang* > /dev/null 2>&1

if [ ! -f Assets/Music/Part06.ogg ]; then
    cp Assets/Music/Part06.ogg.sample Assets/Music/Part06.ogg
fi

echo "Setup complete!"