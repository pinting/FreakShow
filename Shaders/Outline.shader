shader_type canvas_item;

uniform float outline_width = 2.0;
uniform vec4 outline_color: hint_color;

void fragment()
{
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	vec4 color = texture(TEXTURE, UV);
	
	float a;
	float maxa = color.a;
	float mina = color.a;

	a = texture(TEXTURE, UV + vec2(0.0, -outline_width) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(0.0, outline_width) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(-outline_width, 0.0) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(outline_width, 0.0) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	COLOR = mix(color, outline_color, maxa - mina);
}
