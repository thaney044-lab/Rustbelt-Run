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

func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(26, 40)
	shape.shape = rectangle
	add_child(shape)
	floor_snap_length = 8.0
	queue_redraw()

func _draw() -> void:
	# Original placeholder silhouette; replace after the movement playtest.
	draw_rect(Rect2(-13, -20, 26, 40), Color("cd7045"))
	draw_rect(Rect2(-11, -22, 22, 8), Color("e6c86a"))
	draw_rect(Rect2(-10, -9, 20, 7), Color("303b40"))
	draw_circle(Vector2(18, 10), 9, Color("a94e35"))

func _physics_process(delta: float) -> void:
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
