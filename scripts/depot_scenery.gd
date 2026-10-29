extends Node2D

var lab: Node2D
var camera: Camera2D
var sky := preload("res://assets/art/depot_sky.svg")

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(lab.player):
		return
	if not camera:
		camera = get_viewport().get_camera_2d()
	if not camera:
		return
	var scroll := camera.get_screen_center_position().x - 576.0
	draw_texture(sky, Vector2(-scroll * 0.12, 0))
	# The distant silhouettes move slowly, keeping the traversable layer distinct.
	for i in range(-1, 12):
		var x := i * 210.0 - scroll * 0.28
		var h := 100.0 + fposmod(float(i*i*71), 110.0)
		draw_rect(Rect2(x, 430-h, 160, h+220), Color("607c76"))
		draw_colored_polygon(PackedVector2Array([Vector2(x-6,430-h),Vector2(x+55,398-h),Vector2(x+166,430-h)]), Color("526f6b"))
		draw_rect(Rect2(x+104, 335-h, 22, 100), Color("56716c"))
		draw_rect(Rect2(x+99, 332-h, 32, 8), Color("729083"))
		for col in 5:
			for row in 3:
				draw_rect(Rect2(x+12+col*28, 445-h+row*30, 12, 19), Color("a8b49a") if (col+row+i)%4==0 else Color("47635f"))
	# Mid-distance railway viaduct and rusty gantries.
	var rail_y := 420.0
	draw_line(Vector2(0,rail_y),Vector2(1200,rail_y),Color("445d59"),8)
	for i in range(-1, 10):
		var x := i*190.0 - fposmod(scroll*.48,190.0)
		draw_line(Vector2(x,rail_y),Vector2(x,648),Color("526b61"),14)
		draw_line(Vector2(x,rail_y+15),Vector2(x+80,520),Color("526b61"),7)
	# Foreground shade remains below the playable ledges.
	draw_rect(Rect2(0,600,1152,100),Color("183b3c",0.55))
