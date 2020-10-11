# FreakShow

A video game experiment with photo based assets.

## Preview

<img src="https://github.com/pinting/FreakShow/raw/master/screenshot.png" width="600" />

Watch a [recording](https://youtu.be/SdWDLyBJdVU) about the latest gameplay elements.

## Setup

The game was imagined based on a selection of music tracks - however, I do not own the rights to include them with the assets thus it is the duty of the end user to provide the necessary files to the engine. They can be purchased for personal usage through popular 3rd party services.

* Clone or download the repository.
* _(optional)_ Place [the missing proprietary music tracks](docs/Music.md) into the project folder.
* Run `./setup.sh` to prepare the project. This command will convert and move all the proprietary music tracks into the `Assets/Music` directory. If they are not present, the attached sample (`.ogg.sample`) tracks will be used.
* Open the project file with [Godot Editor](https://godotengine.org/) `3.2.x`. Importing the assets will take a couple of minutes.
* Select `Project` -> `Export`.
* Click on `Export All`.
* The DMG and EXE application files will be placed into the `out` directory.

## Credits

* Diana Baranyi - photo assets
* Zsofi Szabo - photo assets
* Babett Farkas - photo assets
* Gergo Tornyi - photo assets, character actor
* Zsuzsa Buka - photo assets, drawings
* Jozsef Koller - animation interpolation
* Xavier Gómez Gosálbez - CRT shader
* Nathan Lovato - fog shader
* Godot Engine - engine, shaders, sprites of particles
* Denes Tornyi - scripting, custom shaders, photo assets, character actor

Thank you for the musical inspiration to the following artists (or group of artists).

* Part00 - Cluster & Eno
* Part01 - Cluster
* Part02 - Phuture
* Part03 - Neu
* Part04 - Booka Shade
* Part05 - Pye Corner Audio

## License

All Rights Reserved.

Copyright (c) 2020 Dénes Tornyi.

The project is uploaded for educational purpose, to serve as an example how a game can be built. Contribution and fair use of the scripts and assets are welcomed, however, please contact me before doing so.