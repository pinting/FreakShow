shader_type canvas_item;
render_mode blend_add;

// Based on github.com/kzerot edge detection shader

uniform vec4 edge_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_thickness : hint_range(0, 10) = 1.0;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	
	float w = size.x;
	float h = size.y;

	vec4 n0 = texture(TEXTURE, UV + vec2(-w, -h));
	vec4 n1 = texture(TEXTURE, UV + vec2(0.0, -h));
	vec4 n2 = texture(TEXTURE, UV + vec2(w, -h));
	vec4 n3 = texture(TEXTURE, UV + vec2(-w, 0.0));
	vec4 n4 = texture(TEXTURE, UV);
	vec4 n5 = texture(TEXTURE, UV + vec2(w, 0.0));
	vec4 n6 = texture(TEXTURE, UV + vec2(-w, h));
	vec4 n7 = texture(TEXTURE, UV + vec2(0.0, h));
	vec4 n8 = texture(TEXTURE, UV + vec2(w, h));

	vec4 sobel_edge_h = n2 + (2.0 * n5) + n8 - (n0 + (2.0 * n3) + n6);
  	vec4 sobel_edge_v = n0 + (2.0 * n1) + n2 - (n6 + (2.0 * n7) + n8);
	vec4 sobel = sqrt((sobel_edge_h * sobel_edge_h) + (sobel_edge_v * sobel_edge_v));
	
    float alpha = sobel.r;
	
    alpha += sobel.g;
    alpha += sobel.b;
    alpha /= 3.0;
	
	vec4 color = vec4(edge_color.rgb, alpha * n4.a);
	
	float outline = n4.a;
	
	outline *= n0.a;
	outline *= n1.a;
	outline *= n2.a;
	outline *= n3.a;
	outline *= n5.a;
	outline *= n6.a;
	outline *= n7.a;
	outline *= n8.a;
	outline = 1.0 - outline;
	
	vec4 outlined_result = mix(color, edge_color, outline * color.a);
	
	COLOR = mix(color, outlined_result, outlined_result.a);
}