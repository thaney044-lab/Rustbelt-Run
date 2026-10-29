shader_type canvas_item;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec2 uv = UV;
	// Small ripples only in the distant water at the bottom of the painting.
	float water = smoothstep(0.72,0.90,uv.y);
	uv.x += sin(uv.y*190.0+TIME*.9)*0.0018*water;
	vec4 painted = texture(TEXTURE,uv);
	COLOR = painted*tint;
}
