extends Node2D

var lab: Node2D
var patrol_left := 330.0
var patrol_right := 485.0
var direction := 1.0
var alive := true
var age := 0.0
var home := Vector2.ZERO
var art: Texture2D
var sprite_region := Rect2()
var wheel_rotation := 0.0

func _ready() -> void:
	home = position
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

func reset() -> void:
	alive = true
	position = home
	direction = 1.0
	age = 0
	wheel_rotation = 0
	queue_redraw()

func defeat() -> void:
	if not alive:
		return
	alive = false
	age = 0
	lab.effects.robot_breakup(position + Vector2(0, -8), direction)
	queue_redraw()

func contact_player(player: CharacterBody2D) -> void:
	if not alive or not Rect2(position-Vector2(18,17),Vector2(36,37)).intersects(Rect2(player.position-Vector2(13,20),Vector2(26,40))):
		return
	if player.velocity.y > 0 and player.position.y < position.y-19:
		defeat()
		player.velocity.y = -350
		lab.combat.show_notice("STOMP!  /  Patrol bot disabled.")
	else:
		if player.take_damage(position.x):
			lab.combat.show_notice("HIT!  /  J swings the wrench; jump onto the bot's flat top.")

func _physics_process(delta: float) -> void:
	age += delta
	if alive:
		wheel_rotation += direction * 48 * delta / 5.0
		position.x = clampf(position.x+direction*48*delta,patrol_left,patrol_right)
		if position.x >= patrol_right:
			direction = -1
		elif position.x <= patrol_left:
			direction = 1
		contact_player(lab.player)
	queue_redraw()

func is_targeted() -> bool:
	# Match the actual wrench selection, including nearest-target priority.
	return alive and lab.combat.nearest_target() == self

func _draw() -> void:
	if not alive and age >= 1.0:
		return
	var alpha := 1.0 if alive else 1.0 - smoothstep(0.55, 1.0, age)
	var targeted := is_targeted()
	draw_set_transform(Vector2(0, 18), 0, Vector2(1, 0.22))
	draw_circle(Vector2.ZERO, 28, Color(0.02, 0.07, 0.08, 0.3 * alpha))
	draw_set_transform(Vector2.ZERO)
	if alive:
		# Faint steam behind the exhaust; particles stay decorative.
		for i in 3:
			var phase := fposmod(age * 0.9 + i / 3.0, 1.0)
			var at := Vector2(-28 * direction - phase * 7 * direction, -28 - phase * 17)
			draw_circle(at, 1.5 + phase * 3.5, Color(0.69, 0.76, 0.68, (1.0 - phase) * 0.22))
	# Tip around the feet on defeat instead of spinning around the body center.
	var collapse := 0.0 if alive else smoothstep(0.08, 0.35, age)
	var tilt := collapse * 0.28 * direction
	draw_set_transform(Vector2(0, 18), tilt, Vector2(direction * 1.4, 1.4 * (1.0 - collapse * 0.6)))
	var body_rect := Rect2(-25, -34.6, 50, 36.6)
	if art:
		draw_texture_rect_region(art, body_rect, sprite_region, Color(1, 1, 1, alpha))
	else:
		draw_rect(Rect2(-18, -34, 36, 29), Color(0.29, 0.47, 0.45, alpha))
		for x in [-12, 12]:
			draw_circle(Vector2(x, -4), 7, Color(0.13, 0.22, 0.23, alpha))
	# Brass hub spokes animate the painted wheels without moving the contact plane.
	for x in [-12.0, 15.0]:
		var hub := Vector2(x, -4.1)
		draw_circle(hub, 2.5, Color(0.26, 0.22, 0.13, alpha))
		for spoke in 3:
			var offset := Vector2.from_angle(wheel_rotation * direction + spoke * TAU / 3) * 2.1
			draw_line(hub, hub + offset, Color(0.88, 0.65, 0.32, alpha), 0.8, true)
		draw_circle(hub, 0.8, Color(1.0, 0.86, 0.57, alpha))
	var lens := Vector2(20, -18)
	var pulse := 0.5 + 0.5 * sin(age * 5)
	draw_circle(lens, 6, Color(1.0, 0.69, 0.22, (0.06 + pulse * 0.04) * alpha))
	draw_circle(lens, 2, Color(1.0, 0.8, 0.33, alpha))
	draw_circle(lens + Vector2(0, -0.7), 0.8, Color(1.0, 0.96, 0.76, alpha))
	draw_set_transform(Vector2.ZERO)
	if not alive and age < 0.16:
		var flash := 1.0 - age / 0.16
		draw_circle(Vector2(0, -8), 12 + age * 85, Color(1.0, 0.86, 0.52, flash * 0.7))
		draw_arc(Vector2(0, -8), 14 + age * 150, 0, TAU, 32, Color(1.0, 0.94, 0.72, flash), 2, true)
	if targeted:
		# Node2D drawing uses local coordinates, never the bot's world position.
		var radius := 39.0 + sin(age * 4) * 1.0
		for quadrant in 4:
			var angle := PI / 4 + quadrant * PI / 2
			draw_arc(Vector2.ZERO, radius, angle - 0.18, angle + 0.18, 8, Color("ffe0a0", 0.9), 1.5, true)
		draw_colored_polygon(PackedVector2Array([Vector2(-3, -43), Vector2(3, -43), Vector2(0, -39)]), Color("ffe0a0"))
