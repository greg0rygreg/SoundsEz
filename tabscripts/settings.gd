extends MarginContainer

@onready var brain := get_tree().current_scene
@onready var conf := FileAccess.open("user://conf.json", FileAccess.READ)

func __ready() -> void:
  if !conf:
    var temp := FileAccess.open("user://conf.json", FileAccess.WRITE)
    temp.store_string(JSON.stringify(brain.data))
    temp.close()
    conf = FileAccess.open("user://conf.json", FileAccess.READ)
  brain.data = JSON.parse_string(conf.get_as_text())
  $vercont/theme/CheckButton.button_pressed = brain.data["lightmode"]
  $vercont/defloop/CheckBox.button_pressed = brain.data["nextloop"]
  $vercont/defvolume/SpinBox.value = brain.data["nextvol"] * 100
  if !OS.has_feature("editor"):
    brain.data["files"] = brain.data["files"].filter(func(x: String): return !x.begins_with("res://"))
  brain.data["files"] = brain.data["files"].filter(func(x: String): return FileAccess.file_exists(x))
  print(OS.get_user_data_dir())
  applysets()
    
func applysets():
  brain.get_node("theme").visible = $vercont/theme/CheckButton.button_pressed
  AudioServer.output_device = $vercont/outs.get_item_text($vercont/outs.selected)

func _ready() -> void:
  call_deferred("__ready")

func _on_apply_pressed() -> void:
  brain.data["lightmode"] = $vercont/theme/CheckButton.button_pressed
  brain.data["nextloop"] = $vercont/defloop/CheckBox.button_pressed
  brain.data["nextvol"] = $vercont/defvolume/SpinBox.value / 100
  applysets()

func _notification(what: int) -> void:
  if what == NOTIFICATION_WM_CLOSE_REQUEST:
    var temp := FileAccess.open("user://conf.json", FileAccess.WRITE)
    temp.store_string(JSON.stringify(brain.data, "  "))
    temp.close()
