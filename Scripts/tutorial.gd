extends Control

var current_dialogue = 0
@onready var typewriter: Control = %Typewriter/ScrollContainer/LinesContainer
var completed_line:bool = false

func _ready() -> void:
	Game.TUTORIAL = true

func _input(event: InputEvent) -> void:
	if not current_dialogue == 2:
		if Input.is_action_just_pressed("next_dialogue"):
			next_dialogue()

func next_dialogue():
	if current_dialogue == 9:
		Game.duration = 5
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
		return
			
	get_node("d" + str(current_dialogue)).visible = false
	get_node("d" + str(current_dialogue) + "/AUDIO").stop()
	current_dialogue += 1
	get_node("d" + str(current_dialogue)).visible = true
	get_node("d" + str(current_dialogue) + "/AUDIO").play()
	if current_dialogue == 2:
		typewriter.new_line()
