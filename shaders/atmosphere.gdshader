shader_type canvas_item;
render_mode unshaded, blend_mix;

void fragment() {
	vec2 uv = UV;
	float edge = smoothstep(0.25, 0.88, distance(uv,vec2(0.5,0.46)));
	vec3 cool = vec3(0.025,0.065,0.073);
	COLOR = vec4(cool,edge*0.30);
}
