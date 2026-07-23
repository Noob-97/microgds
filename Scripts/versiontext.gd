extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "GAME VERSION: " + Game.version + " | PLATFORM: " + OS.get_name()
