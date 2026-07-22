extends ProgressBar

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	_actualizar_shader(value)

func _on_value_changed(nuevo_valor: float) -> void:
	_actualizar_shader(nuevo_valor)

func _actualizar_shader(valor_actual: float) -> void:
	# Convertimos el valor a un rango de 0.0 a 1.0
	var porcentaje: float = (valor_actual - min_value) / (max_value - min_value)
	
	# Le pasamos el porcentaje exacto al Shader
	var mat = material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("valor_progreso", porcentaje)
