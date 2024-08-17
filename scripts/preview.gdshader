// Shader for the preview tile map tiles
shader_type canvas_item;

uniform float transparency : hint_range(0.0, 1.0) = 0.5;
uniform bool remove = false;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	if (!remove) {
		COLOR = texture(TEXTURE, UV);
		COLOR.a = transparency * COLOR.a;
	}
	else {
		COLOR = texture(screen_texture, SCREEN_UV);
		COLOR = mix(COLOR, vec4(1, 1, 1, 1), 0.5);
	}
}
