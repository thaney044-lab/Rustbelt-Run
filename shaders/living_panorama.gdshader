shader_type canvas_item;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec2 uv = UV;
	// Small ripples only in the distant water at the bottom of the painting.
	float water = smoothstep(0.72,0.90,uv.y);
	uv.x += sin(uv.y*190.0+TIME*.9)*0.0018*water;
	vec4 painted = texture(TEXTURE,uv);
	// Warm sunlit stone and cooler distant shadows, in the existing texture pass.
	vec3 color = painted.rgb * tint.rgb;
	float light = dot(color, vec3(0.2126,0.7152,0.0722));
	color *= mix(vec3(0.91,1.015,1.045),vec3(1.09,1.035,0.94),smoothstep(0.18,0.72,light));
	color = mix(vec3(dot(color,vec3(0.2126,0.7152,0.0722))),color,1.045);
	COLOR = vec4(clamp(color,0.0,1.0),painted.a*tint.a);
}
