extends MarginContainer

@onready var brain := get_tree().current_scene
@onready var outputs_button := $vercont/setstabs/general/vercont/outs/OptionButton
@onready var theme_toggle := $vercont/setstabs/general/vercont/theme/CheckButton
@onready var tts_warn := $vercont/setstabs/general/vercont/ttswarn
@onready var searchtech := $vercont/setstabs/soundpad/vercont/search/OptionButton
@onready var searchcase := $vercont/setstabs/soundpad/vercont/search/CheckBox
  
func _on_visibility_changed() -> void:
  if !visible: return
  theme_toggle.button_pressed = brain.conf.get_value("General", "lightmode", false)
  tts_warn.button_pressed = brain.conf.get_value("General", "ttswarn", false)
  searchtech.select(brain.conf.get_value("Soundpad", "searchtype", 0))
  searchcase.button_pressed = brain.conf.get_value("Soundpad", "searchcase", true)
  outputs_button.clear()
  brain.outputs = AudioServer.get_output_device_list()
  for out in brain.outputs:
    outputs_button.add_item(out)
  outputs_button.select(brain.outputs.find(AudioServer.output_device))

func __ready() -> void:
  print(OS.get_user_data_dir())
  applysets()
  visibility_changed.connect(_on_visibility_changed)

func applysets():
  brain.get_node("theme").visible = theme_toggle.button_pressed
  AudioServer.output_device = outputs_button.get_item_text(outputs_button.selected)

func _ready() -> void:
  call_deferred("__ready")

func _on_apply_pressed() -> void:
  brain.conf.set_value("General", "lightmode", theme_toggle.button_pressed)
  brain.conf.set_value("General", "ttswarn", tts_warn.button_pressed)
  brain.conf.set_value("Soundpad", "searchtype", searchtech.selected)
  brain.conf.set_value("Soundpad", "searchcase", searchcase.button_pressed)
  applysets()

func _on_reset_pressed() -> void:
  theme_toggle.button_pressed = false
  tts_warn.button_pressed = false
  outputs_button.select(0)
  searchtech.select(0)
  searchcase.button_pressed = true

func _notification(what: int) -> void:
  if what == NOTIFICATION_WM_CLOSE_REQUEST:
    brain.conf.save("user://conf.ini")
