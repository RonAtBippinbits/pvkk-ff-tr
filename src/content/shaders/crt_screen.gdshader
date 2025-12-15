shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D tv_mask : source_color,filter_linear_mipmap,repeat_enable;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform sampler2D tv_image : source_color, hint_default_black,filter_linear,repeat_enable;
uniform float emission_energy;
uniform sampler2D texture_normal : hint_roughness_normal,filter_linear_mipmap,repeat_enable;
uniform float normal_scale : hint_range(-16,16);
uniform float clearcoat : hint_range(0,1);
uniform float clearcoat_roughness : hint_range(0,1);
uniform sampler2D texture_detail_normal : hint_normal,filter_linear_mipmap,repeat_enable;

uniform vec2 image_scale = vec2(1.0);
uniform vec2 image_offset = vec2(0.0);
uniform vec2 screen_orientation = vec2(0.0, 1.0);
uniform vec2 screen_orientation_i = vec2(1.0, 0.0);
uniform float scanlines_opacity : hint_range(0.0, 1.0) = 0.4;
uniform float scanlines_width : hint_range(0.0, 0.5) = 0.25;
uniform float grille_opacity : hint_range(0.0, 1.0) = 0.3;
uniform vec2 resolution = vec2(640.0, 480.0); // Set the number of rows and columns the texture will be divided in. Scanlines and grille will make a square based on these values

uniform bool roll = true;
uniform float roll_speed = 8.0; // Positive values are down, negative are up
uniform float roll_size : hint_range(0.0, 100.0) = 15.0;
uniform float roll_variation : hint_range(0.1, 5.0) = 1.8; // This valie is not an exact science. You have to play around with the value to find a look you like. How this works is explained in the code below.
uniform float distort_intensity : hint_range(0.0, 0.2) = 0.05; // The distortion created by the rolling effect.

uniform float noise_opacity : hint_range(0.0, 1.0) = 0.4;
uniform float noise_speed = 5.0; // There is a movement in the noise pattern that can be hard to see first. This sets the speed of that movement.

uniform float static_noise_intensity : hint_range(0.0, 1.0) = 0.06;

uniform float aberration : hint_range(-1.0, 1.0) = 0.03; // Chromatic aberration, a distortion on each color channel.
uniform float brightness = 1.4; // When adding scanline gaps and grille the image can get very dark. Brightness tries to compensate for that.
uniform bool discolor = true; // Add a discolor effect simulating a VHS

uniform float vignette_intensity = 0.4; // Size of the vignette, how far towards the middle it should go.
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;

// Used by the noise functin to generate a pseudo random value between 0.0 and 1.0
vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

// Generate a Perlin noise used by the distortion effects
float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) * 0.5 + 0.5;
}

// Adds a vignette shadow to the edges of the image
float vignette(vec2 uv){
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity * vignette_opacity);
}


vec2 scale_uv(vec2 uv, vec2 scale, vec2 offset) {
	// Offset UV to center
	uv -= vec2(0.5);
	// Scale
	uv *= scale;
	// Offset back
	uv += vec2(0.5) + offset;
	return uv;
}


