shader_type canvas_item;
render_mode blend_mix;

uniform bool keep_size = true;
uniform vec2 offset = vec2(0.5, 0.5);
uniform float grab_amount = 1.0;
uniform float glow_radius = 10.0;
uniform float glow_amount = 0.0;

vec4 safe_texture2ddsa(sampler2D tex, vec2 p)
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
	vec4 color = texture(TEXTURE, UV);
	
	vec4 glow = color;
	float r = glow_radius;

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
	glow *= glow_amount;

	vec2 ruv = UV - offset;
	vec2 dir = normalize(ruv);
	float len = length(ruv);

	len = pow(len * 2.0, grab_amount) * 0.5;
	ruv = len * dir;
	
	vec4 fatty = texture(TEXTURE, ruv + offset);
	vec3 combined = fatty.rgb + glow.rgb;
	
	COLOR = vec4(combined.r, combined.g, combined.b, fatty.a);
}
