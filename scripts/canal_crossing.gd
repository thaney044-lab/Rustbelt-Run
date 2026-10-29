extends Node2D
var lab: Node2D
var active := false
var time := 0.0
var finished := false

func _ready() -> void:
	var water := ColorRect.new()
	water.position = Vector2(4280,590)
	water.size = Vector2(1150,140)
	water.z_index = -1
	water.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var water_material := ShaderMaterial.new()
	water_material.shader = preload("res://shaders/canal_water.gdshader")
	water_material.set_shader_parameter("panorama",preload("res://assets/art/painted/depot_panorama.png"))
	water.material = water_material
	add_child(water)
	lab.platform(Vector2(4400,560),Vector2(200,80))
	lab.platform(Vector2(4520,470),Vector2(80,20))
	lab.platform(Vector2(4700,470),Vector2(120,20),true)
	lab.platform(Vector2(5100,560),Vector2(460,80))
	lab.platform(Vector2(5150,455),Vector2(110,20))
	lab.label_at("FLOODED SERVICE CANAL",Vector2(4310,310))
	lab.label_at("RIDE THE MAINTENANCE LIFT",Vector2(4540,350))
	lab.label_at("NEXT DISTRICT  /  FOUNDRY",Vector2(5080,340))
	lab.player.respawned.connect(func(): finished = false)

func _physics_process(delta: float) -> void:
	time += delta
	var p: CharacterBody2D = lab.player
	if p.position.x > 4330 and p.position.x < 4500 and p.is_on_floor() and not active:
		active = true
		p.spawn_point = Vector2(4370,490)
	if not active:
		return
	if p.position.x > 4280 and p.position.y > 620:
		p.respawn()
	if p.position.x > 5180 and p.is_on_floor():
		finished = true
	lab.status.text = "FIRST SHIFT  /  FOUNDRY GATE REACHED!\nR: replay canal crossing." if finished else "SERVICE CANAL  /  CHECKPOINT ACTIVE\nJump to the moving maintenance lift, then cross to the foundry gate."
	queue_redraw()

func _draw() -> void:
	# Low-contrast water below the landing surfaces, with ripples and reflections.

	for i in 32:
		var x := 4300+i*34.0
		var y := 600+fposmod(i*19.0,100)
		draw_line(Vector2(x,y),Vector2(x+18+sin(time+i)*7,y),Color("7caaa0",0.35),2)
	for x in [4320,4900,5260]:
		draw_line(Vector2(x,590),Vector2(x,260),Color("324c4c"),12)
		draw_line(Vector2(x,260),Vector2(x+60,260),Color("324c4c"),8)
		draw_circle(Vector2(x+60,275),14,Color("1c3338"))
		draw_circle(Vector2(x+60,275),10,Color("bc914f"))
		draw_circle(Vector2(x+60,275),7,Color("e8c884"))
		draw_circle(Vector2(x+58,273),3,Color("fff0be"))
		draw_line(Vector2(x+47,260),Vector2(x+73,260),Color("36473e"),5)
		for r in [20,32,44]:
			draw_circle(Vector2(x+60,275),r,Color(0.95,0.8,0.47,0.025))
	draw_line(Vector2(4340,520),Vector2(4340,455),Color("d4bc88"),4)
	draw_colored_polygon(PackedVector2Array([Vector2(4342,456),Vector2(4375,465),Vector2(4342,478)]),Color("88bd9b"))
	# Riveted foundry arch and warm furnace light beyond the exit.
	for x in [5180,5290]:
		draw_rect(Rect2(x,370,15,150),Color("374a48"))
		for y in range(380,520,25):
			draw_circle(Vector2(x+7,y),2,Color("b29c72"))
	draw_rect(Rect2(5170,360,145,18),Color("9b764b"))
	draw_rect(Rect2(5200,395,65,125),Color("6e5940"))
	draw_rect(Rect2(5210,405,45,115),Color("be8750",0.5))
