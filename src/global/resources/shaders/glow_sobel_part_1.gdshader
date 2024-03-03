shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;
//region Uniforms
//region Magnify
group_uniforms magnify;
uniform vec2 center = vec2(0.5, 0.5);
uniform float size = -0.1;
uniform float thickness = 0.05;
uniform float force = 0.1;
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

vec3 dev_realm(sampler2D target, vec2 screen_uv, vec2 screen_pixel_size, vec4 fragcoord) {
	return sobel_fragment(target, screen_uv, screen_pixel_size); //* crt_dev_realm(target, screen_pixel_size, fragcoord);
}
//endregion

//region Game realm
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

