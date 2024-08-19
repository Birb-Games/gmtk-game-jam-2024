// Shader for the preview tile map tiles
shader_type canvas_item;

uniform float transparency : hint_range(0.0, 1.0) = 0.5;
uniform bool remove = false;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec4 add_tile_frag(sampler2D tex, vec2 uv)
{
	vec4 color = texture(tex, uv);
	color.a = transparency * color.a;
	return color;
}

vec4 delete_tile_frag(vec2 screen_uv)
{
	vec4 color = texture(screen_texture, screen_uv);
	color = mix(color, vec4(1, 1, 1, 1), 0.5);
	return color;
}

void fragment() {
	COLOR = add_tile_frag(TEXTURE, UV) * (1.0 - float(remove)) + delete_tile_frag(SCREEN_UV) * float(remove);
}
