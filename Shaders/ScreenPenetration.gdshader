shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec2 offset = vec2(0.5, 0.5);
uniform float value = 0.2;
uniform float dist = 0.2;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 ruv = uv - offset;
	vec2 dir = normalize(ruv);
	float len = length(ruv);
	
	if (len < dist) {
		len = pow(len * 2.0, 1.0 + value * ((dist - len) / dist)) * 0.5;
		ruv = len * dir;
		uv = ruv + offset;
	}

	COLOR = textureLod(SCREEN_TEXTURE, uv, 0.0);
}