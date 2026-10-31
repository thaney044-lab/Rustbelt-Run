shader_type canvas_item;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec2 uv = UV;
	float water = smoothstep(0.72,0.90,uv.y);
	uv.x += sin(uv.y*190.0+TIME*.9)*0.0018*water;
	// The painting is one depth plane behind the sharply rendered foreground.
	vec2 radius = TEXTURE_PIXEL_SIZE * 1.65;
	vec4 painted = texture(TEXTURE,uv) * .4;
	painted += texture(TEXTURE,uv+vec2(radius.x,0.0)) * .15;
	painted += texture(TEXTURE,uv-vec2(radius.x,0.0)) * .15;
	painted += texture(TEXTURE,uv+vec2(0.0,radius.y)) * .15;
	painted += texture(TEXTURE,uv-vec2(0.0,radius.y)) * .15;
	vec3 color = painted.rgb * tint.rgb;
	float light = dot(color, vec3(0.2126,0.7152,0.0722));
	color *= mix(vec3(0.86,1.035,1.10),vec3(1.09,1.035,0.89),smoothstep(0.18,0.72,light));
	color = mix(vec3(dot(color,vec3(0.2126,0.7152,0.0722))),color,0.83);
	color = (color-0.38)*0.9+0.38;
	float haze = 0.06+smoothstep(0.38,0.95,uv.y)*0.12;
	color = mix(color,vec3(0.18,0.30,0.32),haze);
	COLOR = vec4(clamp(color,0.0,1.0),painted.a*tint.a);
}
