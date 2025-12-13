shader_type canvas_item;

// 1. Necesitas esta variable para acceder a lo que está detrás del nodo.
uniform sampler2D screen_texture : hint_screen_texture;

uniform float distortion_strength : hint_range(0.0, 0.005) = 0.001; // Fuerza de la distorsión
uniform float distortion_speed = 0.5; // Velocidad de las ondas
uniform vec4 water_fog_color : source_color = vec4(0.1, 0.4, 0.5, 0.2); // Azul verdoso tenue
uniform float fog_depth_y = 1000.0; // Distancia en Y (píxeles) para que el color de niebla sea máximo

void fragment() {
	// Las coordenadas de la textura de la pantalla.
	// NOTA: Para la distorsión usamos SCREEN_UV, NO UV.
	
	// 1. Efecto de Distorsión (Refracción Submarina)
	// Usa el tiempo y la posición UV para crear un offset de onda.
	float distortion_x = sin(SCREEN_UV.y * 50.0 + TIME * distortion_speed) * distortion_strength;
	float distortion_y = cos(SCREEN_UV.x * 50.0 + TIME * distortion_speed * 0.8) * distortion_strength;
	
	// Aplica la distorsión a las coordenadas de la pantalla.
	vec2 offset_uv = SCREEN_UV + vec2(distortion_x, distortion_y);

	// Lee el color del fondo (lo que está detrás del ColorRect) usando el offset.
	vec4 color = texture(screen_texture, offset_uv);
	
	// 2. Efecto de Niebla/Profundidad (Fog)
	// Calculamos el factor de niebla basado en la coordenada Y de la pantalla.
	float fog_factor = clamp(SCREEN_UV.y * 1000.0 / fog_depth_y, 0.0, 1.0);
	
	// Aplica el color de la niebla/neblina.
	color.rgb = mix(color.rgb, water_fog_color.rgb, fog_factor * water_fog_color.a);
	
	// 3. Resultado final
	COLOR = color;
}