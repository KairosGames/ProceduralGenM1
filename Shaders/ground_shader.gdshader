shader_type spatial;
render_mode world_vertex_coords;

uniform sampler2D altitude_gradient : source_color, repeat_disable, filter_linear;
uniform float base_radius = 10.0;
uniform float amplitude = 3.0;
uniform vec3 center_world = vec3(0.0);
varying vec3 world_pos;

void vertex(){
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment(){
	float dist = length(world_pos - center_world);
	float delta = dist - base_radius;
	float h = 0.5 + 0.5 * (delta / max(amplitude, 0.0001));
	h = clamp(h, 0.0, 1.0);
	ALBEDO = texture(altitude_gradient, vec2(h, 0.5)).rgb;
}