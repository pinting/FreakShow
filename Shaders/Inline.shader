shader_type canvas_item;
render_mode blend_premul_alpha;

uniform float aura_width = 2.0;
uniform float threshold = 0.01;
uniform vec4 border_color: hint_color;

vec4 safe_texture(sampler2D tex, vec2 p)
{
	if(p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0)
	{
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	
	return texture(tex, p);
}

void fragment() 
{
	vec4 base = texture(TEXTURE, UV);
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;

	// North
	vec4 n = safe_texture(TEXTURE, UV + vec2(0.0, -aura_width) * pixel_size);

	// South
	vec4 s = safe_texture(TEXTURE, UV + vec2(0.0, aura_width) * pixel_size);

	// West
	vec4 w = safe_texture(TEXTURE, UV + vec2(-aura_width, 0.0) * pixel_size);

	// East
	vec4 e = safe_texture(TEXTURE, UV + vec2(aura_width, 0.0) * pixel_size);
	
	base.rgb *= base.a;
	
	COLOR = base;
	
	// If the end of the texture is close enough
	if(n.a < threshold || s.a < threshold || w.a < threshold || e.a < threshold)
	{
		// But only points inside the texture should be set to the border color
		if(base.a > threshold)
		{
			COLOR.rgb = base.rgb * (1.0 - border_color.a) + border_color.rgb * border_color.a;
		}
	}
}
