extends Node2D

var time := 0.0
var scroll := 0.0
var steam_texture: Texture2D

func _ready() -> void:
	# Soft procedural plume texture; generated once, not per frame.
	var gradient := Gradient.new()
	gradient.set_color(0,Color(0.85,0.88,0.80,0.45))
	gradient.set_color(1,Color(0.85,0.88,0.80,0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5,0.5)
	texture.fill_to = Vector2(1,0.5)
	texture.width = 96
	texture.height = 96
	steam_texture = texture

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	if not steam_texture:
		return
	# Clouds drift independently of the mountain painting and the near machinery.
	for i in 6:
		var x := fposmod(i*270.0+time*6-scroll*.025,1700)-220
		var y := 55+i%3*42.0
		for j in 3:
			draw_texture_rect(steam_texture,Rect2(x+j*42,y-j%2*12,155,54),false,Color(1,0.96,0.86,0.55))
	# Steam vents rise in world-relative locations, expanding and dissolving.
	for i in 4:
		var x := i*420.0-fposmod(scroll*.18,420.0)+90
		for j in 5:
			var age := fposmod(time*.20+j*.2+i*.13,1.0)
			var radius := 20+age*55
			var at := Vector2(x+age*35,300-age*155)
			draw_texture_rect(steam_texture,Rect2(at-Vector2.ONE*radius,Vector2.ONE*radius*2),false,Color(0.91,0.96,0.94,sin(age*PI)*0.70))
