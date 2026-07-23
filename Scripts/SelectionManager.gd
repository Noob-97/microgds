extends Control

@export var game_price_option:Selection

@onready var info = %InfoManager
@onready var type = %Typewriter
@onready var timer = $Timer
var prompt = load("res://Scenes/prompt.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func new_select():
	if info.ON_SELECTION:
		return
	if info.SelectionArray.size() == 0:
		return
		
	var tween2 = get_tree().create_tween()
	tween2.tween_property(type, "modulate", Color.TRANSPARENT, 0.25)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var select = randi_range(0, info.SelectionArray.size() - 1)
	var node = prompt.instantiate()
	node.CurrentSelection = info.SelectionArray[select]
	add_child(node)
	info.ON_SELECTION = true
	info.SelectionArray.remove_at(select)
	info.stop_runtime()

func selection(selection:Selection):
	if info.ON_SELECTION:
		return
		
	var tween2 = get_tree().create_tween()
	tween2.tween_property(type, "modulate", Color.TRANSPARENT, 0.25)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var node = prompt.instantiate()
	node.CurrentSelection = selection
	add_child(node)
	info.ON_SELECTION = true
	info.stop_runtime()

func line_completed(no:int):
	if info == null:
		return
	if no == roundi(info.line_goal * 0.6):
		await get_tree().create_timer(1.05).timeout
		selection(game_price_option)

func stop_timer(bool):
	timer.stop()
