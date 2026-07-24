extends AudioStreamPlayer

@export var music:Array[AudioStreamMP3]
var index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music.shuffle()
	play_new()

func play_new():
	if index > music.size() - 1:
		index = 0
		music.shuffle()
	stream = music[index]
	play()
	index += 1
