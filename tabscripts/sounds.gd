extends MarginContainer

@onready var brain := get_tree().current_scene
@onready var filelist := $horcont/files/toplay/scrollcont/margineer/vercont
@onready var playlist := $horcont/player/playing/scrollcont/margineer/vercont
@onready var afp_scn: PackedScene = load("res://audio_file_playback/audio_file_playback.tscn")
@onready var afs_scn: PackedScene = load("res://audio_file_selection/audio_file_selection.tscn")

var files: Array = []
var being_grabbed := false

func _notification(what: int) -> void:
  if what == NOTIFICATION_WM_CLOSE_REQUEST:
    #brain.data["sounds"]["volume"] = $horcont/player/next/volume.value
    #brain.data["sounds"]["loop"] = $horcont/player/next/loop.button_pressed
    brain.conf.set_value("Soundpad", "volume", $horcont/player/next/volume.value)
    brain.conf.set_value("Soundpad", "loop", $horcont/player/next/loop.button_pressed)
    var temp_AF := FileAccess.open("user://audiofiles.json", FileAccess.WRITE)
    temp_AF.store_string(JSON.stringify(files, "  "))
    temp_AF.close()

func add_new_to_pl(track: String):
  var temp: AudioFilePlayback = afp_scn.instantiate()
  var stream_temp: AudioStream
  var fail := false
  match track.get_extension():
    "wav":
      stream_temp = AudioStreamWAV.load_from_file(track)
    "ogg":
      stream_temp = AudioStreamOggVorbis.load_from_file(track)
    "mp3":
      stream_temp = AudioStreamMP3.load_from_file(track)
    _:
      EasyNotify.add_notification({
        "title": "what the fuck",
        "message": "i ain't loading ts gng",
        "duration": 2
      })
      fail = true
  
  if !fail:
    temp.playback.stream = stream_temp
    temp.track_label.text = track
    temp.looping.button_pressed = $horcont/player/next/loop.button_pressed
    temp.volume.value = $horcont/player/next/volume.value
    playlist.add_child(temp)

func reload_filelist():
  for file: AudioFileSelection in filelist.get_children():
    filelist.remove_child(file)
    file.queue_free()
  for file: String in files:
    var temp := afs_scn.instantiate()
    temp.trackname_label.text = file
    temp.playbutton.connect("pressed", add_new_to_pl.bind(temp.trackname_label.text))
    temp.rembutton.connect("pressed", func():
      files.erase(temp.trackname_label.text)
      for y: AudioFilePlayback in playlist.get_children():
        if y.track_label.text == temp.trackname_label.text:
          y.queue_free()
      reload_filelist()
    )
    filelist.add_child(temp)

func __ready():
  var temp_AF := FileAccess.open("user://audiofiles.json", FileAccess.READ)
  if !temp_AF:
    temp_AF = FileAccess.open("user://audiofiles.json", FileAccess.WRITE)
    temp_AF.store_string(JSON.stringify([]))
    temp_AF.close()
    temp_AF = FileAccess.open("user://audiofiles.json", FileAccess.READ)
  # if it's STILL telling us it's not working
  if !temp_AF:
    EasyNotify.add_notification({
      "title": "Uh...oh!",
      "message": "Couldn't read user://audiofiles.json, soundpad functionality has been disabled",
      "duration": 3
    })
    brain.tabs.set_tab_disabled(1, true)
  else:
    files = JSON.parse_string(temp_AF.get_as_text())
    temp_AF.close()
  
  if !OS.has_feature("editor"):
    files = files.filter(func(x: String): return !x.begins_with("res://"))
  files = files.filter(func(x: String): return FileAccess.file_exists(x))

  $horcont/files/pl_actions/add.connect("pressed", brain.get_node("newaf").popup_centered)
  $horcont/files/pl_actions/reload.connect("pressed", reload_filelist)
  $horcont/player/next/volume.value = brain.conf.get_value("Soundpad", "volume", 100)
  $horcont/player/next/loop.button_pressed = brain.conf.get_value("Soundpad", "loop", false)
  reload_filelist()

func _ready() -> void:
  call_deferred("__ready")

func _on_newaf_files_selected(paths: PackedStringArray) -> void:
  for path in paths:
    match path.get_extension():
      "wav", "mp3", "ogg":
        if path not in files:
          files.append(path)
      _:
        EasyNotify.add_notification({
          "title": "Oops! Did not import:",
          "message": "%s" % path,
          "duration": 2
        })
  reload_filelist()

func _on_rem_pressed() -> void:
  files = files.filter(
    func(file):
      var temp := []
      for x: AudioFileSelection in filelist.get_children():
        if !x.selected.button_pressed: continue
        temp.append(x.trackname_label.text)
        for y: AudioFilePlayback in playlist.get_children():
          if y.track_label.text == x.trackname_label.text:
            y.queue_free()
      return not file in temp
  )
  reload_filelist()

func _on_play_pressed() -> void:
  for x: AudioFileSelection in filelist.get_children():
    if !x.selected.button_pressed: continue
    add_new_to_pl(x.trackname_label.text)

func _on_ohno_pressed() -> void:
  for y: AudioFilePlayback in playlist.get_children():
    if !y.selected.button_pressed: continue
    y.volume.value = $horcont/player/next/volume.value
    y.looping.button_pressed = $horcont/player/next/loop.button_pressed

func _on_pauseall_pressed() -> void:
  for y: AudioFilePlayback in playlist.get_children():
    if !y.selected.button_pressed: continue
    y.playback.stream_paused = true

func _on_resumeall_pressed() -> void:
  for y: AudioFilePlayback in playlist.get_children():
    if !y.selected.button_pressed: continue
    y.playback.stream_paused = false

func _on_stopall_pressed() -> void:
  for y: AudioFilePlayback in playlist.get_children():
    if !y.selected.button_pressed: continue
    y.queue_free()

func _on_slc_selall_toggled(toggled_on: bool) -> void:
  for x: AudioFileSelection in filelist.get_children():
    x.selected.button_pressed = toggled_on

func _on_pl_selall_toggled(toggled_on: bool) -> void:
  for y: AudioFilePlayback in playlist.get_children():
    y.selected.button_pressed = toggled_on

func _on_slc_search_submitted(new_text: String) -> void:
  #i don't really like FuzzySearch from Godot 4.8
  for x: AudioFileSelection in filelist.get_children():
    if new_text == "": x.show()
    else:
      if new_text.to_lower().is_subsequence_of(x.trackname_label.text): x.show()
      else: x.hide()

func _on_pl_search_submitted(new_text: String) -> void:
  for y: AudioFilePlayback in playlist.get_children():
    if new_text == "": y.show()
    else:
      if new_text.to_lower().is_subsequence_of(y.track_label.text): y.show()
      else: y.hide()
