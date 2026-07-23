extends VBoxContainer

@export var tutorial:bool
@onready var escena_hijo = load("res://Scenes/line.tscn")
var no_lines = 0

func _ready() -> void:
	if tutorial:
		return
	for i in 2:
		no_lines += 1
		var nuevo_hijo = escena_hijo.instantiate()
		nuevo_hijo.find_child("Content").index = no_lines
		add_child(nuevo_hijo)
		nuevo_hijo.find_child("Content").config()

func new_line():
		no_lines += 1
		var nuevo_hijo = escena_hijo.instantiate()
		nuevo_hijo.find_child("Content").index = no_lines
		add_child(nuevo_hijo)
		if tutorial:
			nuevo_hijo.find_child("Content").tutorial()
		else:
			nuevo_hijo.find_child("Content").config()
		
		if not tutorial:
			for i in get_children():
				i.find_child("Content").check_availability()
