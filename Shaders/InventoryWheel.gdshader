shader_type canvas_item;

uniform float width = 0.1;

void fragment() {
	float d = distance(UV, vec2(0.5, 0.5));
	
	COLOR.a = (d > 0.5 - width && d <= 0.5) ? COLOR.a : 0.0;
}
