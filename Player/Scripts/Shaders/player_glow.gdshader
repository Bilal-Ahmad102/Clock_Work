// player_glow.gdshader
// Makes the player read as a light source: an emissive pulse over the whole
// sprite plus a glowing outline traced around the silhouette (alpha-based).
// Meant to be paired with gloom.gdshader on a full-screen overlay, but also
// looks right on its own. Safe on this project because each animation frame is
// its own texture (no atlas), so sampling neighbouring texels can't bleed into
// an adjacent frame.
shader_type canvas_item;

uniform vec4  glow_color : source_color = vec4(0.45, 0.80, 1.0, 1.0);
uniform float emission_strength : hint_range(1.0, 4.0) = 1.4; // brightens the body
uniform float outline_width     : hint_range(0.0, 8.0) = 1.5; // in texels
uniform float outline_strength  : hint_range(0.0, 4.0) = 1.8;
uniform float pulse_speed       : hint_range(0.0, 12.0) = 3.0;
uniform float pulse_amount      : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Breathing pulse in [1 - pulse_amount, 1].
	float pulse = 1.0 - pulse_amount + pulse_amount * (0.5 + 0.5 * sin(TIME * pulse_speed));

	// 1) Emissive brighten of the body itself.
	vec3 col = tex.rgb + tex.rgb * glow_color.rgb * (emission_strength - 1.0) * pulse;

	// 2) Alpha-based outline: sample 8 neighbours; where they are opaque but
	//    the current texel is transparent, we're on the outer border.
	vec2 px = TEXTURE_PIXEL_SIZE * outline_width;
	float a =
		  texture(TEXTURE, UV + vec2( px.x, 0.0)).a
		+ texture(TEXTURE, UV + vec2(-px.x, 0.0)).a
		+ texture(TEXTURE, UV + vec2(0.0,  px.y)).a
		+ texture(TEXTURE, UV + vec2(0.0, -px.y)).a
		+ texture(TEXTURE, UV + vec2( px.x,  px.y)).a
		+ texture(TEXTURE, UV + vec2(-px.x,  px.y)).a
		+ texture(TEXTURE, UV + vec2( px.x, -px.y)).a
		+ texture(TEXTURE, UV + vec2(-px.x, -px.y)).a;
	float neighbor = clamp(a, 0.0, 1.0);
	float outline  = clamp(neighbor - tex.a, 0.0, 1.0);

	vec3 outline_col = glow_color.rgb * outline_strength * pulse;

	// Composite the outline only into the transparent border pixels.
	col = mix(col, outline_col, outline * (1.0 - tex.a));
	float final_a = max(tex.a, outline * glow_color.a);

	COLOR = vec4(col, final_a);
}
