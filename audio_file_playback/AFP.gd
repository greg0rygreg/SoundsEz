extends PanelContainer
class_name AudioFilePlayback

@onready var current_time_label := $margineer/vercont/playtime/cur
@onready var current_time := {"hour": 0, "minute": 0, "second": 0, "msec": 0}
@onready var current_time_slider := $margineer/vercont/timeslider
@export var playback: AudioStreamPlayer
@export var track_label: Label
@export var looping: CheckBox
@export var volume: SpinBox
var dragging := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  var time := Time.get_time_dict_from_unix_time(playback.stream.get_length())
  time["msec"] = wrapf(playback.stream.get_length(), 0, 1) * 100
  current_time_slider.max_value = playback.stream.get_length()
  $margineer/vercont/playtime/max.text = "%d:%s%d:%s%d.%s%d" % [
    time["hour"],
    "0" if time["minute"] < 10 else "",
    time["minute"],
    "0" if time["second"] < 10 else "",
    time["second"],
    "0" if time["msec"] < 10 else "",
    time["msec"]
  ]
  
  current_time_slider.connect("drag_started", func(): dragging = true)
  current_time_slider.connect("drag_ended", func(_changed: bool):
    if playback.stream_paused:
      playback.play(current_time_slider.value)
      playback.stream_paused = true
    else:
      playback.seek(current_time_slider.value)
    dragging = false
  )
  $margineer/vercont/ctrls/stop.connect("pressed", queue_free)
  $margineer/vercont/ctrls/pause.connect("pressed", func(): playback.stream_paused = !playback.stream_paused)
  
  playback.volume_linear = volume.value / 100
  volume.connect("value_changed",
    func(value: float): playback.volume_linear = value / 100
  )

func _on_playback_finished() -> void:
  if looping.button_pressed:
    playback.play()
  else: queue_free()

func _process(_delta: float) -> void:
  current_time = Time.get_time_dict_from_unix_time(playback.get_playback_position())
  current_time["msec"] = wrapf(playback.get_playback_position(), 0, 1) * 100
  current_time_label.text = "%d:%s%d:%s%d.%s%d" % [
    current_time["hour"],
    "0" if current_time["minute"] < 10 else "",
    current_time["minute"],
    "0" if current_time["second"] < 10 else "",
    current_time["second"],
    "0" if current_time["msec"] < 10 else "",
    current_time["msec"]
  ]
  if !dragging:
    current_time_slider.value = playback.get_playback_position()
