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
	# Near flywheels turn on supporting girders at a faster parallax depth.
	for i in range(-1,4):
		var x := i*540.0-fposmod(scroll*.5,540.0)+240
		var center := Vector2(x,560)
		draw_line(center,center+Vector2(0,140),Color("1f3839",0.75),9)
		draw_arc(center,35,0,TAU,40,Color("243f3e",0.8),6,true)
		draw_arc(center,31,0,TAU,40,Color("728577",0.45),2,true)
		for spoke in 6:
			var angle := time*.42+spoke*TAU/6
			draw_line(center,center+Vector2.from_angle(angle)*31,Color("425e53",0.8),4,true)
		draw_circle(center,7,Color("b2925c",0.6))