void fragment() {
	vec2 uv = UV;
	vec2 text_uv = scale_uv(UV, image_scale, image_offset);
	vec2 roll_uv = vec2(0.0);
	float time = roll ? TIME : 0.0;
	float uv_turned = length(uv * screen_orientation);
	float uv_turned_i = length(uv * screen_orientation_i);

	float roll_line = 0.0;
	if (roll || noise_opacity > 0.0)
	{
		roll_line = smoothstep(0.3, 0.9, sin(uv_turned * roll_size - (time * roll_speed) ) );
		roll_line *= roll_line * smoothstep(0.3, 0.9, sin(uv_turned * roll_size * roll_variation - (time * roll_speed * roll_variation) ) );
		roll_uv = vec2(roll_line * distort_intensity * (1.-UV.x)) * screen_orientation;
	}

	vec4 text;
	if (roll)
	{
		// If roll is true distort the texture with roll_uv. The texture is split up into RGB to
		// make some chromatic aberration. We apply the aberration to the red and green channels accorging to the aberration parameter
		// and intensify it a bit in the roll distortion.
		text.r = texture(tv_image, text_uv + roll_uv * 0.8 + (vec2(aberration)*screen_orientation_i) * .1).r;
		text.g = texture(tv_image, text_uv + roll_uv * 1.2 - (vec2(aberration)*screen_orientation_i) * .1 ).g;
		text.b = texture(tv_image, text_uv + roll_uv).b;
		text.a = 1.0;
	}
	else
	{
		// If roll is false only apply the aberration without any distorion. The aberration values are very small so the .1 is only
		// to make the slider in the Inspector less sensitive.
		text.r = texture(tv_image, text_uv + (vec2(aberration)*screen_orientation_i) * .1).r;
		text.g = texture(tv_image, text_uv - (vec2(aberration)*screen_orientation_i) * .1).g;
		text.b = texture(tv_image, text_uv).b;
		text.a = 1.0;
	}

	float r = text.r;
	float g = text.g;
	float b = text.b;

	uv = UV;

	// CRT monitors don't have pixels but groups of red, green and blue dots or lines, called grille. We isolate the texture's color channels
	// and divide it up in 3 offsetted lines to show the red, green and blue colors next to each other, with a small black gap between.

	float g_r = smoothstep(0.85, 0.95, abs(sin(uv_turned_i * (resolution.x * 3.14159265))));
	r = mix(r, r * g_r, grille_opacity);

	float g_g = smoothstep(0.85, 0.95, abs(sin(1.05 + uv_turned_i * (resolution.x * 3.14159265))));
	g = mix(g, g * g_g, grille_opacity);

	float b_b = smoothstep(0.85, 0.95, abs(sin(2.1 + uv_turned_i * (resolution.x * 3.14159265))));
	b = mix(b, b * b_b, grille_opacity);


	// Apply the grille to the texture's color channels and apply Brightness. Since the grille and the scanlines (below) make the image very dark you
	// can compensate by increasing the brightness.
	text.r = clamp(r * brightness, 0.0, 1.0);
	text.g = clamp(g * brightness, 0.0, 1.0);
	text.b = clamp(b * brightness, 0.0, 1.0);
	float scanlines = smoothstep(scanlines_width, scanlines_width + 0.5, abs(sin(uv_turned * (resolution.y * 3.14159265))));
	text.rgb = mix(text.rgb, text.rgb * vec3(scanlines), scanlines_opacity);

	float noise = smoothstep(0.4, 0.5, noise(uv * (vec2(200.0)*screen_orientation) + vec2(10.0, (TIME * (noise_speed))) ) );
	roll_line *= noise * scanlines * clamp(random((ceil(uv * resolution) / resolution) + (vec2(TIME * 0.8)*screen_orientation)).x + 0.8, 0.0, 1.0);
	text.rgb = clamp(mix(text.rgb, text.rgb + roll_line, noise_opacity), vec3(0.0), vec3(1.0));

	if (static_noise_intensity > 0.0)
	{
		text.rgb += clamp(random((ceil(uv * resolution*2.0) / resolution*2.0) + fract(TIME)).x, 0.0, 1.0) * static_noise_intensity;
	}
	text.rgb *= vignette(uv);
	float saturation = 0.5;
	float contrast = 1.2;
	if (discolor)
	{
		// Saturation
		vec3 greyscale = vec3(text.r + text.g + text.b) / 3.;
		text.rgb = mix(text.rgb, greyscale, saturation);

		// Contrast
		float midpoint = pow(0.5, 2.2);
		text.rgb = (text.rgb - vec3(midpoint)) * contrast + midpoint;
	}

	text.rgb = clamp(text.rgb, 0.0, 1.0);

	METALLIC = 0.0;
	vec2 tv_uv = scale_uv(UV2, image_scale, image_offset);
	vec2 uv_scaled = scale_uv(UV, image_scale, image_offset);

	vec3 tv_mask_tex = texture(tv_mask, tv_uv).rgb;
	ALBEDO = albedo.rgb * tv_mask_tex.rgb;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness, UV),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular * tv_mask_tex.r;
	NORMAL_MAP = texture(texture_normal,UV).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	vec3 emission_tex = texture(tv_image, uv_scaled).rgb;
	EMISSION = text.rgb*emission_energy*tv_mask_tex;
	EMISSION *= step(0.0, tv_uv.x) * step(tv_uv.x, 1.0) * step(0.0, tv_uv.y) * step(tv_uv.y, 1.0);
	CLEARCOAT = clearcoat * tv_mask_tex.r;
	CLEARCOAT_ROUGHNESS = clearcoat_roughness;
	vec4 detail_norm_tex = texture(texture_detail_normal,UV);
	NORMAL_MAP = mix(NORMAL_MAP,detail_norm_tex.rgb,0.3);
}