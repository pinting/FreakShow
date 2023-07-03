shader_type canvas_item;
render_mode blend_mix;

uniform vec2 offset = vec2(0.5, 0.5);
uniform float value = 2.0;
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
	vec2 ruv = UV - offset;
	vec2 dir = normalize(ruv);
	float len = length(ruv);

	len = pow(len * 2.0, value) * 0.5;
	ruv = len * dir;

	COLOR = safe_texture(TEXTURE, ruv + offset);
}
