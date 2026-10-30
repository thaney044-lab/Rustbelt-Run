extends Node2D
var lab: Node2D
var mission_id := 1
var time := 0.0
const PAINTING = preload("res://assets/art/painted/foundry_panorama.png")
const DEPOT = preload("res://assets/art/painted/depot_panorama.png")

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(lab.player): return
	var camera := get_viewport().get_camera_2d()
	if not camera: return
	var scroll := camera.get_screen_center_position().x
	var cool := mission_id == 1
	draw_texture_rect(DEPOT if cool else PAINTING,Rect2(-clampf(scroll*0.04,0,350),-20,1600,710),false,Color(0.63,0.83,0.83) if cool else Color(0.95,0.72,0.57))
	for i in 12:
		draw_rect(Rect2(0,350+i*27,1152,27),Color(0.04,0.14,0.17,i*0.012) if cool else Color(0.19,0.07,0.04,i*0.014))
	if cool:
		draw_rect(Rect2(0,590,1152,150),Color("284b55",0.75))
		for row in 8:
			for i in 6:
				var x := fposmod(i*211+row*53-scroll*0.3+time*7,1250)-60
				draw_line(Vector2(x,600+row*16),Vector2(x+50+sin(time+row)*12,600+row*16),Color("a0bfc0",0.14),1,true)
	else:
		for i in 22:
			var at := Vector2(fposmod(i*173.0-time*9-scroll*0.1,1200),fposmod(i*67.0-time*(6+i%3),750))
			draw_circle(at,1.0,Color("edb77b",0.24))
