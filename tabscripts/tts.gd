extends MarginContainer

@onready var brain := get_tree().current_scene

@onready var tts_history: ItemList = $horcont/vercont2/hist
@onready var tts_text: TextEdit = $horcont/vercont2/text

var rprocs: Array[int] = []

func play_tts(text: String, pitch: int, volume: int, speed: int):
  var pid := OS.create_process("espeak-ng", [
    "-p", # pitch
    pitch,
    "-s", # speed
    speed,
    "-a", # volume
    volume,
    "-d", # device
    AudioServer.output_device,
    "-v", # voice
    "%s+%s" % [
      $horcont/vercont/langs.get_item_text($horcont/vercont/langs.get_selected_items()[0]),
      $horcont/vercont/vars.get_item_text($horcont/vercont/vars.get_selected_items()[0])
    ],
    text
  ])
  print(pid)
  if pid == -1:
    EasyNotify.add_notification({
      "title": "Uh...oh!",
      "message": "espeak-ng couldn't speak for some reason...",
      "duration": 5.0
    })
  else: rprocs.append(pid)

func _notification(what: int) -> void:
  if what == NOTIFICATION_WM_CLOSE_REQUEST:
    for proc in rprocs:
      OS.kill(proc)
    rprocs.clear()
    brain.data["tts"]["volume"] = $horcont/vercont/ctrls/volume/SpinBox.value
    brain.data["tts"]["pitch"] = $horcont/vercont/ctrls/pitch/SpinBox.value
    brain.data["tts"]["wpm"] = $horcont/vercont/ctrls/rate/SpinBox.value

func __ready() -> void:
  if OS.execute("espeak-ng", ["-h"]) != 0:
    printerr("espeak-ng not detected: no TTS!")
    EasyNotify.add_notification({
      "title": "Uh...oh!",
      "message": "espeak-ng was not detected on your system:\nTTS functionality has been disabled",
      "duration": 3
    })
    brain.tabs.set_tab_disabled(0, true)
    brain.tabs.current_tab = 1
  $horcont/vercont2/audio/stop.connect("pressed", func():
    for proc in rprocs:
      OS.kill(proc)
    rprocs.clear()
  )
  $horcont/vercont2/clear.connect("pressed", tts_history.clear)
  $horcont/vercont/langs.select(0)
  $horcont/vercont/vars.select(0)
  $horcont/vercont/ctrls/volume/SpinBox.value = brain.data["tts"]["volume"]
  $horcont/vercont/ctrls/pitch/SpinBox.value = brain.data["tts"]["pitch"]
  $horcont/vercont/ctrls/rate/SpinBox.value = brain.data["tts"]["wpm"]

func _ready() -> void:
  call_deferred("__ready") # godot rapes my plans if i don't defer the call

func _on_play_pressed() -> void:
  var moved := false
  var text := tts_text.placeholder_text if !tts_text.text else tts_text.text
  for itemid in range(0, tts_history.item_count):
    if tts_history.get_item_text(itemid) == text:
      tts_history.move_item(itemid, 0)
      moved = true
  if !moved:
    tts_history.move_item(tts_history.add_item(text), 0)
  play_tts(
    $horcont/vercont2/text.text if $horcont/vercont2/text.text else $horcont/vercont2/text.placeholder_text,
    $horcont/vercont/ctrls/pitch/SpinBox.value,
    $horcont/vercont/ctrls/volume/SpinBox.value,
    $horcont/vercont/ctrls/rate/SpinBox.value
  )

func _on_hist_item_activated(index: int) -> void:
  play_tts(
    tts_history.get_item_text(index),
    $horcont/vercont/ctrls/pitch/SpinBox.value,
    $horcont/vercont/ctrls/volume/SpinBox.value,
    $horcont/vercont/ctrls/rate/SpinBox.value
  )
  tts_history.move_item(index, 0)
  
func _process(_delta: float) -> void:
  for proc in rprocs:
    if !OS.is_process_running(proc):
      rprocs.erase(proc)
