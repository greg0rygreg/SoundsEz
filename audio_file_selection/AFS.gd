extends PanelContainer
class_name AudioFileSelection

@export var tracklen_label: Label
@export var selected: CheckBox
@export var trackname_label: Label
@onready var stream_temp: AudioStream
@export var playbutton: Button
@export var rembutton: Button

func __ready():
  var time := Time.get_time_dict_from_unix_time(stream_temp.get_length())
  time["msec"] = wrapf(stream_temp.get_length(), 0, 1) * 100
  tracklen_label.text = "%d:%s%d:%s%d.%s%d" % [
    time["hour"],
    "0" if time["minute"] < 10 else "",
    time["minute"],
    "0" if time["second"] < 10 else "",
    time["second"],
    "0" if time["msec"] < 10 else "",
    time["msec"]
  ]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  match trackname_label.text.get_extension():
    "wav":
      stream_temp = AudioStreamWAV.load_from_file(trackname_label.text)
    "ogg":
      stream_temp = AudioStreamOggVorbis.load_from_file(trackname_label.text)
    "mp3":
      stream_temp = AudioStreamMP3.load_from_file(trackname_label.text)
    _:
      queue_free()
  call_deferred("__ready")
