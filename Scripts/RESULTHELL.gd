extends Node2D

@onready var price: Label = $PURCHASES/PRICE
@onready var price2: Label = $BUYERS/PRICE
@onready var price3: Label = $INVESTOR/PRICE
@onready var rep: Label = $BUYERS/REP
@onready var investor: Label = $INVESTOR/INVESTOR
@onready var v_1: Label = $INVESTOR/v1
@onready var v_2: Label = $INVESTOR/v2
@onready var pop: Label = $BUYERS/POP
@onready var willing: Label = $BUYERS/WILLING
@onready var buyers: Label = $PURCHASE/Value
@onready var v_3: Label = $PURCHASES/v3
@onready var v_4: Label = $PURCHASES/v4
@onready var bonus: Label = $PURCHASES/BONUS
@onready var costs: Label = $FINAL/COSTS
@onready var finalscore: Label = $FINAL/FINALSCORE
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var earn: Label = $TOTAL/EARN

var CurrentNode: Label
var wdollar = false
var val = 0
var step = 0
var dict

func _ready() -> void:
	price.text = "x " + str(Tracker.GAMEPRICE) + "$"
	price2.text = str(Tracker.GAMEPRICE)
	price3.text = "x " + str(Tracker.GAMEPRICE) + "$"
	rep.text = str(Tracker.GAMEREPUTATION)
	dict = Tracker.calculate_result()
	animation_player.play("results")

func _process(delta: float) -> void:
	if CurrentNode == null:
		return
	if wdollar:
		CurrentNode.text = str(val) + "$"
	else:
		CurrentNode.text = str(val)

func increment_value(value:int, target:Label, dollar:bool, addearn:bool):
	if target == earn:
		val = int(earn.text.replace("$",""))
	else:
		val = 0
	CurrentNode = target
	wdollar = dollar
	var tween = get_tree().create_tween()
	tween.tween_property(self, "val", value, 1)
	if addearn:
		tween.tween_callback(increment_value.bind(int(earn.text.replace("$","")) + value, earn, true, false))
	

func anim_step():
	match step:
		0:
			increment_value(Tracker.INVESTOR, investor, false, false)
		1:
			increment_value(dict["v1"], v_1, true, true)
		2:
			increment_value(dict["v2"], v_2, true, true)
		3:
			increment_value(Tracker.POPULARITY, pop, false, false)
		4:
			increment_value(dict["WILLING TO PAY"], willing, false, false)
		5:
			increment_value(dict["PURCHASE"], buyers, false, false)
		6:
			increment_value(dict["v3"], v_3, true, true)
		7:
			if Tracker.MICROTRANSACTIONS:
				v_4.modulate = Color.WHITE
				increment_value(dict["v4"], v_4, true, true)
		8:
			increment_value(dict["CONTENT BONUS"], bonus, true, true)
		9:
			increment_value(Tracker.COSTS, costs, true, false)
		10:
			if dict["EARNINGS"] < 0:
				finalscore.modulate = Color.INDIAN_RED
			increment_value(dict["EARNINGS"], finalscore, true, false)
	step += 1

func play_again():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func quit():
	get_tree().quit()

func mainmenu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
