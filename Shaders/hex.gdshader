shader_type canvas_item;

// --- Controles de Pixelado ---
uniform float pixel_size : hint_range(1.0, 32.0) = 4.0;
uniform bool handle_edges = false;

// --- Controles de Movimiento y UV (Vertex) ---
uniform vec2 tiling = vec2(1.0, 1.0);
uniform vec2 offset = vec2(0.0, 0.0);
uniform bool moving = false;

// --- Controles del Efecto Hexagonal ---
uniform vec3 color1: source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 color2: source_color = vec3(1.0, 1.0, 1.0);
uniform float speed1 = 2.0;
uniform float speed2 = 3.79;

// --- Control de Transparencia ---
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

varying vec2 p_world;

// Función de distancia para el hexágono
float sdHexagon(in vec2 p, in float r) {
	const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
	p = abs(p);
	p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
	p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
	return length(p) * sign(p.y);
}

void vertex() {
	// Guardamos la posición en pantalla/mundo para el pixelado
	p_world = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;

	// Aplicamos escala y movimiento inicial
	UV *= tiling;
	UV += offset;

	if (moving) {
		UV += offset * TIME;
	}
}

void fragment() {
	// 1. CÁLCULO DEL PIXELADO
	vec2 p_snapped = floor(p_world / pixel_size) * pixel_size + pixel_size * 0.5;
	vec2 delta = p_snapped - p_world;

	mat2 M_p = mat2(dFdx(p_world), dFdy(p_world));
	mat2 M_uv = mat2(dFdx(UV), dFdy(UV));
	mat2 J = M_uv * inverse(M_p);
	vec2 delta_uv = J * delta;

	// Coordenada UV Pixelada
	vec2 pixelated_uv = UV + delta_uv;

	// 2. RENDERIZADO DEL PATRÓN HEXAGONAL (Usando la UV pixelada)
	vec2 zoom = pixelated_uv * 10.0;
	vec2 guv = fract(zoom) - 0.5;

	// Hexágono 1 (Centro)
	float sd = sdHexagon(guv, 0.45 - abs(sin(TIME * speed1) * 0.35));
	float c1 = smoothstep(0.05, 0.00, sd);
	vec3 final_color = color1 * (0.95 + c1 * 0.75);

	// Hexágono 2 (Borde)
	float sd2 = sdHexagon(guv, 0.4 + cos(TIME * speed2) * 0.2);
	float c = smoothstep(0.04, 0.0, abs(sd2));
	final_color += color2 * c;

	// 3. MANEJO DE BORDES Y TRANSPARENCIA
	float alpha = 1.0;
	if (handle_edges) {
		float margin_x = (abs(J[0].x) + abs(J[1].x)) * pixel_size * 0.5;
		float margin_y = (abs(J[0].y) + abs(J[1].y)) * pixel_size * 0.5;
		if (pixelated_uv.x < margin_x || pixelated_uv.x > 1.0 - margin_x || 
		    pixelated_uv.y < margin_y || pixelated_uv.y > 1.0 - margin_y) {
			alpha = 0.0;
		}
	}

	// Multiplicamos la opacidad por el alpha calculado (bordes) y por el modulate del nodo (COLOR.a)
	COLOR = vec4(final_color, alpha * opacity * COLOR.a);
}