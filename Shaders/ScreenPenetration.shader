shader_type canvas_item;

uniform vec2 offset = vec2(0.5, 0.5);
uniform float value = 0.1;
uniform float dist = 0.1;

void fragment() {
	vec2 uv = UV;
	vec2 ruv = uv - offset;
	vec2 dir = normalize(ruv);
	float len = length(ruv);
	
	if (len < dist) {
		len = pow(len * 2.0, 1.0 + value * ((dist - len) / dist)) * 0.5;
		ruv = len * dir;
		uv = ruv + offset;
	}
	
	uv.y = 1.0 - uv.y;

	COLOR = textureLod(SCREEN_TEXTURE, uv, 0.0);
}