extends MarginContainer

@onready var brain := get_tree().current_scene
@onready var outputs_button := $vercont/setstabs/general/vercont/outs/OptionButton
@onready var theme_toggle := $vercont/setstabs/general/vercont/theme/CheckButton
  
func _on_visibility_changed() -> void:
  if !visible: return
  theme_toggle.button_pressed = brain.get_node("theme").visible
  outputs_button.clear()
  brain.outputs = AudioServer.get_output_device_list()
  for out in brain.outputs:
    outputs_button.add_item(out)
  outputs_button.select(brain.outputs.find(AudioServer.output_device))

func __ready() -> void:
  theme_toggle.button_pressed = brain.data["lightmode"]
  print(OS.get_user_data_dir())
  applysets()
  visibility_changed.connect(_on_visibility_changed)

func applysets():
  brain.get_node("theme").visible = theme_toggle.button_pressed
  AudioServer.output_device = outputs_button.get_item_text(outputs_button.selected)

func _ready() -> void:
  call_deferred("__ready")

func _on_apply_pressed() -> void:
  brain.data["lightmode"] = theme_toggle.button_pressed
  applysets()

func _on_reset_pressed() -> void:
  theme_toggle.button_pressed = false
  outputs_button.select(0)

func _notification(what: int) -> void:
  if what == NOTIFICATION_WM_CLOSE_REQUEST:
    var temp := FileAccess.open("user://conf.json", FileAccess.WRITE)
    temp.store_string(JSON.stringify(brain.data, "  "))
    temp.close()
