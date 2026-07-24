extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var color = randf_range(0.2, 0.8)
	modulate = Color(color, color, color)
