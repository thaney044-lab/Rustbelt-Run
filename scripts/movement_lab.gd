extends Node2D

const Player = preload("res://scripts/player.gd")
const MovingPlatform = preload("res://scripts/moving_platform.gd")
var player: CharacterBody2D
var status: Label
var checkpoint_reached := false

func _ready() -> void:
	configure_input()
	platform(Vector2(270, 560), Vector2(540, 80))
	platform(Vector2(700, 560), Vector2(180, 80))
	platform(Vector2(1030, 560), Vector2(220, 80))
	platform(Vector2(1410, 560), Vector2(300, 80))
	platform(Vector2(1750, 560), Vector2(240, 80))
	platform(Vector2(260, 450), Vector2(110, 20))
	platform(Vector2(440, 370), Vector2(110, 20))
	platform(Vector2(1100, 430), Vector2(140, 24))
	platform(Vector2(1450, 450), Vector2(150, 24))
	platform(Vector2(1480, 362), Vector2(150, 24))
	platform(Vector2(855, 470), Vector2(100, 20), true)
	player = Player.new()
	player.position = player.spawn_point
	add_child(player)
	var camera := Camera2D.new()
	camera.position = Vector2(180, -80)
	camera.limit_left = 0
	camera.limit_right = 3000
	camera.limit_top = 0
	camera.limit_bottom = 720
	player.add_child(camera)
	var hud := CanvasLayer.new()
	add_child(hud)
	status = Label.new()
	status.position = Vector2(24, 20)
	status.add_theme_font_size_override("font_size", 21)
	hud.add_child(status)
	status.text = "RUSTBELT RUN / Movement lab\nA/D or arrows: move   Space: jump (hold for height)   R: retry\nController: left stick / D-pad + A. Reach the checkpoint flag."
	label_at("SHORT / FULL JUMPS", Vector2(140, 310))
	label_at("MOVING PLATFORM", Vector2(670, 335))
	label_at("CHECKPOINT", Vector2(980, 470))
	label_at("LOW CEILING", Vector2(1340, 290))
	label_at("REPAIR YARD ->", Vector2(1640, 410))
	var yard := preload("res://scripts/repair_yard.gd").new()
	yard.lab = self
	add_child(yard)
	queue_redraw()

func configure_input() -> void:
	bind_keys("move_left", [KEY_A, KEY_LEFT])
	bind_keys("move_right", [KEY_D, KEY_RIGHT])
	bind_keys("jump", [KEY_SPACE])
	bind_keys("restart", [KEY_R])
	bind_keys("interact", [KEY_E])
	bind_keys("swing", [KEY_J])
	bind_keys("throw_wrench", [KEY_K])
	bind_keys("reset_puzzle", [KEY_T])
	var axis_left := InputEventJoypadMotion.new()
	axis_left.axis = JOY_AXIS_LEFT_X
	axis_left.axis_value = -1.0
	InputMap.action_add_event("move_left", axis_left)
	var axis_right := InputEventJoypadMotion.new()
	axis_right.axis = JOY_AXIS_LEFT_X
	axis_right.axis_value = 1.0
	InputMap.action_add_event("move_right", axis_right)
	for pair in [["interact", JOY_BUTTON_Y], ["swing", JOY_BUTTON_X], ["throw_wrench", JOY_BUTTON_B], ["reset_puzzle", JOY_BUTTON_BACK], ["jump", JOY_BUTTON_A], ["move_left", JOY_BUTTON_DPAD_LEFT], ["move_right", JOY_BUTTON_DPAD_RIGHT]]:
		var event := InputEventJoypadButton.new()
		event.button_index = pair[1]
		InputMap.action_add_event(pair[0], event)

func bind_keys(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		InputMap.action_erase_events(action)
	else:
		InputMap.add_action(action, 0.2)
	for key in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key
		InputMap.action_add_event(action, event)

func platform(center: Vector2, size: Vector2, moving := false) -> void:
	var body: PhysicsBody2D = MovingPlatform.new() if moving else StaticBody2D.new()
	body.position = center
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([Vector2(-size.x, -size.y), Vector2(size.x, -size.y), size, Vector2(-size.x, size.y)])
	visual.scale = Vector2(0.5, 0.5)
	visual.color = Color("dfb85d") if moving else Color("526a65")
	body.add_child(visual)
	add_child(body)

func label_at(text: String, at: Vector2) -> void:
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_color_override("font_color", Color("e6c86a"))
	add_child(label)

func _physics_process(_delta: float) -> void:
	if player.position.x > 980 and player.position.x < 1130 and player.is_on_floor() and not checkpoint_reached:
		checkpoint_reached = true
		player.spawn_point = Vector2(1020, 490)
		status.text += "\nCheckpoint active — falls and R return here."

func _draw() -> void:
	for x in range(50, 3000, 160):
		draw_rect(Rect2(x, 160, 55, 360), Color("172d30"))
	draw_line(Vector2(1000, 520), Vector2(1000, 465), Color("e6c86a"), 4)
	draw_colored_polygon(PackedVector2Array([Vector2(1000, 465), Vector2(1030, 475), Vector2(1000, 485)]), Color("e6c86a"))
