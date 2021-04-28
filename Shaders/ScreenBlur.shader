shader_type canvas_item;
render_mode unshaded;

uniform float scale_color = 0.5;
uniform float radius = 10.0;

void fragment()
{
	vec4 base = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	vec2 pixel_size = SCREEN_PIXEL_SIZE;

	base += textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, -radius) * pixel_size, 0.0);
	base += textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, radius) * pixel_size, 0.0);
	base += textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(-radius, 0.0) * pixel_size, 0.0);
	base += textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(radius, 0.0) * pixel_size, 0.0);
	
	base /= 5.0;

	COLOR = vec4(base.r * scale_color, base.g * scale_color, base.b * scale_color, base.a);
}
