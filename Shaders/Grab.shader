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

vec4 outline(float amount, vec4 color, sampler2D tex, vec2 uv, vec2 pixel_size)
{
	vec2 size = pixel_size * amount;
	float outline = color.a;
	
	outline *= safe_texture(tex, uv + vec2(0, size.y)).a;
	outline *= safe_texture(tex, uv + vec2(size.x, 0)).a;
	outline *= safe_texture(tex, uv + vec2(0, -size.y)).a;
	outline *= safe_texture(tex, uv + vec2(-size.x, size.y)).a;
	outline *= safe_texture(tex, uv + vec2(size.x, size.y)).a;
	outline *= safe_texture(tex, uv + vec2(-size.x, -size.y)).a;
	outline *= safe_texture(tex, uv + vec2(size.x, -size.y)).a;
	outline = 1.0 - outline;
	
	vec4 outlined_result = mix(color, line_color, outline * color.a);
	
	return mix(color, outlined_result, outlined_result.a);
}

vec4 glow(float amount, sampler2D tex, vec2 uv, vec2 pixel_size)
{
	vec4 color = texture(tex, uv);
	float r = glow_radius;

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
	
	vec3 combined = r_glow.rgb + r_bend.rgb;
	vec4 base_color = vec4(combined.r, combined.g, combined.b, r_bend.a);
	
	if (scale > 0.5) 
	{
		COLOR = outline(scale, base_color, TEXTURE, UV, TEXTURE_PIXEL_SIZE);
	}
	else
	{
		COLOR = base_color;
	}
}
