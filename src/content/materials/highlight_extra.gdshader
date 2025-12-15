shader_type spatial;
render_mode unshaded;

// Higher values are smaller width.
uniform float outline_width : hint_range(0.0, 10.0, 0.1) = 1.4;
uniform vec2 smoothness = vec2(0.1, 0.5);

uniform vec4 base_color : source_color = vec4(1.0);

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	float basic_fresnel = fresnel(outline_width, NORMAL, VIEW);
	basic_fresnel = smoothstep(smoothness.x, smoothness.y, basic_fresnel); //0.5 magic number seems to give the most intuitive control
	ALBEDO = mix(base_color.rgb, vec3(1.0), basic_fresnel);
	ALPHA = basic_fresnel;
}