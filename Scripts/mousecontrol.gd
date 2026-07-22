extends Control

@onready var info = get_node("/root/Main/InfoManager")

func focus():
	if not info.ON_SELECTION:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		info.LastType = self

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("exitfocus"):
		defocus()

func defocus():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	release_focus()
