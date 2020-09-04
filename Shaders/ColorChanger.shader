shader_type canvas_item;

uniform vec4 color_key : hint_color;
uniform vec4 replacement_color : hint_color;
uniform float tolerance;

void fragment()
{
    vec4 base = texture(TEXTURE, UV);
    vec3 rgb = base.rgb;
    vec3 diff3 = rgb - color_key.rgb;
	
    float m = max(max(abs(diff3.r), abs(diff3.g)), abs(diff3.b));
    float brightness = length(rgb);
	
    rgb = mix(rgb, replacement_color.rgb * brightness, step(m, tolerance));
	
    COLOR = vec4(rgb.rgb, base.a);
}