shader_type canvas_item;

uniform float scale = 1.0;

vec2 random(vec2 uv){
    uv = vec2(dot(uv, vec2(127.1,311.7)), dot(uv, vec2(269.5,183.3)));
	
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, uv_fract);
	
    return mix(mix(dot(random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0)),
                   dot(random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0)), blur.x),
               mix(dot(random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0)),
                   dot(random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0)), blur.x), blur.y) + 0.5;
}

void fragment() {
	float noise = noise(UV * 20.0) * scale;
	
	noise = min(1.0, noise + scale);
	
	if (noise > 0.5) {
		COLOR.a *= noise;
	} else {
		COLOR.a = 0.0;
	}
}
