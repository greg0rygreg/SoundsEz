# 🔊 SoundsEz
FOS (Free and Open Source) AiO Solution for micspamming TTS and Sounds/Music

Originally called SAM2PWSP and made to route SAM output to PipeWire Soundpad, inspired by Tarasov Aleksandr's [PipeWire Soundpad](https://github.com/arabianq/pipewire-soundpad) and Sebastian Macke's [Software Automatic Mouth](https://github.com/s-macke/SAM)

itch.io link: https://greg0rygreg.itch.io/soundsez

Made with L❤️VE by G.T. Greg Games

# Features
- TTS
- Multiplatform (Linux, Windows)
- Sound management
- Light mode (for whoever)
- FitnessGram Pacer Test™ Transcription

# why?
I'm greedy and I need TTS and soundpad in one program ONLY

# Big thanks
- IUXGames for [EasyNotify](https://godotengine.org/asset-library/asset/5073): https://github.com/IUXGames/EasyNotify
- Daenvil *et al.* for [MarkdownLabel](https://store.godotengine.org/asset/daenvil/markdownlabel/): https://github.com/daenvil/MarkdownLabel
- eSpeak NG Team for [espeak-ng](https://sourceforge.net/app/espeak-ng/): https://github.com/espeak-ng/espeak-ng
- Godot Team for the [Godot Game Engine](https://godotengine.org): https://github.com/godotengine/godot/

# How 2 install
## Simple (pre-compiled binaries, unlatest but stablest)
1. Go to latest release
2. Download for your OS
3. done

## Advanced (compiling from source, latest but unstablest)
### Windows
1. Install [Git](https://git-scm.com/install/windows) and download the [Godot Game Engine](https://godotengine.org/download/windows)

2. Open Godot, go online, make an empty project, download the Windows export templates and close Godot (you can delete the project you made)

3. Put Godot in your desktop and run these Command Prompt/PowerShell/Terminal lines on your desktop (replace Godot-version with the Godot version you downloaded)
```cmd
git clone https://github.com/greg0rygreg/SoundsEz.git
.\Godot-version --export-release win64 SoundsEz\project.godot SoundsEz.zip
```

### Linux
1. Install the `godot` and `git` packages using your distro's package manager

On Arch, it should be something like this:
```sh
sudo pacman -S godot git
```

2. Open Godot, go online, make an empty project, download the Linux export templates and close Godot (you can delete the project you made)

3. Run these shell lines on your desktop
```sh
git clone https://github.com/greg0rygreg/SoundsEz.git
godot --export-release linux SoundsEz/project.godot SoundsEz.zip
```

# Troubleshooting
## Windows
### VCRUNTIMEXXX errors
Install Visual C++ Redistributable (lastest worked for me (in a VM))

### 'espeak-ng not detected'
install it dude what are you doing

## Linux
### 'espeak-ng not detected'
install it dude what are you doing

# Mentionables
## Windows
Install VB-Audio Cable to be able to micspam to apps or something idk

## Linux
Install pactl (pulseaudio-utils for every distro on [command-not-found.com](https://command-not-found.com/pactl) except Arch which is libpulse), SoundsEz will automatically generate a sink on startup

# TODO
- [x] Make this readme pretty
- [ ] Fix some languages not being compatible with some variants
- [x] Make settings tab pretty

# Screenies
![text to speech](screenshots/tts.png)
![soundpad](screenshots/soundpad.png)
