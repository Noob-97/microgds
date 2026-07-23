shader_type canvas_item;

// Coordenadas del recuadro que será TRANSPARENTE (de 0.0 a 1.0)
uniform vec2 corte_inicio = vec2(0.3, 0.4); // Esquina superior izquierda
uniform vec2 corte_fin = vec2(0.7, 0.8);    // Esquina inferior derecha

// Color para el resto del panel (todo lo de AFUERA)
uniform vec4 color_fondo : source_color = vec4(0.1, 0.1, 0.1, 1.0);

void fragment() {
    // Si el píxel está DENTRO del recuadro, se elimina (queda transparente)
    if (UV.x >= corte_inicio.x && UV.x <= corte_fin.x && 
        UV.y >= corte_inicio.y && UV.y <= corte_fin.y) {
        discard;
    } else {
        // Todo lo que está FUERA toma el color de fondo personalizado
        COLOR = color_fondo;
    }
}