shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0);

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 center = vec2(0.5);

    // distancia al centro
    float dist = distance(UV, center);

    // RANGO MUCHO MÁS MARCADO:
    // 0.12 → el círculo limpio es mucho más chiquito
    // 0.55 → ya está re tapado
    float vignette = smoothstep(0.12, 0.55, dist);

    // ruido en el borde
    float noise = rand(UV * 250.0 + TIME * 4.0);
    float grain = step(0.10, noise); // más granulado, más visible

    // color azul grisáceo claro (para que se note sobre un fondo azul)
    vec3 edge_color = vec3(0, 0, 0);

    float edge = vignette * intensity;

    // en zonas de ruido, lo aclaro un poco
    vec3 rgb = mix(edge_color, edge_color + 0.15, grain * edge);

    // opacidad más marcada
    float alpha = edge * 0.95;

    COLOR = vec4(rgb, alpha);
}
