# FreakShow

A video game experiment with photo based assets built around emotions.

## Preview

<a href="https://www.youtube.com/watch?v=Z677WRkLmXU">
<img src="https://github.com/pinting/FreakShow/raw/master/screenshot.png" width="600" />
</a>

Watch a [recording](https://www.youtube.com/watch?v=Z677WRkLmXU) about the latest gameplay elements.

## Setup

The game was imagined based on a selection of music tracks - however, I do not own the rights to include them with the assets thus it is the duty of the end user to provide the necessary files to the engine. They can be purchased for personal usage through popular 3rd party services.

* Clone or download the repository.
* _(optional)_ Place [the missing proprietary music tracks](docs/Music.md) into the project folder. FFmpeg needs to be available system-wide or put into the bin folder of the project.
* Run `./setup.sh` to prepare the project. This command will convert and move all the proprietary music tracks into the `Assets/Music` directory. If they are not present, the attached sample (`.ogg.sample`) tracks will be used.
* Open the project file with [Godot Editor](https://godotengine.org/) `3.4.5`. Importing the assets will take a couple of minutes.
* Select `Project` -> `Export`.
* Click on `Export All`.
* The DMG and EXE application files will be placed into the `out` directory.

## Credits

* Denes Tornyi - director, programming, textures, translations, character actor
* Zsuzsa Buka - poems, translations, drawings, textures, character actor
* Gergo Tornyi - textures, translations, character actor
* Katalin Bito - textures
* Diana Baranyi - textures
* Zsofi Szabo - textures
* Babett Farkas - textures
* Janos Bito - sound effects

Thank you for the musical inspiration to the following artists (or group of artists).

* Part00 - Delia Derbyshire & Elsa Stansfield
* Part01 - Cluster & Eno
* Part02 - Cluster
* Part03 - Phuture

## License

All Rights Reserved.

Copyright (c) 2021 Dénes Tornyi.

The project is uploaded for educational purpose, to serve as an example how a game can be built around emotions. Contribution and fair use of the scripts and assets are welcomed, however, please contact me before doing so.