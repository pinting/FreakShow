shader_type canvas_item;
render_mode blend_premul_alpha;

uniform float radius = 10.0;
uniform float amount = 0.5;

void fragment()
{
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	vec4 color = texture(TEXTURE, UV);
	
	float r = radius;
	vec4 glow = color;

	glow += texture(TEXTURE, UV + vec2(-r, -r) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(-r, 0.0) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(-r, r) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(0.0, -r) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(0.0, r) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(r, -r) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(r, 0.0) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(r, r) * pixel_size);

	r *= 2.0;
	
	glow += texture(TEXTURE, UV + vec2(-r, -r) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(-r, 0.0) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(-r, r) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(0.0, -r) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(0.0, r) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(r, -r) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(r, 0.0) * pixel_size);
	glow += texture(TEXTURE, UV + vec2(r, r) * pixel_size);

	glow /= 17.0; // Number of texture calls
	glow *= amount;
	
	color.rgb *= color.a;

	COLOR = glow + color;
}
