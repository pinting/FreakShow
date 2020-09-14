shader_type canvas_item;

uniform vec4 shadow_color : hint_color;
uniform float tile_factor = 1.0;
uniform float aspect_ratio = 0.6;
uniform sampler2D texture_offset_uv : hint_black;
uniform vec2 texture_offset_scale = vec2(1.0, 0.5);
uniform float texture_offset_height = 0.04;
uniform float texture_offset_time_scale = 0.03;
uniform float sine_time_scale = 3;
uniform vec2 sine_offset_scale = vec2(0.4, 1.4);
uniform float sine_wave_size = 0.06;
uniform vec2 wave_scale = vec2(0.0, 1.0); 


void fragment()
{
	vec2 base_uv_offset = UV * texture_offset_scale;
	
	base_uv_offset += TIME * texture_offset_time_scale;

	vec2 offset_texture_uv = texture(texture_offset_uv, base_uv_offset).rg;
	vec2 offset_texture_uv_with_height = offset_texture_uv * texture_offset_height;
	vec2 texture_based_offset = offset_texture_uv_with_height * 2.0 - 1.0;

	vec2 adjusted_uv = UV * tile_factor;
	
	adjusted_uv.y *= aspect_ratio;
	adjusted_uv += texture_based_offset;

	adjusted_uv.x += sin(TIME * sine_time_scale + (adjusted_uv.x + adjusted_uv.y) * sine_offset_scale.x) * sine_wave_size;
	adjusted_uv.y += cos(TIME * sine_time_scale + (adjusted_uv.x + adjusted_uv.y) * sine_offset_scale.y) * sine_wave_size;

	float wave_input = adjusted_uv.x * wave_scale.x + adjusted_uv.y * wave_scale.y;
	float sine_wave_height = sin(TIME * sine_time_scale + wave_input * sine_offset_scale.y);
	float water_height = ( sine_wave_height + offset_texture_uv.g ) * 0.5;

	COLOR = mix(texture(TEXTURE, adjusted_uv), shadow_color, water_height * 0.4 * shadow_color.a);
	
	NORMALMAP = texture(NORMAL_TEXTURE, adjusted_uv / 5.0).rgb;
}
