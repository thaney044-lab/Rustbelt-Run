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
var health := 3
var invulnerability := 0.0
var hurt_lock := 0.0


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(26, 40)
	shape.shape = rectangle
	add_child(shape)
	floor_snap_length = 8.0
	var visual := preload("res://scripts/fox_visual.gd").new()
	add_child(visual)
	queue_redraw()

func _draw() -> void:
	if is_on_floor():
		draw_set_transform(Vector2(-2,20),0,Vector2(1,0.22))
		draw_circle(Vector2.ZERO,17,Color(0.03,0.08,0.08,0.25))
		draw_set_transform(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	animation_time += delta
	invulnerability = maxf(0,invulnerability-delta)
	hurt_lock = maxf(0,hurt_lock-delta)
	queue_redraw()
	if Input.is_action_just_pressed("restart"):
		respawn()
		return
	if not controls_enabled:
		return
	var axis := Input.get_axis("move_left", "move_right")
	if absf(axis) > 0.1:
		facing = signf(axis)
	if hurt_lock <= 0:
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
	var was_grounded := is_on_floor()
	move_and_slide()
	if is_on_floor() and not was_grounded:
		get_parent().effects.burst(position+Vector2(0,20),Color("c7bb93",0.6),5)
	if position.y > 850.0:
		respawn()

func set_checkpoint(at: Vector2) -> void:
	spawn_point = at
	health = 3

func take_damage(source_x: float) -> bool:
	if invulnerability > 0:
		return false
	health -= 1
	if health <= 0:
		respawn()
	else:
		invulnerability = 1.1
		hurt_lock = 0.20
		velocity = Vector2(-190 if source_x > position.x else 190,-240)
		get_parent().effects.burst(position,Color("e59b73"),8)
	return true

func respawn() -> void:
	health = 3
	invulnerability = 0.5
	hurt_lock = 0
	position = spawn_point
	velocity = Vector2.ZERO
	coyote = 0.0
	jump_buffer = 0.0
	reset_physics_interpolation()
	respawned.emit()
