shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float intensity = 1.0;
uniform float pixel_width = 800.0;
uniform float pixel_height = 480.0;

// Adjustable parameters
uniform float phosphor_thickness = 2.0;   // Lower = thicker phosphor bands (1.5-3.0)
uniform float phosphor_strength = 0.15;   // How strong the phosphor effect is (0.05-0.25)
uniform float flicker_speed = 100.0;      // Flicker frequency (40-150)
uniform float flicker_strength = 0.03;    // Flicker intensity (0.01-0.05)

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

    off_center *= 1.0 + 0.3 * off_center.yx * off_center.yx * abs(off_center.yx);
    vec2 uv0 = center + off_center;

    // === SCREEN BOUNDS MASK ===
    float inside =
        step(0.0, uv0.x) *
        step(0.0, uv0.y) *
        step(uv0.x, 1.0) *
        step(uv0.y, 1.0);

    vec3 color = vec3(0.05); // border color

    // === SAMPLE IMAGE (pre-curvature for effects) ===
    if (inside > 0.5){

        // chromatic aberration
        float shift = 0.006 * intensity;

        float r = texture(screen_texture, uv0 + vec2(shift,0.0)).r;
        float g = texture(screen_texture, uv0).g;
        float b = texture(screen_texture, uv0 - vec2(shift,0.0)).b;

        color = vec3(r,g,b);

        // noise
        float noise = (rand(uv0 * TIME) - 0.5) * 0.4 * intensity;
        color += noise;
    }
    
    // === APPLY RGB PHOSPHOR MASK (after scanlines) ===
    if (inside > 0.5){
        // Use original UV for phosphor mask to keep it consistent with pixel grid
        float triad = mod(floor(UV.x * pixel_width * phosphor_thickness), 3.0);
        
        vec3 mask = vec3(
            1.0 - step(0.5, abs(triad - 0.0)),
            1.0 - step(0.5, abs(triad - 1.0)),
            1.0 - step(0.5, abs(triad - 2.0))
        );
        
        color *= mix(vec3(1.0), mask, phosphor_strength);
    }
    
    // === APPLY FLICKER (last, affects everything) ===
    float flicker = (1.0 - flicker_strength) + flicker_strength * sin(TIME * flicker_speed);
    color *= flicker;

    COLOR = vec4(clamp(color,0.0,1.0),1.0);
}