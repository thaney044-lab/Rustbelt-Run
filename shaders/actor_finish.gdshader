shader_type canvas_item;
void fragment() {
	vec4 source = texture(TEXTURE,UV);
	vec4 tint = COLOR;
	float luma = dot(source.rgb,vec3(0.2126,0.7152,0.0722));
	vec3 body = source.rgb * mix(vec3(0.90,1.025,1.055),vec3(1.08,1.02,0.92),smoothstep(0.15,0.7,luma));
	float lit_edge = max(0.0,source.a-texture(TEXTURE,UV+TEXTURE_PIXEL_SIZE*vec2(-2.0,-1.5)).a);
	body += vec3(0.30,0.19,0.07)*lit_edge*0.42;
	COLOR = vec4(clamp(body,0.0,1.0),source.a)*tint;
}
