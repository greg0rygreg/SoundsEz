extends MarginContainer

@onready var brain := get_tree().current_scene
@onready var filelist := $horcont/files/toplay/scrollcont/margineer/vercont
@onready var playlist := $horcont/player/playing/scrollcont/margineer/vercont
@onready var afp_scn: PackedScene = load("res://audio_file_playback/audio_file_playback.tscn")
@onready var afs_scn: PackedScene = load("res://audio_file_selection/audio_file_selection.tscn")

var fuzzy := FuzzySearch.new()
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

# clunky. Ew
func shift_array(array: Array, from: int, to: int):
  from = wrapi(from, 0, len(array))
  to = wrapi(to, 0, len(array))
  var temp = array[from]
  array[from] = array[to]
  array[to] = temp

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
    temp.curtime_floating = brain.get_node("cur_time")
    playlist.add_child(temp)
    temp.playback.stream_paused = $horcont/player/next/pause.button_pressed

func add_new_to_fl(file: String):
  var temp := afs_scn.instantiate()
  temp.trackname_label.text = file
  temp.playbutton.connect("pressed", add_new_to_pl.bind(temp.trackname_label.text))
  temp.mvup.connect("pressed", func():
    shift_array(files, files.find(temp.trackname_label.text), files.find(temp.trackname_label.text)-1)
    filelist.move_child(temp, wrapi(
        temp.get_index()-1,
        0,
        len(filelist.get_children())
      )
    )
  )
  temp.mvdown.connect("pressed", func():
    shift_array(files, files.find(temp.trackname_label.text), files.find(temp.trackname_label.text)+1)
    filelist.move_child(temp, wrapi(
        temp.get_index()+1,
        0,
        len(filelist.get_children())
      )
    )
  )
  temp.rembutton.connect("pressed", func():
    files.erase(temp.trackname_label.text)
    temp.queue_free()
    for y: AudioFilePlayback in playlist.get_children():
      if y.track_label.text == temp.trackname_label.text:
        y.queue_free()
  )
  filelist.add_child(temp)

func reload_filelist():
  for file: AudioFileSelection in filelist.get_children():
    filelist.remove_child(file)
    file.queue_free()
  for file: String in files:
    add_new_to_fl(file)
  print("Total files: ", len(filelist.get_children()))

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
    brain.tabs.current_tab = 3
  else:
    files = JSON.parse_string(temp_AF.get_as_text())
    temp_AF.close()
  
  if !OS.has_feature("editor"):
    files = files.filter(func(x: String): return !x.begins_with("res://"))
  files = files.filter(func(x: String): return FileAccess.file_exists(x))

  $horcont/files/pl_actions/add.connect("pressed", brain.get_node("newaf").popup_centered)
  $horcont/files/pl_actions/reload.connect("pressed", reload_filelist)
  get_tree().root.files_dropped.connect(_on_newaf_files_selected)
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
          add_new_to_fl(path)
      _:
        EasyNotify.add_notification({
          "title": "Oops! Did not import:",
          "message": "%s" % path,
          "duration": 2
        })

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
  var target := new_text if brain.conf.get_value("Soundpad", "searchcase", true) else new_text.to_lower()
  for x: AudioFileSelection in filelist.get_children():
    if target == "": x.show()
    else:
      var shooter := x.trackname_label.text \
        if brain.conf.get_value("Soundpad", "searchcase", true) \
        else x.trackname_label.text.to_lower()
      match brain.conf.get_value("Soundpad", "searchtype", 0):
        0:
          if fuzzy.search(target, shooter) != null: x.show()
          else: x.hide()
        1:
          if target.is_subsequence_of(shooter): x.show()
          else: x.hide()
        2:
          if shooter.begins_with(target): x.show()
          else: x.hide()
        3:
          if target in shooter: x.show()
          else: x.hide()

func _on_pl_search_submitted(new_text: String) -> void:
  var target := new_text if brain.conf.get_value("Soundpad", "searchcase", true) else new_text.to_lower()
  for y: AudioFilePlayback in playlist.get_children():
    if new_text == "": y.show()
    else:
      var shooter := y.track_label.text \
        if brain.conf.get_value("Soundpad", "searchcase", true) \
        else y.track_label.text.to_lower()
      match brain.conf.get_value("Soundpad", "searchtype", 0):
        0:
          if fuzzy.search(target, shooter) != null: y.show()
          else: y.hide()
        1:
          if target.is_subsequence_of(shooter): y.show()
          else: y.hide()
        2:
          if shooter.begins_with(target): y.show()
          else: y.hide()
        3:
          if target in shooter: y.show()
          else: y.hide()
