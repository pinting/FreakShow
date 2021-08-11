shader_type canvas_item;
render_mode blend_mix;

uniform bool keep_size = true;
uniform vec2 offset = vec2(0.5, 0.5);
uniform float scale = 0.0;

uniform float glow_scale = 0.5;
uniform float glow_radius = 10.0;
uniform float line_thickness = 3.0;
uniform vec4 line_color: hint_color = vec4(0.96, 0.35, 0.45, 1);

vec4 safe_texture(sampler2D tex, vec2 p)
{
	if(!keep_size && (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0))
	{
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	
	return texture(tex, p);
}

vec4 outline(float thickness, vec4 base_color, sampler2D tex, vec2 uv, vec2 pixel_size)
{
	vec2 s = pixel_size * thickness;
	
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

vec4 glow(float amount, vec4 base_color, sampler2D tex, vec2 uv, vec2 pixel_size)
{
	vec4 g = base_color;
	float r = glow_radius;

	g += safe_texture(tex, uv + vec2(-r, -r) * pixel_size);
	g += safe_texture(tex, uv + vec2(-r, 0.0) * pixel_size);
	g += safe_texture(tex, uv + vec2(-r, r) * pixel_size);
	g += safe_texture(tex, uv + vec2(0.0, -r) * pixel_size);
	g += safe_texture(tex, uv + vec2(0.0, r) * pixel_size);
	g += safe_texture(tex, uv + vec2(r, -r) * pixel_size);
	g += safe_texture(tex, uv + vec2(r, 0.0) * pixel_size);
	g += safe_texture(tex, uv + vec2(r, r) * pixel_size);

	r *= 2.0;
	
	g += safe_texture(tex, uv + vec2(-r, -r) * pixel_size);
	g += safe_texture(tex, uv + vec2(-r, 0.0) * pixel_size);
	g += safe_texture(tex, uv + vec2(-r, r) * pixel_size);
	g += safe_texture(tex, uv + vec2(0.0, -r) * pixel_size);
	g += safe_texture(tex, uv + vec2(0.0, r) * pixel_size);
	g += safe_texture(tex, uv + vec2(r, -r) * pixel_size);
	g += safe_texture(tex, uv + vec2(r, 0.0) * pixel_size);
	g += safe_texture(tex, uv + vec2(r, r) * pixel_size);

	g /= 17.0; // Number of texture calls
	g *= amount;
	
	return g + vec4(base_color.rgb * base_color.a, base_color.a);
}

void fragment()
{
	vec4 color = safe_texture(TEXTURE, UV);
	vec4 outline = outline(line_thickness * scale, color, TEXTURE, UV, TEXTURE_PIXEL_SIZE);
	vec4 glow = glow(scale * glow_scale, outline, TEXTURE, UV, TEXTURE_PIXEL_SIZE);
	
	COLOR = glow;
}
