shader_type spatial;

uniform sampler2D depth_gradient : source_color, repeat_disable, filter_linear;
uniform float steps = 6.0;
uniform float depth_gamma = 0.45;
uniform float shallow_bias = 0.01;
uniform float shimmer_amp = 0.015;
uniform float shimmer_speed = 3.0;
uniform float shimmer_scale = 0.3;

void fragment() {
	float d = clamp(COLOR.r, 0.0, 1.0);
	float wave = sin(TIME * shimmer_speed + VERTEX.x * shimmer_scale + VERTEX.z * shimmer_scale);
	d = clamp(d + shimmer_amp * wave, 0.0, 1.0);
	d = clamp((d - shallow_bias) / max(1.0 - shallow_bias, 0.0001), 0.0, 1.0);
	d = pow(d, depth_gamma);
	d = floor(d * steps) / steps;
	ALBEDO = texture(depth_gradient, vec2(d, 0.5)).rgb;
	ALPHA = 0.95;
}
