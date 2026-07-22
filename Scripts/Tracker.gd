extends Node

var COSTS:int 
var INVESTOR:int
var POPULARITY:int 
var GAMEPRICE:int 
var SUCCESSFUL_LINES:int 
var LINEGOAL:int 
var GAMEREPUTATION:float 
var MICROTRANSACTIONS:bool = false

func calculate_result():
	var v1 = INVESTOR * 100
	var v2 = INVESTOR * GAMEPRICE
	var WILLING_TO_PAY = POPULARITY * (1 - (GAMEPRICE * 0.01))
	var PURCHASE = (POPULARITY * (1 - (GAMEPRICE * 0.01)) * ( GAMEREPUTATION + 1))
	var v3 = PURCHASE * GAMEPRICE
	var v4 = 0
	if MICROTRANSACTIONS:
		var subject = float(PURCHASE) * randf_range(0.1, 0.2)
		v4 = calcular_ganancias_masivas(subject)
	var SUBTOTAL = v1 + v2 + v3 + v4
	var TOTAL = SUBTOTAL * pow(float(SUCCESSFUL_LINES) / float(LINEGOAL), 4)
	var CONTENT_BONUS = TOTAL - SUBTOTAL
	var EARNINGS = TOTAL - COSTS
	print("Score:",EARNINGS)
	return {"v1": v1, "v2": v2, "v3": v3, "v4": v4, "WILLING TO PAY": WILLING_TO_PAY, "PURCHASE": PURCHASE, "CONTENT BONUS": CONTENT_BONUS, "SUBTOTAL": SUBTOTAL, "TOTAL": TOTAL, "EARNINGS": EARNINGS}

func calcular_ganancias_masivas(usuarios: float) -> int:
	# 1. Calculamos el gasto medio por persona con la curva
	#    Hacemos una pequeña muestra de 10 personas para obtener un promedio variable único en este turno
	var muestra_promedio: float = 0.0
	for i in range(10):
		muestra_promedio += pow(randf(), 3.0) * 100.0
	muestra_promedio /= 10.0
	
	# 2. Multiplicamos el promedio por el total de usuarios
	var ganancias_totales: int = roundi(muestra_promedio * usuarios)
	
	return ganancias_totales
