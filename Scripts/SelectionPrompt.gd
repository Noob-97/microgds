extends Control

var CurrentSelection:Selection

@onready var prompt = $Back/Content/Situation
@onready var optionparent = $Back/Content/OptionContainer
@onready var flyingstats = get_node("/root/Main/FlyingStats")
@onready var info = get_node("/root/Main/InfoManager")
@onready var type = get_node("/root/Main/Typewriter")
@onready var back = get_node("/root/Main/MIDDLE/Back")
@onready var twitter = get_node("/root/Main/NEWS/TWITTER/Content")
@onready var timer = get_node("../Timer")
var butt = load("res://Scenes/optionbut.tscn")
var tweetnode = load("res://Scenes/tweet.tscn")
@onready var sfx: AudioStreamPlayer = $SFX

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(back.material, "shader_parameter/opacity", 0.3, 0.5)
	back.material.set_shader_parameter("offset", Vector2(0.01, 0.01))
	prompt.text = CurrentSelection.Text
	for i in CurrentSelection.Options:
		var node = butt.instantiate()
		optionparent.add_child(node)
		node.text = i.Text
		node.pressed.connect(option_exec.bind(i, node))

func option_exec(opt:Option, node:Control):
	flyingstats.get_node("MONEY").text = str(opt.MONEY * -1) + "$"
	if opt.MONEY * -1 >= 0:
		flyingstats.get_node("MONEY").text = "+" + flyingstats.get_node("MONEY").text
		flyingstats.get_node("MONEY").modulate = Color.WHITE
	elif opt.MONEY < 0:
		flyingstats.get_node("MONEY").modulate = Color.RED
	flyingstats.get_node("REP").text = str(opt.REP) + " REP."
	if opt.REP >= 0:
		flyingstats.get_node("REP").text = "+" + flyingstats.get_node("REP").text
		flyingstats.get_node("REP").modulate = Color.WHITE
	elif opt.REP < 0:
		flyingstats.get_node("REP").modulate = Color.RED
	flyingstats.get_node("POP").text = str(opt.POPULARITY) + " POP."
	if opt.POPULARITY >= 0:
		flyingstats.get_node("POP").text = "+" + flyingstats.get_node("POP").text
		flyingstats.get_node("POP").modulate = Color.WHITE
	elif opt.POPULARITY < 0:
		flyingstats.get_node("POP").modulate = Color.RED
	flyingstats.get_node("INVEST").text = str(opt.INVESTOR) + " INVEST."
	if opt.INVESTOR >= 0:
		flyingstats.get_node("INVEST").text = "+" + flyingstats.get_node("INVEST").text
		flyingstats.get_node("INVEST").modulate = Color.WHITE
	elif opt.INVESTOR < 0:
		flyingstats.get_node("INVEST").modulate = Color.RED
	
	node.disabled = true
	node.reparent(get_node(".."))
	var tween = get_tree().create_tween()
	tween.tween_property(node, "position", Vector2(0, 8), 0.75)
	tween.tween_callback(apply_changes.bind(opt, node)).set_delay(0.5)
	modulate = Color.TRANSPARENT

func apply_changes(opt:Option, node:Control):
	info.SelectionFinished.emit(CurrentSelection.ID, opt.SpecialFunctionality)
	if is_instance_valid(info.LastType):
		info.LastType.grab_focus()
	else:
		print("Last Type selected has been queued free..... but why?")
	var tween3 = get_tree().create_tween()
	tween3.tween_property(back.material, "shader_parameter/opacity", 1, 0.5)
	back.material.set_shader_parameter("offset", Vector2(0.05, 0.05))
	info.ON_SELECTION = false
	flyingstats.get_node("AnimationPlayer").play("fade")
	info.LOG_MONEY_ENTRY(opt.MONEY, opt.LogText)
	info.REP += opt.REP
	info.POPULARITY += opt.POPULARITY
	info.INVESTOR += opt.INVESTOR
	var tween2 = get_tree().create_tween()
	tween2.tween_property(type, "modulate", Color(1,1,1,0.804), 0.25)
	timer.start()
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate", Color.TRANSPARENT, 0.25)
	tween.tween_callback(node.queue_free)
	tween.tween_callback(queue_free)
	info.resume_runtime()
	if opt.Twitter != "":
		tweet(opt.Twitter)
	
func tweet(msg:String):
	var random = randi_range(0, info.UsernameArray.size() - 1)
	var node = tweetnode.instantiate()
	twitter.add_child(node)
	twitter.move_child(node, 0)
	node.get_node("msg").text = msg
	node.get_node("username").text = "[b][color=dark_gray]"+ info.UsernameArray[random] +"[/color][/b]"
	sfx.play()
	
