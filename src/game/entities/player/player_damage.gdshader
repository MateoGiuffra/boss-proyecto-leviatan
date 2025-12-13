shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0); // 0 = invisible, 1 = flash fuerte

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);

    // borde más marcado (ajustá 0.2 y 0.8 si querés más/menos borde)
    float vignette = smoothstep(0.2, 0.8, dist);

    // rojo un poco brillante
    vec3 red = vec3(0.5607, 0.1451, 0.1529);

    float alpha = vignette * intensity;

    COLOR = vec4(red, alpha);
}
