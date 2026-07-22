shader_type canvas_item;

uniform vec4 color_base : source_color = vec4(0.0, 0.5, 1.0, 1.0); // Azul XP
uniform vec4 color_brillo : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Luz blanca
uniform float valor_progreso : hint_range(0.0, 1.0) = 0.5; // Conectar al valor actual (0.0 a 1.0)
uniform float ancho_brillo : hint_range(0.01, 0.2) = 0.08; // Ancho del difuminado

void fragment() {
	// UV.x va de 0.0 (izquierda) a 1.0 (derecha)
	float x = UV.x;
	
	// Si el píxel está más allá del progreso actual, lo hacemos transparente
	if (x > valor_progreso) {
		discard;
	}
	
	// Calculamos la distancia desde el píxel actual hasta el borde del progreso
	float distancia_al_borde = valor_progreso - x;
	
	// El ancho del brillo se reduce automáticamente cuando nos acercamos al 1.0 (100%)
	float ancho_efectivo = min(ancho_brillo, 1.0 - valor_progreso + 0.01);
	
	// Calculamos la intensidad de la luz (máxima en el borde, 0 hacia la izquierda)
	float factor_brillo = smoothstep(ancho_efectivo, 0.0, distancia_al_borde);
	
	// Mezclamos el color base con el color de la luz
	COLOR = mix(color_base, color_brillo, factor_brillo);
}