extends Node2D

@onready var main_butt: Control = $MainButt
@onready var game_butt: Control = $GameButt

func play():
	main_butt.visible = false
	game_butt.visible = true

func exit():
	get_tree().quit()
	
func tutorial():
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")

func short():
	Game.duration = 5
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func standard():
	Game.duration = 8
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func long():
	Game.duration = 12
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
