shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float shake : hint_range(0.0, 1.0) = 0.1;

// --- Controles de Movimiento para las Scanlines ---
uniform float scanline_speed : hint_range(-10.0, 10.0) = 2.0; // Velocidad del desplazamiento
uniform float scanline_density = 400.0;                       // Cantidad/grosor de líneas
uniform float scanline_opacity : hint_range(0.0, 0.2) = 0.04;  // Intensidad del efecto

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // 1. Efecto de Glitch/Shake (Afecta a la pantalla)
    if (rand(vec2(TIME, 0.0)) < shake) {
        uv.x += rand(vec2(TIME, uv.y)) * 0.01;
    }

    // 2. Aberración Cromática (R, G, B)
    float r = texture(SCREEN_TEXTURE, uv + vec2(0.0015, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv - vec2(0.0015, 0.0)).b;
    
    // 3. MOVIMIENTO ÚNICAMENTE EN LAS SCANLINES
    // Sumamos (TIME * velocidad) a la coordenada Y para que las líneas se desplacen hacia arriba o abajo
    float moving_y = uv.y + (TIME * scanline_speed * 0.1);
    float scanline = sin(moving_y * scanline_density) * scanline_opacity;

    // Aplicamos las scanlines en movimiento sobre la imagen filtrada
    COLOR = vec4(r - scanline, g - scanline, b - scanline, 1.0);
}