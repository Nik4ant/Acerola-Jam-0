shader_type canvas_item;

uniform vec4 color_other: source_color = vec4(0.25);
uniform vec4 color_stripe: source_color = vec4(1.0, 0.75, 0.0, 1.0);
uniform float divisions = 8.0; // increase for more stripe density
uniform float stripe_bias = 2.5; // 1.0 means no stripes; 2.0 means stripes and gaps are equal size
uniform float speed = 0.1;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	// const float angle = 0.7854;
	// cos(angle) = 0.7071054825
	// sin(angle) = 0.7071080799
	float w = 0.7071054825 * UV.x + 0.7071080799 * UV.y - speed * TIME;
	if (floor(mod(w * divisions, stripe_bias)) > 0.0001) {
		COLOR = color_stripe;
	} else {
		COLOR = color_other;
	}
	COLOR.a = color.a * 0.5;
}