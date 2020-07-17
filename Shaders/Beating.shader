shader_type canvas_item;
render_mode blend_mix;

uniform float speed = 1.0;
uniform float scale = 0.3;
uniform float offset = 0.85;
uniform bool keep_size = false;

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
	vec2 ruv = UV - vec2(0.5, 0.5);
	vec2 dir = normalize(ruv);
	float len = length(ruv);

	len = pow(len * 2.0, scale * abs(cos(speed * TIME)) + offset) * 0.5;
	ruv = len * dir;

	COLOR = safe_texture(TEXTURE, ruv +  vec2(0.5, 0.5));
}
