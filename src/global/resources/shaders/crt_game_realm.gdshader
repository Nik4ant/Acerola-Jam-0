//---CRT Shader---
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float scanline_count : hint_range(0, 1800) = 50.0;
uniform float offset_r = 0.0; 
uniform float offset_b = 0.0; 


void fragment() {
	float r = texture(
		SCREEN_TEXTURE, 
		SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x * offset_r), 
		0.0
	).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
	float b = texture(
		SCREEN_TEXTURE,
		SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x* offset_b), 
		0.0
	).b;
	
	float s = sin(SCREEN_UV.y * scanline_count * PI * 2.0);
	s = (s * 0.5 + 0.5) * 0.9 + 0.1;
	vec4 scan_line = vec4(vec3(pow(s, 0.25)), 1.0);
	
	COLOR = vec4(r, g, b, 1.0) * scan_line;
}
