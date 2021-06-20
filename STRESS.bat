@echo off

:start
start /B godot -w --position 100,100 --resolution 480x270
start /B godot -w --position 580,370 --resolution 480x270
start /B godot -w --position 580,100 --resolution 480x270
start /B godot -w --position 100,370 --resolution 480x270
timeout /T 60
taskkill /F /IM godot.exe
timeout /T 5
goto:start