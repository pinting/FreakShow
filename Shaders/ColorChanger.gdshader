shader_type canvas_item;

uniform vec4 color_key : source_color;
uniform vec4 replacement_color : source_color;
uniform float tolerance;

void fragment()
{
    vec4 base = texture(TEXTURE, UV);
    vec3 rgb = base.rgb;
    vec3 diff = rgb - color_key.rgb;
	
    float m = max(max(abs(diff.r), abs(diff.g)), abs(diff.b));
    float brightness = length(rgb);
	
    rgb = mix(rgb, replacement_color.rgb * brightness, step(m, tolerance));
	
    COLOR = vec4(rgb.rgb, base.a);
}