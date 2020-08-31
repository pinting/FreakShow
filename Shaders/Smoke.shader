shader_type canvas_item;

uniform vec3 color = vec3(0, 0, 0);

float rand(vec2 v) 
{
	return fract(cos(dot(v, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 v) 
{
	vec2 d = vec2(0.0, 1.0);
	vec2 b = floor(v);
	vec2 f = smoothstep(vec2(0.0), vec2(1.0), fract(v));

	return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}

float fbm(vec2 v) 
{
	return noise(v) * 0.5 + noise(v * 2.0) * 0.25 + noise(v * 4.0) * 0.125 + noise(v * 8.0) * 0.065;
}

void fragment() 
{
	vec2 scaled_uv = UV * 20.0;
	vec2 motion = vec2(fbm(scaled_uv + vec2(TIME * -0.5, TIME * 0.5)));
	float result = fbm(scaled_uv + motion);
	
	COLOR = vec4(color, result * 0.5);
}