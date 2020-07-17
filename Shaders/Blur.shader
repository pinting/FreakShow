shader_type canvas_item;
render_mode blend_mix;

uniform float radius = 4.0;

void fragment()
{
	vec4 base = texture(TEXTURE, UV);
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;

	base += texture(TEXTURE, UV + vec2(0.0, -radius) * pixel_size);
	base += texture(TEXTURE, UV + vec2(0.0, radius) * pixel_size);
	base += texture(TEXTURE, UV + vec2(-radius, 0.0) * pixel_size);
	base += texture(TEXTURE, UV + vec2(radius, 0.0) * pixel_size);
	
	base /= 5.0;

	COLOR = base;
}
