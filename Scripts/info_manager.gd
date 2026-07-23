extends Node

# Stadistics
var MONEY:int = 0

var REP:float = 0.5:
	set(value):
		REP = clampf(value, 0.0, 1.0)
		update_rep_ui()

var POPULARITY:int = 0:
	set(value):
		if value < 0:
			POPULARITY = 0
		else:
			POPULARITY = value
		sum_pop = true

var INVESTOR:int = 0:
	set(value):
		if value < 0:
			INVESTOR = 0
		else:
			INVESTOR = value
		sum_invest = true
		sum_earn = true

var PRICE:int = 0

# Arrays
@export var CodeArray:Array[String]
@export var SelectionArray:Array[Selection]

# Tracking Data
var CurrentLine = 1
var ON_SELECTION = false
var LastType:Node
var SuccessfulLines:int = 0:
	set(value):
		SuccessfulLines = value
		update_objective()
var SimualtedTime: int = 0
var past_deadline = false

signal LineCompleted(no:int)
signal SelectionFinished(id:String, special:String)
signal GameEnded(past:bool)

var sum_pop = false
var sum_invest = false
var sum_earn = false
var countup_step = 10
var time_step = 10
var earn_step = 30
var line_goal = 30
var game_ended = false
var microtransactions = false
var timer_tween

# References
@onready var stats_ui = %STATS
@onready var news_ui = %NEWS
@onready var money_ui = stats_ui.get_node("MONEY")
@onready var rep_ui = news_ui.get_node("REP")
@onready var pop_ui = news_ui.get_node("POPULARITY")
@onready var investor_ui = stats_ui.get_node("INVESTOR")
@onready var objective_ui = stats_ui.get_node("OBJECTIVE")
@onready var prog_ui = stats_ui.get_node("PROGRESS")
@onready var deadline_ui = stats_ui.get_node("DEADLINE")
@onready var price_ui = stats_ui.get_node("GAMEPRICE")
@onready var earn_ui = stats_ui.get_node("EARN")
@onready var back = get_node("/root/Main/MIDDLE/Back")
@onready var type = get_node("/root/Main/Typewriter")
@onready var endanim = get_node("/root/Main/EndingAnim")

@onready var moneytimer = $Moneytimer
@onready var logcontainer = stats_ui.get_node("LogContainer")
var logobj = load("res://Scenes/logitem.tscn")

func _ready() -> void:
	Game.TUTORIAL = false
	SimualtedTime = Game.duration * 10 * 3600
	timer_tween = get_tree().create_tween()
	timer_tween.tween_property(self, "SimualtedTime", 0, Game.duration * 60)
	update_rep_ui()
	prog_ui.max_value = line_goal
	update_objective()

func stop_runtime():
	timer_tween.pause()
	moneytimer.paused = true

func resume_runtime():
	timer_tween.play()
	moneytimer.paused = false

