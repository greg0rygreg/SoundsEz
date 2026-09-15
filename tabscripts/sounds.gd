extends MarginContainer

@onready var brain := get_tree().current_scene
@onready var filelist := $horcont/files/list
@onready var playlist := $horcont/player/playing/scrollcont/margineer/vercont
@onready var afp_scn: PackedScene = load("res://audio_file_playback/audio_file_playback.tscn")

var being_grabbed := false

func _notification(what: int) -> void:
  if what == NOTIFICATION_WM_CLOSE_REQUEST:
    brain.data["sounds"]["volume"] = $horcont/player/next/volume.value
    brain.data["sounds"]["loop"] = $horcont/player/next/loop.button_pressed

func reload_filelist():
  filelist.clear()
  for file: String in brain.data["files"]:
    filelist.add_item(file)

func __ready():
  $horcont/files/actions/add.connect("pressed", brain.get_node("newaf").popup_centered)
  $horcont/files/actions/reload.connect("pressed", reload_filelist)
  $horcont/player/next/volume.value = brain.data["sounds"]["volume"]
  $horcont/player/next/loop.button_pressed = brain.data["sounds"]["loop"]
  reload_filelist()

func _ready() -> void:
  call_deferred("__ready")

func _on_newaf_files_selected(paths: PackedStringArray) -> void:
  for path in paths:
    match path.get_extension():
      "wav", "mp3", "ogg":
        if path not in brain.data["files"]:
          brain.data["files"].append(path)
      _:
        EasyNotify.add_notification({
          "title": "Did not import:",
          "message": "%s" % path,
          "duration": 2
        })
  reload_filelist()

func _on_rem_pressed() -> void:
  brain.data["files"] = brain.data["files"].filter(
    func(file):
      var temp := []
      for x in filelist.get_selected_items():
        temp.append(filelist.get_item_text(x))
        for y: AudioFilePlayback in playlist.get_children():
          if y.track_label.text == filelist.get_item_text(x):
            y.queue_free()
      return not file in temp
  )
  reload_filelist()

func _on_list_item_activated(_index: int) -> void:
  for index in filelist.get_selected_items():
    var temp: AudioFilePlayback = afp_scn.instantiate()
    var stream_temp: AudioStream
    var fail := false
    match filelist.get_item_text(index).get_extension():
      "wav":
        stream_temp = AudioStreamWAV.load_from_file(filelist.get_item_text(index))
      "ogg":
        stream_temp = AudioStreamOggVorbis.load_from_file(filelist.get_item_text(index))
      "mp3":
        stream_temp = AudioStreamMP3.load_from_file(filelist.get_item_text(index))
      _:
        EasyNotify.add_notification({
          "title": "what the fuck",
          "message": "i ain't loading ts gng",
          "duration": 2
        })
        fail = true
    
    if !fail:
      temp.playback.stream = stream_temp
      temp.track_label.text = filelist.get_item_text(index)
      temp.looping.button_pressed = $horcont/player/next/loop.button_pressed
      temp.volume.value = $horcont/player/next/volume.value
      playlist.add_child(temp)

func _on_ohno_pressed() -> void:
  for y: AudioFilePlayback in playlist.get_children():
    y.volume.value = $horcont/player/next/volume.value
    y.looping.button_pressed = $horcont/player/next/loop.button_pressed

func _on_pauseall_pressed() -> void:
  for y: AudioFilePlayback in playlist.get_children():
    y.playback.stream_paused = true

func _on_resumeall_pressed() -> void:
  for y: AudioFilePlayback in playlist.get_children():
    y.playback.stream_paused = false

func _on_stopall_pressed() -> void:
  for y: AudioFilePlayback in playlist.get_children():
    y.queue_free()
