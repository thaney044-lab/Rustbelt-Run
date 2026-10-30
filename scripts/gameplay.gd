extends Node2D

var authored_layout := true
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
var wrench_trail: Array[Vector2] = []
var enemy_art: Texture2D = preload("res://assets/art/painted/patrol_bot.png")
var enemy_region := Rect2(162,203,1087,795)

func _ready() -> void:
	if authored_layout:
		for spec in [[355.0,330.0,450.0],[2690.0,2620.0,2740.0],[5030.0,4970.0,5090.0],[7040.0,6900.0,7180.0]]:
			spawn_patrol(Vector2(spec[0],499), spec[1], spec[2])
		for point in [Vector2(140,480),Vector2(250,415),Vector2(440,335),Vector2(525,415),Vector2(575,415),Vector2(660,485),Vector2(770,475),Vector2(855,430),Vector2(960,480),Vector2(1100,395),Vector2(1290,485),Vector2(1450,400),Vector2(1650,485),Vector2(1770,485),Vector2(1990,485),Vector2(2110,450),Vector2(2375,470),Vector2(2580,485),Vector2(2810,435),Vector2(3000,485),Vector2(3290,485),Vector2(3530,485),Vector2(3780,485),Vector2(3970,400),Vector2(4410,485),Vector2(4520,430),Vector2(4700,430),Vector2(4950,485),Vector2(5150,415),Vector2(5500,480),Vector2(5660,450),Vector2(5850,400),Vector2(6140,340),Vector2(6340,410),Vector2(6600,430),Vector2(6940,480),Vector2(7190,460),Vector2(7360,415),Vector2(7490,440),Vector2(7700,410),Vector2(7890,480),Vector2(8000,480),Vector2(8160,440),Vector2(8400,400),Vector2(8560,440)]:
			scrap_positions.append(point)
			collected.append(false)
		lab.label_at("PATROL  /  J swing · K throw · jump to stomp",Vector2(240,570))
	lab.player.respawned.connect(reset_enemies)

func spawn_patrol(at: Vector2, left: float, right: float) -> void:
	var enemy := preload("res://scripts/patrol_bot.gd").new()
	enemy.lab = lab
	enemy.position = at
	enemy.patrol_left = left
	enemy.patrol_right = right
	enemy.art = enemy_art
	enemy.sprite_region = enemy_region
	enemies.append(enemy)
	add_child(enemy)

func show_notice(message: String) -> void:
	notice = message
	notice_time = 2.5

func reset_enemies() -> void:
	for enemy in enemies:
		enemy.reset()
	flight_active = false
	wrench_trail.clear()
	attack_cooldown = 0
	wrench_target = null
	notice_time = 0

func swing() -> void:
	if flight_active or (is_instance_valid(yard) and yard.wrench_out) or attack_cooldown > 0:
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
	if flight_active or (is_instance_valid(yard) and yard.wrench_out):
		return false
	var target := nearest_target()
	if not target and is_instance_valid(yard) and yard.entered:
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
			lab.effects.celebrate(scrap_positions[i], Color("efd081"), "+1 SCRAP")

func _physics_process(delta: float) -> void:
	time += delta
	attack_cooldown = maxf(0,attack_cooldown-delta)
	notice_time = maxf(0,notice_time-delta)
	if Input.is_action_just_pressed("swing"):
		swing()
	collect_scrap()
	if not flight_active:
		wrench_trail.clear()
	if flight_active:
		wrench_trail.append(wrench_position)
		if wrench_trail.size() > 7:
			wrench_trail.pop_front()
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
	if attack_cooldown > 0:
		var progress := 1.0 - attack_cooldown / 0.25
		var center: Vector2 = lab.player.position + Vector2(0, -4)
		var start := -1.2 + progress * 1.5
		if lab.player.facing < 0:
			start = PI - start - 0.65
		draw_arc(center, 46, start, start + 0.65, 16, Color(1.0, 0.87, 0.57, (1.0 - progress) * 0.8), 3, true)
	for i in range(1, wrench_trail.size()):
		draw_line(wrench_trail[i - 1], wrench_trail[i], Color(0.85, 0.92, 0.79, float(i) / wrench_trail.size() * 0.45), 2, true)
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
