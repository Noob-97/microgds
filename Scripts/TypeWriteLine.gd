extends VBoxContainer

var info
var sprite
var is_tutorial:bool = false

@onready var sample = $LineToWrite
@onready var response = $TextEdit
var good = load("res://SFX/good.mp3")
var bad = load("res://SFX/bad.mp3")
var index

var random
var subdivisions: Array[int]

func config() -> void:
	get_node("../Index").text = str(index)
	info = get_node("/root/Main/InfoManager")
	sprite = get_node("/root/Main/MIDDLE/Worker")
	random = randi_range(0, info.CodeArray.size() - 1)
	sample.text = info.CodeArray[random]
	substring_text()
	
	if index != info.CurrentLine:
		response.editable = false

func tutorial():
	is_tutorial = true
	get_node("../Index").text = str(index)
	sprite = get_node("/root/Main/MIDDLE/Worker")
	sample.text = 'print("Being a SuperCool Games developer is so fun!")'
	substring_text()
	

func substring_text():
	var current_text = sample.text
	var char
	
	for i in 5:
		# ¡CRÍTICO! Reiniciar search_char a 0 al cambiar de tipo de carácter
		var search_char = 0 
		match i:
			0:
				char = "."
			1:
				char = " "
			2:
				char = ","
			3:
				char = "("
			4:
				char = "_"
				
		while not current_text.find(char, search_char) == -1:
			var index_found = current_text.find(char, search_char)
			subdivisions.append(index_found)
			search_char = index_found + 1
	
	# Opcional pero muy recomendado: ordenar los índices cronológicamente 
	# para que el bucle de coloreado funcione de izquierda a derecha.
	subdivisions.sort()

func check_text_state():
	if not is_tutorial:
		if info.ON_SELECTION:
			return
	
	# SPRITE ANIMATION
	if sprite.frame == 80:
		sprite.frame = 0
	else:
		sprite.frame += 1
	
	# Limpiamos las etiquetas anteriores
	sample.text = sample.text.replace("[color=#3dcaff]", "")
	sample.text = sample.text.replace("[/color]", "")
	
	var target = null
	for i in subdivisions.size():
		if response.text.length() < subdivisions[i]:
			target = i
			break
			
	# --- Lógica de Inserción Protegida y Corregida ---
	if target == 0:
		sample.text = sample.text.insert(0, "[color=#3dcaff]")
		# Como insertamos la apertura en 0, el cierre se desplaza exactamente 15 caracteres
		sample.text = sample.text.insert(subdivisions[target] + 15, "[/color]")
		
	elif target == null:
		# Si se superaron los límites, pintamos todo hasta el último punto de subdivisión conocido
		if subdivisions.size() > 0:
			var pos_apertura = subdivisions[subdivisions.size() - 1]
			sample.text = sample.text.insert(pos_apertura, "[color=#3dcaff]")
			sample.text += "[/color]"
			
	else:
		# Obtenemos las posiciones originales
		var pos_inicio = subdivisions[target - 1]
		var pos_fin = subdivisions[target]
		
		# Insertamos el primero
		sample.text = sample.text.insert(pos_inicio, "[color=#3dcaff]")
		# Al insertar el primero, la posición de fin se empuja 15 caracteres a la derecha
		sample.text = sample.text.insert(pos_fin + 15, "[/color]")

	# --- Validación de Errores al teclear ---
	var expected = sample.text.replace("[color=#3dcaff]", "")
	expected = expected.replace("[/color]", "") # Nos aseguramos de limpiar ambos
	expected = expected.substr(0, response.text.length())
	
	if response.text != expected:
		response.modulate = Color.INDIAN_RED
		if not is_tutorial:
			info.LOG_MONEY_ENTRY(50, "FOUND CODE NOT WORKING")
	else:
		response.modulate = Color.WHITE
	
func _input(event: InputEvent) -> void:
	if not is_tutorial:
		if Input.is_action_pressed("submit") and info.CurrentLine == index:
			response.editable = false
			submit()
			
			# SPRITE ANIMATION
			if sprite.frame == 80:
				sprite.frame = 0
			else:
				sprite.frame += 1
	else:
		if Input.is_action_pressed("submit") and response.text == 'print("Being a SuperCool Games developer is so fun!")':
			response.editable = false
			sample.modulate = Color.GREEN
			var tween = get_tree().create_tween()
			tween.tween_property(sample, "modulate", Color.WHITE, 0.5)
			get_node("/root/Main/TUTORIAL").next_dialogue()
			# SPRITE ANIMATION
			if sprite.frame == 80:
				sprite.frame = 0
			else:
				sprite.frame += 1
			
			await get_tree().create_timer(1).timeout
			get_node("../..").new_line()
			get_node("..").queue_free()

func submit():
	var color
	var expected = sample.text.replace("[color=#3dcaff]", "")
	expected = expected.replace("[/color]", "") # Nos aseguramos de limpiar ambos
	#expected = expected.substr(0, response.text.length())
	if response.text != expected:
		info.LOG_MONEY_ENTRY(expected.length() * 200, "BUG FIXING TROUBLE")
		color = Color.INDIAN_RED
		get_node("SFX").stream = bad
		get_node("SFX").play()
	else:
		info.LOG_MONEY_ENTRY(expected.length(), "LINE COMPLETE PAY")
		color = Color.GREEN
		info.SuccessfulLines += 1
		get_node("SFX").stream = good
		get_node("SFX").play()
	
	sample.text = sample.text.replace("[color=#3dcaff]", "")
	sample.text = sample.text.replace("[/color]", "")
	
	sample.modulate = color
	var tween = get_tree().create_tween()
	tween.tween_property(sample, "modulate", Color.WHITE, 0.5)
	
	await get_tree().create_timer(1).timeout
	info.CurrentLine += 1
	get_node("../..").new_line()
	get_node("..").queue_free()
	
func check_availability():
	if index == info.CurrentLine:
		response.editable = true
		response.grab_focus()
	else:
		response.editable = false
