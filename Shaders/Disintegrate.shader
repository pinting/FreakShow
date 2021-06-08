shader_type canvas_item;
render_mode blend_mix;

uniform float amount = 1.0;

const float pi = 3.14159265359;

float rand(vec2 v)
{
	return fract(sin(dot(v, vec2(56, 78)) * 1000.0) * 1000.0);
}

void fragment()
{
	vec4 base = texture(TEXTURE, UV);

	if (amount > 0.0)
	{
		base.a *= pow(rand(UV), amount);
	}

	COLOR = base;
}
