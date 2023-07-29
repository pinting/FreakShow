shader_type canvas_item;
render_mode unshaded;

// Based on github.com/kzerot edge detection shader

uniform vec4 edge_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 background_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_thickness: hint_range(0, 10) = 1.0;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	vec4 base_color = texture(TEXTURE, UV);
	
	float w = size.x;
	float h = size.y;

	vec4 n0 = texture(TEXTURE, UV + vec2(-w, -h));
	vec4 n1 = texture(TEXTURE, UV + vec2(0.0, -h));
	vec4 n2 = texture(TEXTURE, UV + vec2(w, -h));
	vec4 n3 = texture(TEXTURE, UV + vec2(-w, 0.0));
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
	
	vec4 first_pass = vec4(edge_color.rgb, alpha * base_color.a);
	
	float outline = base_color.a;
	
	outline *= n0.a;
	outline *= n1.a;
	outline *= n2.a;
	outline *= n3.a;
	outline *= n5.a;
	outline *= n6.a;
	outline *= n7.a;
	outline *= n8.a;
	outline = 1.0 - outline;
	
	vec4 second_pass = mix(first_pass, edge_color, outline * first_pass.a);
	vec4 color_behind = mix(base_color, background_color, base_color.a);
	float a = COLOR.a;
	
	COLOR = mix(color_behind, second_pass, second_pass.a);
	
	COLOR.a = COLOR.a * (1.0 - COLOR.r * COLOR.b * COLOR.g);
}