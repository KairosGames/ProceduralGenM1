shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;

uniform sampler2D noise_tex : source_color, repeat_enable, filter_linear;
uniform float noise_scale_1 = 0.5;
uniform float noise_scale_2 = 1.5; 
uniform float speed = 0.02;
uniform float coverage = 0.6;
uniform float softness = 0.12;
uniform float blend_sharpness = 8.0;
uniform vec3 center_world = vec3(0.0);
uniform float planet_radius = 50.0;
uniform float cloud_rot_speed = -0.05;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float sample_triplanar(vec3 p, vec3 nrm, float scale, vec2 flow) {
	vec3 w = pow(abs(nrm), vec3(blend_sharpness));
	w /= (w.x + w.y + w.z + 1e-6);
	float x = texture(noise_tex, p.yz * scale + flow).r;
	float y = texture(noise_tex, p.xz * scale + flow).r;
	float z = texture(noise_tex, p.xy * scale + flow).r;
	return x * w.x + y * w.y + z * w.z;
}

mat3 rot_y(float a) {
	float s = sin(a);
	float c = cos(a);
	return mat3(
		vec3( c, 0.0,  s),
		vec3(0.0, 1.0, 0.0),
		vec3(-s, 0.0,  c));
}

void fragment() {
	vec3 nrm = normalize(world_pos - center_world);
	float ang = TIME * cloud_rot_speed;
	mat3 R = rot_y(ang);
	vec2 flow1 = vec2(TIME * speed, TIME * speed * 0.6);
	vec2 flow2 = -flow1 * 1.3;
	vec3 p = (world_pos - center_world) / max(planet_radius, 0.0001);
	p = R * p;
	nrm = normalize(R * nrm);
	float n1 = sample_triplanar(p, nrm, noise_scale_1, flow1);
	float n2 = sample_triplanar(p, nrm, noise_scale_2, flow2);
	float n = 0.8 * n1 + 0.2 * n2;
	float a = smoothstep(coverage, coverage + softness, n);
	ALBEDO = vec3(1.0);
	ALPHA = a;
}
