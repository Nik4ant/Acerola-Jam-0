shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform float size = 0.5;
uniform float thickness = 0.0;
uniform float force = 0.1;

float circle(vec2 position, float radius, float feather) {
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}

void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaled_uv = (UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0); 
	
	float len = length(scaled_uv - center);
	float mask = (
		(1.0 - smoothstep(size - 0.1, size, len)) 
		* smoothstep(size - thickness - 0.1, size - thickness, len)
	);
	vec2 disp = normalize(scaled_uv - center) * force * mask;
	COLOR = texture(TEXTURE, UV - disp);
	COLOR.a = float(circle(scaled_uv, size, 0.1) < 0.01);
}