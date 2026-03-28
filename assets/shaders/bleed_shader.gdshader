shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float bleed_strength : hint_range(0.0, 2.0) = 1.0;
uniform float pixel_width = 800.0;
uniform float brightness_threshold : hint_range(0.0, 1.0) = 0.2;
uniform float shift_multiplier : hint_range(1.0, 16.0) = 4.0;

void fragment() {
    vec4 base = texture(screen_texture, UV);
    float brightness = dot(base.rgb, vec3(0.299, 0.587, 0.114));

    if (brightness >= brightness_threshold) {
        COLOR = base;
    } else {
        float shift = shift_multiplier / pixel_width;
        vec3 bleed = vec3(0.0);
        float total = 0.0;

        for (int x = -6; x <= 6; x++) {
            if (x == 0) continue;
            float dist = abs(float(x));
            float weight = 1.0 / dist;
            bleed += texture(screen_texture, UV + vec2(float(x) * shift, 0.0)).rgb * weight;
            total += weight;
        }

        bleed /= total;
        COLOR = vec4(base.rgb + bleed * bleed_strength, base.a);
    }
}