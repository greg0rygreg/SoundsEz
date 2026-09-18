extends PanelContainer

@onready var label := $Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  global_position = get_global_mouse_position() - Vector2(size.x / 2, size.y + 4)
