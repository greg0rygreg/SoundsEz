extends Control

@onready var tabs := $tabs
@onready var outputs := AudioServer.get_output_device_list()

var data := {
  "lightmode": false,
  "files": [],
  "volume": 1.,
  "nextvol": 1.,
  "nextloop": false
}

func _ready() -> void:
  get_tree().root.title = "%s %s" % [
    ProjectSettings.get_setting("application/config/name"),
    ProjectSettings.get_setting("application/config/version")
  ]
  
  $actions/info.connect("pressed", $info.popup_centered)
  tabs.current_tab = 0
  print(OS.get_distribution_name())
  if OS.get_name() == "Linux":
    EasyNotify.add_notification({
      "title": "You're using Linux!",
      "message": "Install %s & run this in the terminal:\npactl load-module module-null-sink" % (
        "pulseaudio-utils" if OS.get_distribution_name() not in ["Arch Linux", "Manjaro", "EndeavourOS", "CachyOS"] else "libpulse"
      ),
      "duration": 5
    })
  elif OS.get_name() == "Windows":
    EasyNotify.add_notification({
      "title": "You're using Windows!",
      "message": "Install VB-Audio Virtual Cables",
      "duration": 5
    })
  else:
    EasyNotify.add_notification({
      "title": "what the fuck",
      "message": "i don't remember compiling SoundsEz for %s" % OS.get_name(),
      "duration": 5
    })
  
  EasyNotify.add_notification({
    "title": "TTS warning",
    "message": "Some languages aren't compatible with some variants & vice versa",
    "duration": 5
  })

  # no outputs
  if len(outputs) != 0:
    for out in outputs:
      tabs.get_node("sets/vercont/outs").add_item(out)
    tabs.get_node("sets/vercont/outs").disabled = false
  else:
    EasyNotify.add_notification({
      "title": "Uh...oh!",
      "message": "No audio output was detected on your system:\nAll audio related functionality has been revoked",
      "duration": 5.0
    })
    tabs.set_tab_disabled(0, true)
    tabs.set_tab_disabled(1, true)
    tabs.set_tab_hidden(3, false)
    tabs.current_tab = 3
