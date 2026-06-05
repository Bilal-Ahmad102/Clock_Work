shader_type canvas_item;

uniform float stamina : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	
	// only cut off pixels beyond the health threshold
	if (UV.y <= stamina) {
		col = vec4(0.0);
	}
	
	COLOR = col;
}