shader_type canvas_item;
render_mode blend_mix;

uniform float time_offset = 0;

vec2 hash(vec2 p)
{
	uvec2 q = uvec2(ivec2(p)) * uvec2(15, 40);
	q = (q.x ^ q.y) * uvec2(1, 1);

	return vec2(q) * (1.0 / float(90));
}

float worley(vec2 uv, float time)
{
	uv *= 10.0;
	uv += time * 0.25;
	
	vec2 id = floor(uv);
	vec2 gv = fract(uv);
	
	float minDist = 100.0;

	for (float y = -1.; y <= 1.; ++y)
	{
		for(float x = -1.; x <= 1.; ++x)
		{
			vec2 offset = vec2(x, y);
			vec2 h = hash(id + offset) * 0.8 + 0.1;
			
			h = (((sin(h * time) + 1.0) * 0.5) * 0.8 + 0.1) + offset;

			float p = length(gv - h);

			if (p < minDist)
			{
				minDist = p;
			}
		}
	}
	
	return minDist;
}

vec4 a(vec2 uv, float time)
{
	float t = time * 1.0;
	float l = uv.x;
	
	float r = sin(t * 0.51 + l * 1.5 + 93.0) + sin(t * 0.12 + l * 3.2 + 35.0);
	float g = sin(t * 0.37 - l * 1.7 + 12.1) + sin(t * 0.17 + l * 1.9 - 85.0);
	float b = sin(t * 0.45 + l * 2.1 + 15.0) + sin(t * 0.22 + l * 2.5 + 95.0);
	
	vec3 col = vec3(r, g, b) * 0.2 + 0.5;
	
	return vec4(col * uv.y * (1.0 - uv.y) * 4.0, 1.0);
} 

vec4 b(vec2 uv, float time, vec2 resolution)
{
	float aspect_ratio = resolution.x / resolution.y;

	uv.x *= aspect_ratio;
	
	vec3 col = vec3(0.0);
	float w = worley(uv, time);

	col += 1.0 - w;
	col.r *= smoothstep(1.7, 0.0, length(uv - (sin(vec2(0.7, 0.5) + time) + 1.0) * 0.5));
	uv.x = 1.2 - uv.x;
	col.g *= smoothstep(1.7, 0.0, length(uv - (cos(0.5 + time) + 1.0) * 0.5));
	col.b *= 1.0 - sin(col.r + col.g);
	
	return vec4(col, 1.0 - ((col.r + col.g + col.b) / 3.0));
}

void fragment()
{
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
    float time = TIME + time_offset;

	vec4 ra = a(UV, time);
    vec4 rb = b(UV, time, resolution);

    COLOR = vec4((ra.r + rb.r) / 2.0, (ra.g + rb.g) / 2.0, (ra.b + rb.b) / 2.0, rb.a);
}