func format_seconds(total_seconds: float) -> String:
	# Convertimos a entero para descartar decimales
	var seconds_int: int = int(total_seconds)
	
	# Cálculos de tiempo
	var hours: int = abs(seconds_int / 3600)
	var minutes: int = abs((seconds_int % 3600) / 60)
	var seconds: int = abs(seconds_int % 60)
	
	# %03d asegura al menos 3 dígitos para horas (hhh)
	# %02d asegura 2 dígitos para minutos y segundos (mm y ss) con ceros a la izquierda
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func _process(delta: float) -> void:
	if not game_ended:
		if SimualtedTime <= 0:
			SimualtedTime -= time_step
		deadline_ui.text = format_seconds(SimualtedTime)
	if SimualtedTime <= 0:
		if SuccessfulLines >= line_goal:
			if not game_ended:
				back.material.set_shader_parameter("offset", Vector2(0,0))
				game_ended = true
				moneytimer.stop()
				GameEnded.emit(past_deadline)
				var tween2 = get_tree().create_tween()
				tween2.tween_property(type, "modulate", Color.TRANSPARENT, 0.25)
				var tween = get_tree().create_tween()
				tween.tween_property(back.material, "shader_parameter/opacity", 0.3, 0.5)
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				endanim.play("end")
				configtracker()
				Tracker.calculate_result()
		else:
			past_deadline = true
			deadline_ui.modulate = Color.RED
			deadline_ui.text = "-" + deadline_ui.text
			
	
	if sum_pop:
		if abs(POPULARITY -  int(pop_ui.text)) <= countup_step:
			pop_ui.text = str(POPULARITY)
			sum_pop = false
		elif int(pop_ui.text) < POPULARITY:
			pop_ui.text = str(int(pop_ui.text) + countup_step)
		elif int(pop_ui.text) > POPULARITY:
			pop_ui.text = str(int(pop_ui.text) - countup_step)
		elif int(pop_ui.text) == POPULARITY:
			sum_pop = false
	
	if sum_invest:
		if int(investor_ui.text) < INVESTOR:
			investor_ui.text = str(int(investor_ui.text) + 1)
		elif int(investor_ui.text) > INVESTOR:
			investor_ui.text = str(int(investor_ui.text) - 1)
		elif int(investor_ui.text) == INVESTOR:
			sum_invest = false
	
	if sum_earn:
		var value = PRICE * INVESTOR
		value += INVESTOR * 100
		if abs(value -  int(earn_ui.text.replace("$", ""))) <= earn_step:
			earn_ui.text = str(value) + "$"
			sum_earn = false
		elif int(earn_ui.text.replace("$", "")) < value:
			earn_ui.text = str(int(earn_ui.text.replace("$", "")) + earn_step) + "$"
		elif int(earn_ui.text.replace("$", "")) > value:
			earn_ui.text = str(int(earn_ui.text.replace("$", "")) - earn_step) + "$"
		elif int(earn_ui.text.replace("$", "")) == value:
				sum_earn = false

func loop_moneytimer():
	if not game_ended:
		LOG_MONEY_ENTRY(10, "TIME IS MONEY")
		moneytimer.start()

func LOG_MONEY_ENTRY(VALUE:int, SUBJECT:String):
	var node = logobj.instantiate()
	logcontainer.add_child(node)
	node.get_child(0).text = str(VALUE) + "$: " + SUBJECT
	var tween = get_tree().create_tween()
	node.get_child(0).scale = Vector2(1, 0)
	tween.tween_property(node.get_child(0), "scale", Vector2.ONE, 0.5)
	logcontainer.CHECK(node)
	
	MONEY += VALUE
	if MONEY > 0:
		money_ui.text = "-" + str(MONEY) + "$"
	else:
		money_ui.text = str(MONEY) + "$"
		
	if MONEY < 0:
		money_ui.modulate = Color.GREEN
	else:
		money_ui.modulate = Color.WHITE
		
func update_rep_ui():
	var final_pos = lerp(40, 240, REP)
	var tween = create_tween()
	tween.tween_property(rep_ui, "position:x", final_pos, 0.5)

func update_objective():
	objective_ui.text = str(SuccessfulLines) + "/" + str(line_goal)
	prog_ui.value = SuccessfulLines
	LineCompleted.emit(SuccessfulLines)

func check_select(id:String, special:String):
	if id == "price":
		PRICE = int(special)
		price_ui.text = str(PRICE) + "$"
		earn_ui.text = "0$"
	if special == "microtransactions":
		microtransactions = true

func configtracker():
	Tracker.COSTS = MONEY
	Tracker.GAMEPRICE = PRICE
	Tracker.GAMEREPUTATION = REP
	Tracker.INVESTOR = INVESTOR
	Tracker.LINEGOAL = line_goal
	Tracker.MICROTRANSACTIONS = microtransactions
	Tracker.POPULARITY = POPULARITY
	Tracker.SUCCESSFUL_LINES = SuccessfulLines

func end(String):
	get_tree().change_scene_to_file("res://Scenes/results.tscn")

func quit():
	get_tree().quit()
