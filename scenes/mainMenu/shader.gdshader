shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float intensity = 1.0;
uniform float pixel_width = 800.0;
uniform float pixel_height = 480.0;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment(){

    vec2 uv = UV;

    // === PIXEL SNAP ===
    vec2 pixel = vec2(pixel_width, pixel_height);
    uv = floor(uv * pixel) / pixel;

    // === CRT CURVATURE ===
    vec2 center = vec2(0.5);
    vec2 off_center = uv - center;

    off_center *= 1.0 + 0.3 * off_center.yx * off_center.yx * abs(off_center.yx); //pow(abs(off_center.yx), vec2(2.5));
    vec2 uv0 = center + off_center;

    // === SCREEN BOUNDS MASK ===
    float inside =
        step(0.0, uv0.x) *
        step(0.0, uv0.y) *
        step(uv0.x, 1.0) *
        step(uv0.y, 1.0);

    vec3 color = vec3(0.05); // border color

    // === SAMPLE IMAGE ===
    if (inside > 0.5){

        // VHS jitter
        float rowIndex = floor(uv0.y * pixel_height);
        float tStep = floor(TIME * 10.0);
        vec2 seed = vec2(rowIndex, tStep);

        if (rand(seed) < 0.02){
            float dir = rand(seed + 10.0) < 0.5 ? -1.0 : 1.0;
            uv0.x += dir / pixel_width;
        }

        // glitch
        if (rand(vec2(floor(TIME * 12.0),0.0)) > 0.95){
            float glitch_y = step(0.3, fract(uv0.y * 10.0));
            float glitch_offset = (rand(vec2(TIME,uv0.y)) - 0.5) * 0.2 * intensity;
            uv0.x += glitch_offset * glitch_y;
        }

        // chromatic aberration
        float shift = 0.006 * intensity;

        float r = texture(screen_texture, uv0 + vec2(shift,0.0)).r;
        float g = texture(screen_texture, uv0).g;
        float b = texture(screen_texture, uv0 - vec2(shift,0.0)).b;

        color = vec3(r,g,b);

        // noise
        float noise = (rand(uv0 * TIME) - 0.5) * 0.08 * intensity;
        color += noise;

        // scanlines
        float scanline = cos(uv0.y * pixel_height * 3.14159);
		scanline = clamp(scanline * 0.24 + 0.82,0.0,1.0);
        color *= scanline;

        // phosphor glow
        vec3 glow = texture(screen_texture, uv0 + vec2(0.0,1.0/pixel_height)).rgb * 0.2;
        color = max(color, glow);

        // === RGB PHOSPHOR MASK ===
		float triad = mod(floor(UV.x * pixel_width * 3.0), 3.0);

		vec3 mask = vec3(
		    1.0 - step(0.5, abs(triad - 0.0)),
		    1.0 - step(0.5, abs(triad - 1.0)),
		    1.0 - step(0.5, abs(triad - 2.0))
		);

		color *= mix(vec3(1.0), mask, 0.08);
    }
	
	float flicker = 0.98 + 0.02 * sin(TIME * 40.0);
	color *= flicker;

    COLOR = vec4(clamp(color,0.0,1.0),1.0);
}