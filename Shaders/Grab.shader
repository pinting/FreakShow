shader_type canvas_item;
render_mode blend_mix;

uniform bool keep_size = true;
uniform vec2 offset = vec2(0.5, 0.5);
uniform float scale = 0.0;

uniform float glow_radius = 10.0;
uniform vec4 line_color: hint_color = vec4(0.96, 0.35, 0.45, 1);

vec4 safe_texture(sampler2D tex, vec2 p)
{
	if(!keep_size && (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0))
	{
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	
	return texture(tex, p);
}

vec4 outline(float amount, vec4 base_color, sampler2D tex, vec2 uv, vec2 pixel_size)
{
	vec2 s = pixel_size * amount;
	
	float color = base_color.a;
	
	color *= safe_texture(tex, uv + vec2(0, s.y)).a;
	color *= safe_texture(tex, uv + vec2(s.x, 0)).a;
	color *= safe_texture(tex, uv + vec2(0, -s.y)).a;
	color *= safe_texture(tex, uv + vec2(-s.x, s.y)).a;
	color *= safe_texture(tex, uv + vec2(s.x, s.y)).a;
	color *= safe_texture(tex, uv + vec2(-s.x, -s.y)).a;
	color *= safe_texture(tex, uv + vec2(s.x, -s.y)).a;
	color = 1.0 - color;
	
	vec4 outlined_result = mix(base_color, line_color, color * base_color.a);
	
	return mix(base_color, outlined_result, outlined_result.a);
}

vec4 glow(float amount, sampler2D tex, vec2 uv, vec2 pixel_size)
{
	float r = glow_radius;
	
	vec4 color = texture(tex, uv);

	color += safe_texture(tex, uv + vec2(-r, -r) * pixel_size);
	color += safe_texture(tex, uv + vec2(-r, 0.0) * pixel_size);
	color += safe_texture(tex, uv + vec2(-r, r) * pixel_size);
	color += safe_texture(tex, uv + vec2(0.0, -r) * pixel_size);
	color += safe_texture(tex, uv + vec2(0.0, r) * pixel_size);
	color += safe_texture(tex, uv + vec2(r, -r) * pixel_size);
	color += safe_texture(tex, uv + vec2(r, 0.0) * pixel_size);
	color += safe_texture(tex, uv + vec2(r, r) * pixel_size);

	r *= 2.0;
	
	color += safe_texture(tex, uv + vec2(-r, -r) * pixel_size);
	color += safe_texture(tex, uv + vec2(-r, 0.0) * pixel_size);
	color += safe_texture(tex, uv + vec2(-r, r) * pixel_size);
	color += safe_texture(tex, uv + vec2(0.0, -r) * pixel_size);
	color += safe_texture(tex, uv + vec2(0.0, r) * pixel_size);
	color += safe_texture(tex, uv + vec2(r, -r) * pixel_size);
	color += safe_texture(tex, uv + vec2(r, 0.0) * pixel_size);
	color += safe_texture(tex, uv + vec2(r, r) * pixel_size);

	color /= 17.0; // Number of texture calls
	color *= amount;
	
	return color;
}

vec4 bend(float amount, sampler2D tex, vec2 uv, vec2 pixel_size)
{
	vec2 ruv = uv - offset;
	vec2 dir = normalize(ruv);
	float len = length(ruv);

	len = pow(len * 2.0, amount) * 0.5;
	ruv = len * dir;
	
	return safe_texture(tex, ruv + offset);
} 

void fragment()
{
	vec4 r_glow = glow(scale / 2.0, TEXTURE, UV, TEXTURE_PIXEL_SIZE);
	vec4 r_bend = bend(scale / 10.0 + 1.0, TEXTURE, UV, TEXTURE_PIXEL_SIZE);
	
	vec3 sum = max(min(r_glow.rgb + r_bend.rgb, vec3(1.0)), vec3(0.0));
	vec4 color = vec4(sum.rgb, r_bend.a);
	
	if (scale > 0.5) 
	{
		COLOR = outline(scale, color, TEXTURE, UV, TEXTURE_PIXEL_SIZE);
	}
	else
	{
		COLOR = color;
	}
}
