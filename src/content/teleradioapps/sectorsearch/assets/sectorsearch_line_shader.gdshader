shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D pattern : source_color, repeat_enable;
uniform float repeat = 40.0;
uniform float scroll_speed = 1.0;

void fragment() {
	float p = texture(pattern, vec2((UV.x*repeat)-TIME*scroll_speed, UV.y)).r;
	COLOR *= p;
}