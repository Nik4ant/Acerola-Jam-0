//---CRT Shader---
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
//region Magnify
group_uniforms magnify;
uniform vec2 center = vec2(0.5, 0.5);
uniform float size = -0.1;
uniform float thickness = 0.05;
uniform float force = 0.1;
//endregion
//region Crt game realm
group_uniforms crt_game_realm;
uniform float game_scanline_count : hint_range(0, 1800) = 350.0;
uniform float game_offset_r = 0.0; 
uniform float game_offset_b = 0.0; 
//endregion
//region Crt dev realm
group_uniforms crt_dev_realm;
uniform float dev_shift_r: hint_range(-0.1, 0.1, 0.001) = 0.0;
uniform float dev_shift_g: hint_range(-0.1, 0.1, 0.001) = 0.002;
uniform float dev_shift_b: hint_range(-0.1, 0.1, 0.001) = 0.002;

uniform float dev_clone_r: hint_range(-0.1, 0.1, 0.001) = 0.0;
uniform float dev_clone_g: hint_range(-0.1, 0.1, 0.001) = 0.0;
uniform float dev_clone_b: hint_range(-0.1, 0.1, 0.001) = 0.0;
//endregion


float circle(vec2 position, float radius, float feather) {
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}

vec3 crt_game_realm(sampler2D target, vec2 uv, vec2 screen_pixel_size) {
	float r = texture(
		target, 
		uv + vec2(screen_pixel_size.x * game_offset_r), 
		0.0
	).r;
	float g = texture(target, uv).g;
	float b = texture(
		target,
		uv + vec2(screen_pixel_size.x * game_offset_b), 
		0.0
	).b;
	
	float s = sin(uv.y * game_scanline_count * PI * 2.0);
	s = (s * 0.5 + 0.5) * 0.9 + 0.1;
	vec3 scan_line = vec3(pow(s, 0.25));
	
	return vec3(r, g, b) * scan_line;
}

vec3 crt_dev_realm(sampler2D starting_texture, vec2 screen_pixel_size, vec4 fragcoord) {
	vec2 iResolution = 1.0 / screen_pixel_size;
	vec2 uv = fragcoord.xy / iResolution.xy;
	vec3 oricol = texture(starting_texture, vec2(uv.x, uv.y)).xyz;
	vec3 col;
	float x = sin(0.3 * TIME + uv.y * 21.0) * 
			sin(0.7 * TIME + uv.y * 29.0) *
			sin(0.3 + 0.33 * TIME + uv.y * 31.0) * 0.0017;
	
	col.r = texture(starting_texture, vec2(x + uv.x + dev_shift_r, uv.y + dev_shift_r)).x + 0.05;
	col.g = texture(starting_texture, vec2(x + uv.x + dev_shift_g, uv.y + dev_shift_g)).y + 0.05;
	col.b = texture(starting_texture, vec2(x + uv.x + dev_shift_b, uv.y + dev_shift_b)).z + 0.05;
	
	col.r += 0.08 * texture(
		starting_texture,
		dev_clone_r * vec2(x + 0.025, -0.027) + vec2(uv.x + 0.001, uv.y + 0.001)
	).r;
	col.g += 0.05 * texture(
		starting_texture, 
		dev_clone_g * vec2(x + -0.022, -0.02) + vec2(uv.x + 0.000, uv.y - 0.002)
	).g;
	col.b += 0.08 * texture(
		starting_texture, 
		dev_clone_b * vec2(x + -0.02, -0.018) + vec2(uv.x - 0.002, uv.y + 0.000)
	).b;
	
	col = clamp(col * 0.6+ 0.4 * col * col * 1.0, 0.0, 1.0);
	
	float vig = (0.0 + 1.0 * 16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
	col *= vec3(pow(vig, 0.3));
	
	col *= vec3(0.95, 1.05, 0.95);
	col *= 2.8;
	
	float scans = clamp(
		0.35 + 0.35 * sin(3.5 * TIME + uv.y * iResolution.y * 1.5), 
		0.0, 
		1.0
	);
	
	float s = pow(scans, 1.7);
	col = col * vec3(0.4 + 0.7 * s);
	
	col *= 1.0 + 0.01 * sin(110.0 * TIME);
	if (uv.x < 0.0 || uv.x > 1.0)
		col *= 0.0;
	if (uv.y < 0.0 || uv.y > 1.0)
		col *= 0.0;
	
	col *= 1.0 - 0.65 * vec3(clamp((mod(fragcoord.x, 2.0) - 1.0) * 2.0, 0.0, 1.0));
	
	float comp = smoothstep(0.1, 0.9, sin(TIME));
	return col;
}

void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaled_uv = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0); 
	
	float len = length(scaled_uv - center);
	float mask = (
		(1.0 - smoothstep(size - 0.1, size, len)) 
		* smoothstep(size - thickness - 0.1, size - thickness, len)
	);
	vec2 disp = normalize(scaled_uv - center) * force * mask;
	COLOR.rgb = crt_game_realm(SCREEN_TEXTURE, SCREEN_UV - disp, SCREEN_PIXEL_SIZE);
	/*if (circle(scaled_uv, size, 0.1) < 0.1) {
		COLOR.rgb = crt_dev_realm(SCREEN_TEXTURE, SCREEN_PIXEL_SIZE, FRAGCOORD);
	} else {
		
	}*/
}
