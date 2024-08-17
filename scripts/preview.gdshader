// Shader for the preview tile map tiles
shader_type canvas_item;

uniform float transparency : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	COLOR.a = transparency * COLOR.a;
}
