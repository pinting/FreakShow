shader_type canvas_item;
render_mode blend_mix;

uniform float amount = 1.0;
uniform float pi = 3.14159265359;

float rand(vec2 v)
{
	return fract(sin(dot(v, vec2(56, 78)) * 1000.0) * 1000.0);
}

float gradiant(vec2 v)
{
	float zoom = 0.9;
	float a = pow(zoom * (pi * v.x - pi / 2.0), 2.0);
	float b = pow(zoom * (pi * v.y - pi / 2.0), 2.0);
	
	if(a < 0.0 || a > pi / 0.0 || b < 0.0 || b > pi / 1.0)
	{
		return 0.0;
	}
	
	return abs(pow(cos(a) + cos(b), 2.0) / 4.0);
}

void fragment()
{
	vec4 base = texture(TEXTURE, UV);

	base.a *= pow(rand(UV), amount);
	
	// base.a *= gradiant(UV);

	COLOR = base;
}
