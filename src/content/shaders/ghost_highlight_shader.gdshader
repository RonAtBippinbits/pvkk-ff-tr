shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,diffuse_burley;

uniform vec4 albedo : source_color;
uniform vec4 emission_color : source_color;
uniform float emission_amount: hint_range(0.0, 16.0) = 5.0f; 
uniform float rim_steepness : hint_range(0.0f, 16.0f) = 3.0f; //higher values mean a smaller rim.
uniform vec3 uv_scale;
uniform vec3 uv_offset;


void vertex() {
	UV=UV*uv_scale.xy+uv_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	ALBEDO = albedo.rgb;
	EMISSION = emission_color.rgb * emission_amount;
	float NdotV = dot(NORMAL, VIEW);
	float rim_light = pow(1.0 - NdotV, rim_steepness);
	ALPHA = rim_light * emission_color.a / PI;
}