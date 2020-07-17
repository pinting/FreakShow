shader_type canvas_item;
render_mode blend_mix;

uniform vec2 offset = vec2(0.5, 0.5);
uniform float penetration = 1.0;
uniform bool keep_size = true;
uniform float glow_radius = 10.0;
uniform float glow_amount = 0.0;

vec4 safe_texture(sampler2D tex, vec2 p)
{
	if(!keep_size && (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0))
	{
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	
	return texture(tex, p);
}

void fragment()
{
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	vec4 color = safe_texture(TEXTURE, UV);

	float r = glow_radius;
	vec4 glow = color;

	glow += safe_texture(TEXTURE, UV + vec2(-r, -r) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(-r, 0.0) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(-r, r) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(0.0, -r) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(0.0, r) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(r, -r) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(r, 0.0) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(r, r) * pixel_size);

	r *= 2.0;
	
	glow += safe_texture(TEXTURE, UV + vec2(-r, -r) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(-r, 0.0) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(-r, r) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(0.0, -r) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(0.0, r) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(r, -r) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(r, 0.0) * pixel_size);
	glow += safe_texture(TEXTURE, UV + vec2(r, r) * pixel_size);

	glow /= 17.0; // Number of safe_texture calls
	glow *= glow_amount;

	vec2 ruv = UV - offset;
	vec2 dir = normalize(ruv);
	float len = length(ruv);

	len = pow(len * 2.0, penetration) * 0.5;
	ruv = len * dir;

	COLOR = safe_texture(TEXTURE, ruv + offset) + glow;
}
