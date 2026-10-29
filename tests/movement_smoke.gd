extends SceneTree

var failures := 0
var lab: Node2D
var player: CharacterBody2D

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1

func jump_height(hold_frames: int) -> float:
	player.spawn_point = Vector2(100, 490)
	player.respawn()
	await frames(20)
	var start_y: float = player.position.y
	var minimum_y := start_y
	Input.action_press("jump")
	for i in 55:
		if i == hold_frames:
			Input.action_release("jump")
		await frames(1)
		minimum_y = minf(minimum_y, player.position.y)
	Input.action_release("jump")
	return start_y - minimum_y

func run() -> void:
	lab = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(lab)
	player = lab.player
	await frames(30)
	check(player.is_on_floor(), "player settles on solid ground")
	var short_jump := await jump_height(3)
	var full_jump := await jump_height(40)
	check(short_jump > 20 and full_jump > short_jump + 30, "held jump rises higher than short hop (%0.1f / %0.1f)" % [short_jump, full_jump])
	player.position = Vector2(1020, 485)
	player.velocity = Vector2.ZERO
	await frames(30)
	check(lab.checkpoint_reached and player.spawn_point.x == 1020, "landing activates checkpoint")
	player.position = Vector2(1200, 900)
	await frames(3)
	check(absf(player.position.x - 1020) < 1 and player.position.y < 530, "fall restores safe checkpoint")
	var moving: AnimatableBody2D
	for child in lab.get_children():
		if child is AnimatableBody2D:
			moving = child
	player.position = moving.position + Vector2(0, -31)
	player.velocity = Vector2.ZERO
	await frames(10)
	var relative_start: float = player.position.x - moving.position.x
	await frames(35)
	check(player.is_on_floor() and absf(player.position.x - moving.position.x - relative_start) < 5, "moving platform carries grounded player")
	print("Movement smoke test failures: ", failures)
	quit(1 if failures else 0)
