extends Control

@onready var tabs := $tabs
@onready var outputs: PackedStringArray
@onready var conf := FileAccess.open("user://conf.json", FileAccess.READ)
var md_fix := """# 🔊 SoundsEz
FOS (Free and Open Source) AiO Solution for micspamming TTS and Sounds/Music

Inspired by Tarasov Aleksandr's [PipeWire Soundpad](https://github.com/arabianq/pipewire-soundpad) and Sebastian Macke's [Software Automatic Mouth](https://github.com/s-macke/SAM) (though this uses [espeak-ng](https://github.com/espeak-ng/espeak-ng))

itch.io link: https://greg0rygreg.itch.io/soundsez

Made with L❤️VE by G.T. Greg Games

# Features
- TTS
- Multiplatform (Linux, Windows)
- Sound management
- Light mode (for whoever)
- FitnessGram Pacer Test™ Transcription

# why?
Why NOT

# Big thanks
- Daenvil *et al.* for [MarkdownLabel](https://store.godotengine.org/asset/daenvil/markdownlabel/): https://github.com/daenvil/MarkdownLabel
- eSpeak NG Team for [espeak-ng](https://sourceforge.net/app/espeak-ng/): https://github.com/espeak-ng/espeak-ng
- Godot Game Engine Team for the [Godot Game Engine](https://godotengine.org): https://github.com/godotengine/godot/

# How 2 install
You already did it

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
"""

var data := {
  "lightmode": false,
  "files": [],
  "sounds": {
    "volume": 100,
    "loop": false
  },
  "tts": {
    "volume": 100,
    "pitch": 50,
    "wpm": 175
  }
}
var soundsez_sink_id: int = -1

func _notification(what: int) -> void:
  if what == NOTIFICATION_WM_CLOSE_REQUEST:
    OS.execute("pactl", ["unload-module", soundsez_sink_id])

func _ready() -> void:
  get_tree().root.title = "%s %s" % [
    ProjectSettings.get_setting("application/config/name"),
    ProjectSettings.get_setting("application/config/version")
  ]
  tabs.current_tab = 0
  
  print(OS.get_distribution_name())
  
  if !conf:
    var conftemp := FileAccess.open("user://conf.json", FileAccess.WRITE)
    conftemp.store_string(JSON.stringify(data))
    conftemp.close()
    conf = FileAccess.open("user://conf.json", FileAccess.READ)
  data = JSON.parse_string(conf.get_as_text())
  
  if !OS.has_feature("editor"):
    data["files"] = data["files"].filter(func(x: String): return !x.begins_with("res://"))
  data["files"] = data["files"].filter(func(x: String): return FileAccess.file_exists(x))
  
  match OS.get_name():
    "Windows":
      pass
    "Linux":
      var outtemp := []
      OS.execute("pactl", [
        "load-module",
        "module-pipe-sink",
        "sink_name='SoundsEz Audio Output'"
      ], outtemp)
      soundsez_sink_id = int(outtemp[0].strip_escapes())
    _:
      EasyNotify.add_notification({
        "title": "what the fuck",
        "message": "i don't remember compiling SoundsEz for %s" % OS.get_name(),
        "duration": 3
      })
  outputs = AudioServer.get_output_device_list()
  for out in outputs:
    tabs.get_node("sets").outputs_button.add_item(out)
  
  EasyNotify.add_notification({
    "title": "TTS warning",
    "message": "Some languages aren't compatible with some variants & vice versa",
    "duration": 3
  })
  
  $tabs/info/MarkdownLabel.markdown_text = md_fix
