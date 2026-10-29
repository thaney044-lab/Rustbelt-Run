extends Node2D
var lab: Node2D
var active := false
var powered := false
var stage := 0
var finished := false
var time := 0.0
var lift: AnimatableBody2D
const CONTROL := Vector2(5490,490)

func _ready() -> void:
	lab.platform(Vector2(5420,560),Vector2(260,80))
	lab.platform(Vector2(5660,500),Vector2(110,20))
	lift = AnimatableBody2D.new()
	lift.position = Vector2(5850,500)
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(150,20)
	shape.shape = rectangle
	lift.add_child(shape)
	var visual := preload("res://scripts/platform_art.gd").new()
	visual.size = Vector2(150,20)
	visual.moving = true
	lift.add_child(visual)
	add_child(lift)
	lab.platform(Vector2(6140,390),Vector2(220,20))
	lab.platform(Vector2(6340,450),Vector2(120,20))
	lab.platform(Vector2(6600,470),Vector2(120,20),true)
	lab.platform(Vector2(7030,560),Vector2(460,80))
	lab.platform(Vector2(7480,530),Vector2(250,80))
	lab.label_at("FOUNDRY SERVICE RUN",Vector2(5350,290))
	lab.label_at("E  /  POWER THE HOIST",Vector2(5410,400))
	lab.label_at("RIDE UP, THEN JUMP RIGHT",Vector2(5780,280))
	lab.label_at("CROSS THE STEAM CHANNEL",Vector2(6400,315))
	lab.label_at("FOUNDRY EXIT",Vector2(7350,360))
	lab.player.respawned.connect(reset)

func reset() -> void:
	time = 0
	powered = stage >= 2
	finished = false

func use_control() -> void:
	if lab.player.position.distance_to(CONTROL) < 65:
		powered = true
		time = 0
		lab.effects.burst(CONTROL,Color("b6e5b9"),10)

func _physics_process(delta: float) -> void:
	time += delta
	var p: CharacterBody2D = lab.player
	if not active and p.position.x > 5350 and p.position.x < 5550 and p.is_on_floor():
		active = true
		stage = 1
		p.set_checkpoint(Vector2(5420,490))
	if active and Input.is_action_just_pressed("interact"):
		use_control()
	lift.position = Vector2(5850,435+cos(time*1.3)*65 if powered else 500)
	if not active:
		return
	if p.position.x > 5400 and p.position.y > 650:
		p.respawn()
	if stage == 1 and p.position.x > 6870 and p.position.x < 7200 and p.is_on_floor():
		stage = 2
		p.set_checkpoint(Vector2(6910,490))
	if p.position.x > 7440 and p.is_on_floor():
		finished = true
	if finished:
		lab.status.text = "FOUNDRY SERVICE RUN COMPLETE!\nR: retry from the final checkpoint."
	elif not powered:
		lab.status.text = "FOUNDRY HOIST  /  CHECKPOINT ACTIVE\nPress E beside the control to start the lift."
	else:
		lab.status.text = "FOUNDRY SERVICE RUN\nRide the hoist, cross the upper catwalk, then use the moving gantry."
	queue_redraw()

func _draw() -> void:
	for x in [5780,5920]:
		draw_line(Vector2(x,600),Vector2(x,245),Color("2a4140"),12)
		draw_line(Vector2(x-2,600),Vector2(x-2,245),Color("a17d50"),3)
	draw_line(Vector2(5760,245),Vector2(5940,245),Color("b18b54"),12)
	draw_line(Vector2(5850,245),Vector2(5850,lift.position.y),Color("c9b887"),3)
	draw_rect(Rect2(CONTROL-Vector2(16,18),Vector2(32,45)),Color("354b42"))
	draw_circle(CONTROL,9,Color("a5dbad") if powered else Color("e3b65c"))
	draw_line(CONTROL,CONTROL+Vector2(0,-18),Color("e2d7ae"),3)
	# Heat is below the catwalk; all actual landing rims remain unobstructed.
	draw_rect(Rect2(5550,610,1250,180),Color("493b2c",0.8))
	for i in 16:
		var x := 5570+i*78.0
		draw_line(Vector2(x,620),Vector2(x+30,620+sin(time+i)*8),Color("d69c5e",0.25),2)
	for x in [5380,6870]:
		draw_line(Vector2(x,520),Vector2(x,455),Color("cbbb8d"),4)
		draw_colored_polygon(PackedVector2Array([Vector2(x+2,456),Vector2(x+30,464),Vector2(x+2,478)]),Color("8cb48b"))
