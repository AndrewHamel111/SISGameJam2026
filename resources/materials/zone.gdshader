shader_type spatial;
render_mode cull_disabled, blend_add;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float max_height = 10.0;

varying vec3 world_position;

void vertex() {
	// Called for every vertex the material is visible on.
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	float scaled_time = TIME * 4.0;

	float height = (world_position.y) + sin(scaled_time + world_position.x*5.0 + world_position.z*5.0) * 0.05;
	if(height > max_height)
		discard;

	float tone = sin(scaled_time + world_position.y) / 2.0 + 0.8;
	vec3 color = glow_color.rgb * tone;
	ALBEDO = vec3(0.0, 1.0, 0.0) * color;
	ALPHA = clamp(tone, 0.0, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
