shader_type canvas_item;
render_mode unshaded;
uniform sampler2D panorama : source_color, filter_linear;
void fragment() {
	vec2 uv = UV;
	float wave = sin(uv.y*75.0+TIME*0.65)*0.006+sin(uv.y*173.0-TIME*0.9)*0.002;
	vec3 reflected = texture(panorama,vec2(clamp(uv.x+wave,0.0,1.0),0.67-uv.y*0.30)).rgb;
	vec3 water = mix(vec3(0.035,0.15,0.16),reflected*vec3(0.50,0.68,0.65),0.60);
	float ripple = pow(max(0.0,sin(uv.y*260.0+sin(uv.x*35.0+TIME*.3)*2.0+TIME)),20.0);
	float sun = exp(-pow((uv.x-0.65)/0.10,2.0))*ripple;
	water += vec3(0.30,0.23,0.12)*sun+vec3(0.04,0.065,0.06)*ripple;
	COLOR = vec4(water,0.96);
}
