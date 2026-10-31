extends Node2D
## First Shift's signage and machinery live in world space, below the actors.
const Art = preload("res://scripts/rendered_art.gd")
var lab: Node2D
var shuttles: Array[AnimatableBody2D] = []
const STEEL := Color("28413e")
const BRASS := Color("bd9d64")
const SIGNS := [
	[Vector2(60,363),520,"01  /  CINDER YARD","REPAIR WORKS  >"],
	[Vector2(1640,400),520,"02  /  REPAIR WORKS","RESTORE THE CRANE"],
	[Vector2(2920,345),520,"03  /  PISTON HALL","WATCH THE CRUSH LANES"],
	[Vector2(4310,365),520,"04  /  SERVICE CANAL","FERRY CROSSING  >"],
	[Vector2(5310,340),520,"05  /  THE FOUNDRY","HOIST CONTROL  >"],
	[Vector2(8550,320),490,"06  /  FREIGHT AQUEDUCT","UPPER CATWALKS  >"],
	[Vector2(11160,350),520,"07  /  THE LAST MILE","PATCH'S WORKSHOP  >"]
]
const REST_STOPS := [Vector2(1020,520),Vector2(5420,520),Vector2(6910,520),Vector2(7940,520),Vector2(8680,490),Vector2(10080,460),Vector2(11300,520),Vector2(12040,460)]

func _ready() -> void:
	z_index = -1
	for child in lab.get_children():
		if child is AnimatableBody2D and child.get_script() == preload("res://scripts/moving_platform.gd"):
			shuttles.append(child)
	for spec in SIGNS:
		var title := Label.new()
		title.text = spec[2]
		title.position = spec[0]+Vector2(12,10)
		title.add_theme_font_size_override("font_size",13)
		title.add_theme_color_override("font_color",Color("f1ddb2"))
		add_child(title)
		var caption := Label.new()
		caption.text = spec[3]
		caption.position = spec[0]+Vector2(12,34)
		caption.add_theme_font_size_override("font_size",10)
		caption.add_theme_color_override("font_color",Color("b8c8b3"))
		add_child(caption)

func _process(_delta: float) -> void:
	queue_redraw()

func near(at: Vector2) -> bool:
	return absf(at.x-lab.player.position.x) < 1200

func _draw() -> void:
	for spec in SIGNS:
		var at: Vector2 = spec[0]
		if not near(at): continue
		for x in [18,202]:
			draw_line(at+Vector2(x,55),Vector2(at.x+x,spec[1]),STEEL,5,true)
			draw_line(at+Vector2(x-1,55),Vector2(at.x+x-1,spec[1]),Color("798674"),1,true)
		var board := Rect2(at,Vector2(220,61))
		draw_rect(Rect2(at+Vector2(3,4),board.size),Color("102a28",0.5))
		draw_rect(board,Color("203b38"))
		draw_rect(board,BRASS,false,1.5)
		draw_line(at+Vector2(12,30),at+Vector2(208,30),Color("586e5b"),1,true)
		for corner in [Vector2(5,5),Vector2(215,5),Vector2(5,56),Vector2(215,56)]:
			draw_circle(at+corner,1.5,BRASS)
	for shuttle in shuttles:
		if not near(shuttle.origin): continue
		var track: Vector2 = shuttle.origin+Vector2(0,36)
		var span: float = shuttle.travel+16
		Art.strip(self,"gantry",track.x-span,track.y,span*2,Color(0.68,0.77,0.74))
		var carriage := shuttle.position+Vector2(0,32)
		draw_line(carriage,shuttle.position+Vector2(0,10),STEEL,8,true)
		for dx in [-9,9]:
			Art.sprite(self,"wheel",carriage+Vector2(dx,0),0.45)
	for at in REST_STOPS:
		if not near(at): continue
		var secured: bool = lab.player.spawn_point.x >= at.x-30
		Art.sprite(self,"checkpoint",at+Vector2(72,0),0.65,Color.WHITE if secured else Color(0.69,0.77,0.70))
		if secured:
			draw_circle(at+Vector2(72,-40),13,Color("c5e6ae",0.07))
	# Mechanical silhouettes and material detail belong to real maintenance banks.
	for at in [Vector2(60,520),Vector2(1755,520),Vector2(2720,520),Vector2(5075,520),Vector2(7040,520),Vector2(10080,460),Vector2(12800,490)]:
		if near(at): Art.sprite(self,"pump",at,0.67,Color(0.85,0.94,0.89))
