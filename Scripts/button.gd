extends Button
const HOVER = preload("uid://dnay6iymj3t4a")
const BUTTON = preload("uid://cmxlqr1w1xl8d")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(hover)
	pressed.connect(button)

func hover():
	var node = AudioStreamPlayer.new()
	add_child(node)
	node.finished.connect(node.queue_free)
	node.stream = HOVER
	node.play()

func button():
	var node = AudioStreamPlayer.new()
	add_child(node)
	node.finished.connect(node.queue_free)
	node.stream = BUTTON
	node.play()
