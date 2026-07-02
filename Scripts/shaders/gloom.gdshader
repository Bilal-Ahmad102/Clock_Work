// gloom.gdshader
// Full-screen post effect for a dark, gloomy mood. Reads what has already been
// drawn (screen texture), desaturates + blue-tints + darkens it and adds a
// vignette, then reveals the original bright image inside a soft radial halo
// around the player so the player stays lit while the world falls into gloom.
// Drive `light_pos` / `viewport_size` from gloom.gd (they track the player).
shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

// --- world grade ---
uniform vec4  gloom_tint : source_color = vec4(0.30, 0.35, 0.55, 1.0);
uniform float darkness         : hint_range(0.0, 1.0) = 0.75; // 0 = untouched, 1 = black
uniform float desaturation     : hint_range(0.0, 1.0) = 0.60;
uniform float vignette_strength : hint_range(0.0, 2.0) = 1.10;

// --- player light halo (fed from gloom.gd) ---
uniform vec2  light_pos      = vec2(0.5, 0.5);       // screen UV of the player
uniform vec2  viewport_size  = vec2(640.0, 360.0);   // pixels
uniform float light_radius   = 220.0;                // fully-lit radius, pixels
uniform float light_softness = 160.0;                // fade distance, pixels
uniform vec4  light_color : source_color = vec4(1.0, 0.85, 0.55, 1.0);

void fragment() {
	vec3 src = texture(screen_tex, SCREEN_UV).rgb;

	// Gloomy grade: desaturate -> tint -> darken.
	float luma   = dot(src, vec3(0.299, 0.587, 0.114));
	vec3  desat  = mix(src, vec3(luma), desaturation);
	vec3  gloomy = desat * gloom_tint.rgb;
	vec3  dark   = gloomy * (1.0 - darkness);

	// Vignette darkens the screen edges further.
	float vig = smoothstep(0.8, 0.2, length(SCREEN_UV - vec2(0.5)) * vignette_strength);
	dark *= mix(0.35, 1.0, vig);

	// Radial light around the player (distance measured in pixels so it stays
	// circular regardless of aspect ratio).
	float dist  = length((SCREEN_UV - light_pos) * viewport_size);
	float light = 1.0 - smoothstep(light_radius, light_radius + light_softness, dist);

	// Fade from gloom back toward the bright original near the player, plus a
	// subtle warm additive core.
	vec3 lit = mix(dark, src * light_color.rgb, light);
	lit += light_color.rgb * light * 0.04;

	COLOR = vec4(lit, 1.0);
}
