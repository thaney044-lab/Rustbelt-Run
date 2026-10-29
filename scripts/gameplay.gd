extends Node2D

var lab: Node2D
var yard: Node2D
var enemies: Array[Node2D] = []
var scrap_positions: Array[Vector2] = []
var collected: Array[bool] = []
var scrap_count := 0
var flight_active := false
var returning := false
var wrench_position := Vector2.ZERO
var wrench_destination := Vector2.ZERO
var wrench_target: Node2D
var notice := ""
var notice_time := 0.0
var time := 0.0
var attack_cooldown := 0.0
var enemy_art: Texture2D = preload("res://assets/art/painted/patrol_bot.png")
var enemy_region := Rect2(162,203,1087,795)

func _ready() -> void:
	for spec in [[355.0,330.0,485.0],[2690.0,2620.0,2740.0],[5030.0,4970.0,5090.0],[7040.0,6900.0,7180.0]]:
		var enemy := preload("res://scripts/patrol_bot.gd").new()
		enemy.lab = lab
		enemy.position = Vector2(spec[0],499)
		enemy.patrol_left = spec[1]
		enemy.patrol_right = spec[2]
		enemy.art = enemy_art
		enemy.sprite_region = enemy_region
		enemies.append(enemy)
		add_child(enemy)
	for point in [Vector2(140,480),Vector2(250,415),Vector2(440,335),Vector2(525,465),Vector2(575,450),Vector2(660,485),Vector2(770,475),Vector2(855,430),Vector2(960,480),Vector2(1100,395),Vector2(1290,485),Vector2(1450,400),Vector2(1650,485),Vector2(1770,485),Vector2(1990,485),Vector2(2110,450),Vector2(2375,470),Vector2(2580,485),Vector2(2810,435),Vector2(3000,485),Vector2(3290,485),Vector2(3530,485),Vector2(3780,485),Vector2(3970,400),Vector2(4410,485),Vector2(4520,430),Vector2(4700,430),Vector2(4950,485),Vector2(5150,415),Vector2(5500,480),Vector2(5660,450),Vector2(5850,400),Vector2(6140,340),Vector2(6340,410),Vector2(6600,430),Vector2(6940,480),Vector2(7190,460),Vector2(7410,440)]:
		scrap_positions.append(point)
		collected.append(false)
	lab.label_at("PATROL BOT  /  J swing, K throw, or stomp",Vector2(305,275))
	lab.player.respawned.connect(reset_enemies)

func show_notice(message: String) -> void:
	notice = message
	notice_time = 2.5

func reset_enemies() -> void:
	for enemy in enemies:
		enemy.reset()
	flight_active = false
	attack_cooldown = 0
	wrench_target = null
	notice_time = 0

func swing() -> void:
	if flight_active or yard.wrench_out or attack_cooldown > 0:
		return
	attack_cooldown = 0.25
	for enemy in enemies:
		var difference: Vector2 = enemy.position-lab.player.position
		if enemy.alive and difference.length() <= 80 and difference.x*lab.player.facing >= -10:
			enemy.defeat()
			show_notice("WRENCH HIT!  /  Patrol bot disabled.")

func nearest_target() -> Node2D:
	var result: Node2D
	var distance := 250.0
	for enemy in enemies:
		var diff: Vector2 = enemy.position-lab.player.position
		if enemy.alive and diff.x*lab.player.facing >= 0 and diff.length() < distance:
			distance = diff.length()
			result = enemy
	return result

func begin_throw() -> bool:
	if flight_active or yard.wrench_out:
		return false
	var target := nearest_target()
	if not target and yard.entered:
		return false # The existing puzzle wrench handles switches and crane machinery.
	flight_active = true
	returning = false
	wrench_position = lab.player.position
	wrench_target = target
	wrench_destination = target.position if target else lab.player.position+Vector2(lab.player.facing*230,0)
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_wrench") and not event.is_echo():
		begin_throw()

func collect_scrap() -> void:
	for i in scrap_positions.size():
		if not collected[i] and lab.player.position.distance_to(scrap_positions[i]) < 24:
			collected[i] = true
			scrap_count += 1
			lab.effects.burst(scrap_positions[i],Color("efd081"),5)

func _physics_process(delta: float) -> void:
	time += delta
	attack_cooldown = maxf(0,attack_cooldown-delta)
	notice_time = maxf(0,notice_time-delta)
	if Input.is_action_just_pressed("swing"):
		swing()
	collect_scrap()
	if flight_active:
		var destination: Vector2 = lab.player.position if returning else (wrench_target.position if is_instance_valid(wrench_target) and wrench_target.alive else wrench_destination)
		wrench_position = wrench_position.move_toward(destination,680*delta)
		if wrench_position.distance_to(destination) < 12:
			if returning:
				flight_active = false
			else:
				if is_instance_valid(wrench_target) and wrench_target.alive:
					wrench_target.defeat()
					show_notice("RETURNING WRENCH  /  Patrol bot disabled.")
				returning = true
	if notice_time > 0:
		lab.status.text = notice+"\nHealth and collected scrap are shown in the upper right."
	queue_redraw()

func _draw() -> void:
	for i in scrap_positions.size():
		if collected[i]:
			continue
		var at := scrap_positions[i]+Vector2(0,sin(time*2+i)*2)
		draw_circle(at,8,Color("dbb45e",0.10))
		var points := PackedVector2Array()
		for j in 6:
			points.append(at+Vector2.from_angle(j*TAU/6+time*.35)*5)
		draw_colored_polygon(points,Color("dfb65c"))
		draw_circle(at,2.3,Color("684c2e"))
		draw_circle(at+Vector2(-1,-2),1,Color("fff0b3"))
	if flight_active:
		draw_set_transform(wrench_position,time*16)
		draw_line(Vector2(-10,0),Vector2(8,0),Color("c8d6cf"),4,true)
		draw_arc(Vector2(10,0),5,-2.3,2.3,12,Color("e2e9d9"),3,true)
		draw_set_transform(Vector2.ZERO)
