extends Node2D
var lab: Node2D
var active := false
var powered := false
var stage := 0
var finished := false
var time := 0.0
var lift: AnimatableBody2D
const CONTROL := Vector2(5490,490)
const METAL = preload("res://assets/art/painted/weathered_steel.png")
const VENTS := [Vector2(7460,475),Vector2(8230,490),Vector2(11580,460),Vector2(12280,410)]

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
	# A short optional climb rewards confident jumping without blocking the exit.
	lab.platform(Vector2(6110,305),Vector2(100,20))
	lab.platform(Vector2(6290,265),Vector2(90,20))
	lab.platform(Vector2(6450,315),Vector2(100,20))
	lab.platform(Vector2(6340,450),Vector2(120,20))
	lab.platform(Vector2(6600,470),Vector2(100,20),true,1.65)
	lab.platform(Vector2(7030,560),Vector2(460,80))
	lab.platform(Vector2(7460,485),Vector2(100,20))
	lab.platform(Vector2(7700,455),Vector2(100,20),true,1.6,70.0)
	lab.platform(Vector2(7940,560),Vector2(180,80))
	lab.platform(Vector2(8230,500),Vector2(90,20))
	lab.platform(Vector2(8430,450),Vector2(90,20))
	lab.platform(Vector2(8680,530),Vector2(330,80))
	lab.label_at("FOUNDRY SERVICE RUN",Vector2(5350,290))
	lab.label_at("E  /  POWER THE HOIST",Vector2(5410,400))
	lab.label_at("RIDE UP, THEN JUMP RIGHT",Vector2(5780,280))
	lab.label_at("CROSS THE STEAM CHANNEL",Vector2(6400,315))
	lab.label_at("TRANSFER SPAN  /  WAIT FOR STEAM TO CLEAR",Vector2(7070,280))
	lab.label_at("SAFE SERVICE ISLAND",Vector2(7850,360))
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

func vent_phase(index: int) -> float:
	return fposmod(time+index*2.1,4.6)

func vent_live(index: int) -> bool:
	var phase := vent_phase(index)
	return phase >= 2.2 and phase < 3.3

func vent_rect(index: int) -> Rect2:
	return Rect2(VENTS[index]-Vector2(20,110),Vector2(40,112))

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
	if stage == 2 and p.position.x > 7890 and p.position.x < 8010 and p.is_on_floor():
		stage = 3
		p.set_checkpoint(Vector2(7940,490))
		time = 0
	var player_rect := Rect2(p.position-Vector2(13,20),Vector2(26,40))
	for i in VENTS.size():
		if vent_live(i) and vent_rect(i).intersects(player_rect):
			p.respawn()
			break
	if p.position.x > preload("res://scripts/freight_run.gd").END_X and p.is_on_floor():
		finished = true
	if finished:
		lab.status.text = "FOUNDRY SERVICE RUN COMPLETE!\nR: retry from the final checkpoint."
	elif not powered:
		lab.status.text = "FOUNDRY HOIST  /  CHECKPOINT ACTIVE\nPress E beside the control to start the lift."
	elif p.position.x > 7200:
		lab.status.text = "TRANSFER SPAN  /  PRECISION CROSSING\nAmber ! warns before a steam burst. Wait for the vent to clear, then jump."
	else:
		lab.status.text = "FOUNDRY SERVICE RUN\nRide the hoist, cross the upper catwalk, then use the moving gantry."
	queue_redraw()

func _draw() -> void:
	for x in [5780,5920]:
		draw_rect(Rect2(x-8,245,16,365),Color("273d32"))
		draw_texture_rect_region(METAL,Rect2(x-7,245,14,365),Rect2(180,100,42,1095),Color(0.62,0.68,0.50))
		draw_line(Vector2(x-5,600),Vector2(x-5,245),Color("a69965"),2,true)
		for y in range(260,595,28):
			draw_circle(Vector2(x+3,y),1.5,Color("c8af76"))
			draw_line(Vector2(x-6,y),Vector2(x+6,y+20),Color("626d48"),2,true)
	draw_rect(Rect2(5760,238,180,16),Color("314633"))
	draw_texture_rect_region(METAL,Rect2(5760,238,180,16),Rect2(100,180,540,48),Color(0.81,0.75,0.48))
	draw_line(Vector2(5760,238),Vector2(5940,238),Color("c5ad72"),2,true)
	draw_circle(Vector2(5850,245),12,Color("283e30"))
	draw_arc(Vector2(5850,245),9,0,TAU,24,Color("ab9a63"),2,true)
	draw_line(Vector2(5850,245),Vector2(5850,lift.position.y),Color("c9b887"),3)
	draw_rect(Rect2(CONTROL-Vector2(16,18),Vector2(32,45)),Color("354b42"))
	draw_circle(CONTROL,9,Color("a5dbad") if powered else Color("e3b65c"))
	draw_line(CONTROL,CONTROL+Vector2(0,-18),Color("e2d7ae"),3)
	# Heat is below the catwalk; all actual landing rims remain unobstructed.
	for i in 12:
		var x := 5570+i*105.0
		# Furnace mouths sit deep below the jumping line, with a restrained heat shimmer.
		draw_rect(Rect2(x,660,70,95),Color("26352c",0.8))
		draw_rect(Rect2(x+5,670,60,70),Color("a26231",0.55))
		for j in 4:
			draw_line(Vector2(x+9,681+j*14),Vector2(x+61,681+j*14),Color("d5a45c",0.25+sin(time+i+j)*0.05),2,true)
		for j in 5:
			draw_line(Vector2(x+11+j*12,670),Vector2(x+11+j*12,740),Color("324132"),3,true)
	for x in [5380,6870,7890]:
		draw_line(Vector2(x,520),Vector2(x,455),Color("cbbb8d"),4)
		draw_colored_polygon(PackedVector2Array([Vector2(x+2,456),Vector2(x+30,464),Vector2(x+2,478)]),Color("8cb48b"))
	for i in VENTS.size():
		var at: Vector2 = VENTS[i]
		var warning := vent_phase(i) >= 1.4 and vent_phase(i) < 2.2
		draw_rect(Rect2(at-Vector2(23,-3),Vector2(46,12)),Color("27392f"))
		for dx in [-16,-8,0,8,16]:
			draw_line(at+Vector2(dx,4),at+Vector2(dx,12),Color("bfa16a"),2,true)
		var lamp := at+Vector2(-32,-18)
		draw_circle(lamp,8,Color("d77c53") if vent_live(i) else (Color("efbf62") if warning else Color("86b99a")))
		if warning:
			draw_line(lamp+Vector2(0,-5),lamp+Vector2(0,1),Color("263d32"),2,true)
			draw_circle(lamp+Vector2(0,4),1.2,Color("263d32"))
		if vent_live(i):
			for j in 11:
				var rise := fposmod(time*100+j*11,110)
				var center := at+Vector2(sin(time*5+j)*5,-rise)
				draw_circle(center,10+rise*0.10,Color(0.83,0.91,0.84,(1-rise/130)*0.35))
			for j in 5:
				var base := at+Vector2(-12+j*6,0)
				draw_line(base,base+Vector2(sin(time*9+j)*4,-85-j*4),Color("d6e7d8",0.25),3,true)
		elif warning:
			for j in 3:
				draw_circle(at+Vector2(sin(time*6+j)*4,-7-j*5),5,Color("d9d6ac",0.18))
