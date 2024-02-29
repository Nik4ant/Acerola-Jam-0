//---CRT Shader---
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float scanline_count : hint_range(0, 1800) = 50.0;
uniform float offset_r = -2.0; 
uniform float offset_b = 2.0; 

vec2 uv_curve(vec2 uv)
{
	return uv;
	/*
	uv = (uv - 0.5) * 2.0;
	
	//You can modify the numbers and try different values
	uv.x *= 1.0 + pow(abs(uv.y) / 4.0, 2.0);
	uv.y *= 1.0 + pow(abs(uv.x) / 4.0, 2.0);
	
	//The scale part (you can delete it when you want)
	//uv *= 0.83;
	
	uv = (uv * 0.5) + 0.5;
	return uv;*/
}


void fragment() {
	float r = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x* offset_r), 0.0).r;
	// + vec2(SCREEN_PIXEL_SIZE.x * 0.0), 0.0
	float g = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV)).g;
	float b = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x* offset_b), 0.0).b;
	
	// If you dont want scanlines you can just delete this part
	float s = sin(uv_curve(SCREEN_UV).y * scanline_count * PI * 2.0);
	s = (s * 0.5 + 0.5) * 0.9 + 0.1;
	vec4 scan_line = vec4(vec3(pow(s, 0.25)), 1.0);
	
	COLOR = vec4(r, g, b, 1.0) * scan_line;
}
