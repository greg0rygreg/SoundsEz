extends Control

@onready var tabs := $tabs
@onready var outputs: PackedStringArray
@onready var conf := FileAccess.open("user://conf.json", FileAccess.READ)

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
  
  var mdtemp := FileAccess.open("res://README.md", FileAccess.READ)
  var mdtemp_txt := mdtemp.get_as_text()
  var mdtemp_txt_split := mdtemp_txt.split("```")
  mdtemp.close()
  print(mdtemp_txt_split)
  $tabs/info/MarkdownLabel.markdown_text = mdtemp_txt_split[0] + "(codeblocks aren't supported by MarkdownLabel, check it from [Github](https://github.com/greg0rygreg/SoundsEz#linux))" + mdtemp_txt_split[2]
