extends CharacterBody2D

signal respawned
var facing := 1.0

const SPEED := 290.0
const ACCELERATION := 1900.0
const GRAVITY := 1450.0
const JUMP_SPEED := -535.0
const COYOTE_TIME := 0.10
const BUFFER_TIME := 0.12
var coyote := 0.0
var jump_buffer := 0.0
var spawn_point := Vector2(100, 490)
var controls_enabled := true
var animation_time := 0.0

func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(26, 40)
	shape.shape = rectangle
	add_child(shape)
	floor_snap_length = 8.0
	queue_redraw()

func _draw() -> void:
	var running := absf(velocity.x) > 20 and is_on_floor()
	var stride := sin(animation_time * 18) if running else 0.0
	var bob := absf(stride) * 1.5 if running else sin(animation_time * 3) * 0.6
	draw_set_transform(Vector2(0, bob), 0, Vector2(facing, 1))
	# Big striped tail, dark limbs and cream ear/cheek markings identify the panda.
	var tail := PackedVector2Array([Vector2(-8,8),Vector2(-22,2+stride),Vector2(-36,-3+stride*2),Vector2(-44,2+stride*2),Vector2(-41,12+stride*2),Vector2(-27,19+stride),Vector2(-10,18)])
	draw_colored_polygon(tail, Color("302e2d"))
	draw_polyline(tail, Color("302e2d"), 3, true)
	draw_line(Vector2(-13,12),Vector2(-34,6+stride*2),Color("bd603a"),13,true)
	for i in 3:
		var t := Vector2(-18-i*7,10-i*1.6+stride)
		draw_line(t+Vector2(-1,-5),t+Vector2(-4,5),Color("edac61"),4,true)
	# Boots alternate in the run cycle, with tucked feet during the jump.
	var tuck := -3.0 if not is_on_floor() else 0.0
	for i in [-1,1]:
		var foot := Vector2(i*7, 16+tuck+stride*i*3)
		draw_line(Vector2(i*6,8),foot,Color("343738"),8,true)
		draw_style_box(art_box(Color("293335")),Rect2(foot-Vector2(4,0),Vector2(12,6)))
	draw_style_box(art_box(Color("bb633a")),Rect2(-13,-10,26,26))
	draw_rect(Rect2(-10,0,20,13),Color("3f696b"))
	draw_line(Vector2(-7,-6),Vector2(-7,10),Color("6d9491"),3)
	draw_line(Vector2(7,-6),Vector2(7,10),Color("6d9491"),3)
	draw_rect(Rect2(-13,9,26,4),Color("e3b65b"))
	draw_rect(Rect2(3,8,5,6),Color("704a33"))
	# Rounded head and pointed ears with ivory interiors.
	for x in [-10,10]:
		draw_colored_polygon(PackedVector2Array([Vector2(x-6,-22),Vector2(x-3,-37),Vector2(x+7,-25)]),Color("303033"))
		draw_colored_polygon(PackedVector2Array([Vector2(x-3,-24),Vector2(x-2,-33),Vector2(x+4,-25)]),Color("f2ddaf"))
	draw_circle(Vector2(0,-20),16,Color("302e2d"))
	draw_circle(Vector2(0,-20),14,Color("ce7142"))
	for x in [-9,9]:
		draw_circle(Vector2(x,-17),6,Color("f3dfb4"))
		draw_line(Vector2(x,-23),Vector2(x*0.55,-22),Color("f4deb0"),3,true)
		draw_circle(Vector2(x*0.55,-19),2,Color("273337"))
	draw_circle(Vector2(1,-14),4,Color("f5d7a7"))
	draw_circle(Vector2(2,-16),2,Color("293638"))
	# Brass workshop goggles sit above the eyes, leaving expressions visible.
	draw_line(Vector2(-14,-28),Vector2(14,-28),Color("684936"),4)
	for x in [-6,6]:
		draw_circle(Vector2(x,-29),5,Color("e0ad55"))
		draw_circle(Vector2(x,-29),3,Color("537e80"))
		draw_line(Vector2(x-1,-31),Vector2(x+1,-29),Color("a1d8cc"),1,true)
	var hand := Vector2(15,2+stride*2)
	draw_line(Vector2(10,-3),hand,Color("7b3f2e"),6,true)
	draw_circle(hand,4,Color("ddc698"))
	draw_line(hand+Vector2(0,3),hand+Vector2(8,-8),Color("9aada8"),3,true)
	draw_arc(hand+Vector2(10,-10),4,0.3,4.7,10,Color("c5d3c5"),3,true)
	draw_set_transform(Vector2.ZERO)

func art_box(fill: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color("2c3232")
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	return style

func _physics_process(delta: float) -> void:
	animation_time += delta
	queue_redraw()
	if not controls_enabled:
		return
	var axis := Input.get_axis("move_left", "move_right")
	if absf(axis) > 0.1:
		facing = signf(axis)
	velocity.x = move_toward(velocity.x, axis * SPEED, ACCELERATION * delta)
	coyote = COYOTE_TIME if is_on_floor() else maxf(0.0, coyote - delta)
	jump_buffer = BUFFER_TIME if Input.is_action_just_pressed("jump") else maxf(0.0, jump_buffer - delta)
	if jump_buffer > 0.0 and coyote > 0.0:
		velocity.y = JUMP_SPEED
		jump_buffer = 0.0
		coyote = 0.0
	if Input.is_action_just_released("jump") and velocity.y < -180.0:
		velocity.y = -180.0
	velocity.y += GRAVITY * delta
	move_and_slide()
	if position.y > 850.0 or Input.is_action_just_pressed("restart"):
		respawn()

func respawn() -> void:
	position = spawn_point
	velocity = Vector2.ZERO
	coyote = 0.0
	jump_buffer = 0.0
	reset_physics_interpolation()
	respawned.emit()
