shader_type canvas_item; // Just makes shit brighter, doesnt work

render_mode blend_add; 

uniform sampler2D screen_texture : hint_screen_texture;

uniform float threshold = 0.6;
uniform float intensity = 1.3;
uniform float blur_size = 2.5;

void fragment() {
    vec2 texel = vec2(1.0) / vec2(textureSize(screen_texture, 0));

    vec3 col = texture(screen_texture, SCREEN_UV).rgb;

    float brightness = max(col.r, max(col.g, col.b));

    // soft threshold
    float mask = smoothstep(threshold, threshold + 0.2, brightness);

    vec3 blur = vec3(0.0);

    // near
    blur += texture(screen_texture, SCREEN_UV + vec2(texel.x, 0.0) * blur_size).rgb;
    blur += texture(screen_texture, SCREEN_UV - vec2(texel.x, 0.0) * blur_size).rgb;
    blur += texture(screen_texture, SCREEN_UV + vec2(0.0, texel.y) * blur_size).rgb;
    blur += texture(screen_texture, SCREEN_UV - vec2(0.0, texel.y) * blur_size).rgb;

    // far (bleed)
    blur += texture(screen_texture, SCREEN_UV + vec2(texel.x, texel.y) * blur_size * 2.0).rgb;
    blur += texture(screen_texture, SCREEN_UV - vec2(texel.x, texel.y) * blur_size * 2.0).rgb;
    blur += texture(screen_texture, SCREEN_UV + vec2(-texel.x, texel.y) * blur_size * 2.0).rgb;
    blur += texture(screen_texture, SCREEN_UV + vec2(texel.x, -texel.y) * blur_size * 2.0).rgb;

    blur *= 0.125;

    // glow only (no base image!)
    vec3 glow = blur * intensity * mask;

    COLOR = vec4(glow, 1.0);
}