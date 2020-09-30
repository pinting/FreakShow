# Missing proprietary music files

Should be placed into `Assets/Music`.

Playlist: https://www.youtube.com/playlist?list=PLfecV2b5DItOgrSQ3Dy-3OY3Oc9zsDb73

## Part00.ogg

Cluster & Eno - Wehrmut

https://www.youtube.com/watch?v=q5mwB0LcfzY

https://music.apple.com/hu/album/cluster-eno/1185025944

Required minimum length is 5 minutes and 4 seconds

Copyright (c) 2009 Bureau B / 1977 Sky Records

## Part01.ogg

Cluster - Grosses Wasser

https://www.youtube.com/watch?v=eLkcrSmP5RA

https://music.apple.com/us/album/grosses-wasser/1184938410

Required minimum length is 18 minutes and 39 seconds

Copyright (c) 2009 Bureau B / 1979 Sky Records

## Part02.ogg

Phuture - Your Only Friend

https://www.youtube.com/watch?v=HRwOZiRFjHc

https://music.apple.com/us/album/acid-tracks-ep/885922990

Required minimum length is 4 minutes and 44 seconds

Copyright (c) 2000 Trax Records

## Part03.ogg

Neu - Sonderangebot

https://www.youtube.com/watch?v=p4fmKS8Apug

https://music.apple.com/us/album/sonderangebot/566610553

Required minimum length is 4 minutes and 51 seconds

Copyright (c) 2012 Groenland Records

# Prepare files

Copy each music file into `Assets/Music` and run the following command in the same folder to prepare them for the game engine.

```
ffmpeg -i *Wehrmut* Part00.ogg
ffmpeg -i  *Grosses\ Wasser* Part01.ogg
ffmpeg -i  *Your\ Only\ Friend* Part02.ogg
ffmpeg -i  *Sonderangebot* Part03.ogg
```

The directory where FFmpeg is installed needs to be present in the PATH variable.