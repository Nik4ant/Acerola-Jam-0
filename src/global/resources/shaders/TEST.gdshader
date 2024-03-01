shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;
//region Uniforms
//region Magnify
group_uniforms magnify;
uniform vec2 center = vec2(0.5, 0.5);
uniform float size = 0.5;
uniform float thickness = 0.0;
uniform float force = 0.1;
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

//region Crt game realm
group_uniforms crt_game_realm;
uniform float game_scanline_count : hint_range(0, 1800) = 50.0;
uniform float game_offset_r = 0.0; 
uniform float game_offset_b = 0.0; 
//endregion

//region Glow
group_uniforms bloom;
uniform float BLOOM_THRESHOLD = 0.75;
uniform float BLOOM_INTENSITY = 2.0;

uniform int BLUR_ITERATIONS = 5;
uniform float BLUR_SIZE = 0.005;
uniform int BLUR_SUBDIVISIONS = 32;
//endregion
//endregion


//region Dev realm
vec3 gaussian5x5(sampler2D tex, vec2 uv, vec2 pix_size) {
	vec3 p = vec3( 0.0, 0.0, 0.0 );
	float coef[25] = { 0.00390625, 0.015625, 0.0234375, 0.015625, 0.00390625, 0.015625, 0.0625, 0.09375, 0.0625, 0.015625, 0.0234375, 0.09375, 0.140625, 0.09375, 0.0234375, 0.015625, 0.0625, 0.09375, 0.0625, 0.015625, 0.00390625, 0.015625, 0.0234375, 0.015625, 0.00390625 };
	
	for( int y=-2; y<=2; y++ ) {
		for( int x=-2; x<=2; x ++ ) {
			p += ( texture( tex, uv + vec2( float( x ), float( y ) ) * pix_size ).rgb ) * coef[(y+2)*5 + (x+2)];
		}
	}

	return p;
}

vec3 sobel_fragment(sampler2D starting_texture, vec2 screen_uv, vec2 screen_pixel_size) {
	// 3 x 3
	vec3 pix[9];
	// ガウシアンフィルタ
	for(int y = 0; y < 3; y++) {
		for(int x = 0; x < 3; x++) {
			pix[y * 3 + x] = gaussian5x5(
				starting_texture,
				screen_uv + vec2(float(x - 1), float(y - 1)) * screen_pixel_size,
				screen_pixel_size
			);
		}
	}
	// Sobelフィルタ
	vec3 sobel_src_x = (
		pix[0] * -1.0
	+	pix[3] * -2.0
	+	pix[6] * -1.0
	+	pix[2] * 1.0
	+	pix[5] * 2.0
	+	pix[8] * 1.0
	);
	vec3 sobel_src_y = (
		pix[0] * -1.0
	+	pix[1] * -2.0
	+	pix[2] * -1.0
	+	pix[6] * 1.0
	+	pix[7] * 2.0
	+	pix[8] * 1.0
	);
	return sqrt(sobel_src_x * sobel_src_x + sobel_src_y * sobel_src_y);
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

vec3 dev_realm(sampler2D target, vec2 screen_uv, vec2 screen_pixel_size, vec4 fragcoord) {
	return sobel_fragment(target, screen_uv, screen_pixel_size); //+ crt_dev_realm(target, screen_pixel_size, fragcoord);
}
//endregion

//region Game realm
vec3 crt_game_fragment(sampler2D target, vec2 uv, vec2 screen_pixel_size) {
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

	//region glow
vec3 getHDR(vec3 tex) {
    return max((tex - BLOOM_THRESHOLD) * BLOOM_INTENSITY, vec3(0.0));
}

vec3 gaussian(sampler2D sampler, vec2 uv) {
	vec3 sum = vec3(0.0);
	for (int i = 1; i <= BLUR_ITERATIONS; i++) {
		float angle = 360.0 / float(BLUR_SUBDIVISIONS);
		
		for (int j = 0; j < BLUR_SUBDIVISIONS; j++) {
			float dist = BLUR_SIZE * float(i + 1) / float(BLUR_ITERATIONS);
			float s = sin(angle * float(j));
			float c = cos(angle * float(j));
			
			sum += getHDR(texture(sampler, uv + vec2(c, s) * dist).xyz);
		}
	}
	
	sum /= float(BLUR_ITERATIONS * BLUR_SUBDIVISIONS);
	return sum * BLOOM_INTENSITY;
}

vec3 blend(vec3 a, vec3 b) {
	return 1.0 - (1.0 - a) * (1.0 - b);
}

vec4 glow_fragment(sampler2D target, vec2 uv) {
	vec4 tx = texture(target, uv);
	vec3 result = gaussian(target, uv);

	vec4 bg = vec4(result, 1);

	float gray = dot(bg.rgb, vec3(0.299, 0.587, 0.114));
	bg = vec4(bg.rgb, gray);
	
	return bg + tx;
}
	//endregion

vec4 game_realm(sampler2D target, vec2 uv, vec2 screen_pixel_size) {
	return glow_fragment(target, uv); //+ vec4(crt_game_fragment(target, uv, screen_pixel_size), 1.0);
}
//endregion


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
	//COLOR = texture(TEXTURE, UV - disp);
	
	//COLOR.rgb = dev_realm(TEXTURE, UV, SCREEN_PIXEL_SIZE, FRAGCOORD);
	if (circle(scaled_uv, size, 0.1) < 0.01) {
		COLOR.rgb = dev_realm(TEXTURE, UV - disp, SCREEN_PIXEL_SIZE, FRAGCOORD);
	} else {
		COLOR = game_realm(TEXTURE, UV - disp, SCREEN_PIXEL_SIZE);
	}
}

