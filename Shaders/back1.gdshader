shader_type canvas_item;

// --- Controles de Vertex / UV ---
uniform vec2 tiling = vec2(2.0, 1.0);
uniform vec2 offset = vec2(0.0, 0.0);
uniform bool moving = false;

// --- Controles del Efecto de Ondas ---
uniform float size : hint_range(1.0, 100.0) = 25.0;
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0); 
uniform vec4 color2 : source_color = vec4(0.7, 0.7, 0.7, 1.0);
uniform float speed : hint_range(0.0, 10.0) = 1.0;

// Configuración de Dirección de la Onda
uniform bool mover_en_y = true;
uniform float sentido : hint_range(-1.0, 1.0, 2.0) = 1.0; 

void vertex() {
    UV *= tiling;
    UV += offset;

    if (moving) {
        UV += offset * TIME;
    }
}

void fragment() {
    // Escalamos las UVs para el tamaño de las celdas
    vec2 pos = UV * size;

    if (mover_en_y) {
        // Movimiento vertical en columnas alternadas
        int col = int(floor(pos.x));
        float time_offset = (col % 2 == 0 ? cos(TIME * speed * sentido) : sin(TIME * speed * sentido));
        pos.y -= time_offset;
    } else {
        // Movimiento horizontal en filas alternadas
        int row = int(floor(pos.y));
        float time_offset = (row % 2 == 0 ? cos(TIME * speed * sentido) : sin(TIME * speed * sentido));
        pos.x -= time_offset;
    }

    // Calculamos las posiciones finales de las celdas
    pos = floor(pos);

    // Máscara del patrón en ajedrez
    float pattern_mask = mod(pos.x + mod(pos.y, 2.0), 2.0);
    
    // Si la textura tiene contenido la mezcla, de lo contrario muestra los colores base
    vec4 tex_color = texture(TEXTURE, fract(UV));
    vec4 grid_color = mix(color1, color2, pattern_mask);

    COLOR = grid_color * tex_color;
}
