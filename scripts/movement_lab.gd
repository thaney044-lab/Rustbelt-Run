extends Node2D

const Player = preload("res://scripts/player.gd")
const MovingPlatform = preload("res://scripts/moving_platform.gd")
var player: CharacterBody2D
var status: Label
var checkpoint_reached := false
var effects: Node2D
var combat: Node2D

func _ready() -> void:
	effects = preload("res://scripts/visual_effects.gd").new()
	add_child(effects)
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
	camera.zoom = Vector2(1.12,1.12)
	camera.limit_left = 0
	camera.limit_right = 7660
	camera.limit_top = 0
	camera.limit_bottom = 720
	player.add_child(camera)
	var hud := CanvasLayer.new()
	add_child(hud)
	status = Label.new()
	status.position = Vector2(24, 22)
	status.add_theme_font_size_override("font_size", 17)
	var backing := StyleBoxFlat.new()
	backing.bg_color = Color("142b30", 0.88)
	backing.border_color = Color("c99c52")
	backing.border_width_left = 2
	backing.border_width_bottom = 1
	backing.shadow_color = Color(0,0,0,0.22)
	backing.shadow_size = 4
	backing.content_margin_left = 14
	backing.content_margin_right = 16
	backing.content_margin_top = 9
	backing.content_margin_bottom = 9
	backing.set_corner_radius_all(3)
	status.add_theme_stylebox_override("normal", backing)
	hud.add_child(status)
	var fullscreen := Button.new()
	fullscreen.text = "FULLSCREEN"
	fullscreen.focus_mode = Control.FOCUS_NONE
	fullscreen.position = Vector2(1000,22)
	fullscreen.add_theme_font_size_override("font_size",13)
	var button_style := backing.duplicate()
	button_style.content_margin_left = 12
	button_style.content_margin_right = 12
	fullscreen.add_theme_stylebox_override("normal",button_style)
	fullscreen.add_theme_stylebox_override("hover",button_style)
	fullscreen.add_theme_color_override("font_color",Color("efd6a1"))
	fullscreen.pressed.connect(func():
		var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)
	)
	hud.add_child(fullscreen)
	status.text = "RUSTBELT RUN   /   OVERGROWN RAIL DEPOT\nA/D or arrows: run    Space: jump    R: retry  |  Reach the workshop flag."
	label_at("SHORT / FULL JUMPS", Vector2(140, 310))
	label_at("MOVING PLATFORM", Vector2(670, 335))
	label_at("CHECKPOINT", Vector2(980, 470))
	label_at("LOW CEILING", Vector2(1340, 290))
	label_at("REPAIR YARD ->", Vector2(1640, 410))
	var yard := preload("res://scripts/repair_yard.gd").new()
	yard.lab = self
	add_child(yard)
	var passage := preload("res://scripts/piston_passage.gd").new()
	passage.lab = self
	add_child(passage)
	var canal := preload("res://scripts/canal_crossing.gd").new()
	canal.lab = self
	add_child(canal)
	combat = preload("res://scripts/gameplay.gd").new()
	combat.lab = self
	combat.yard = yard
	add_child(combat)
	var vitals := preload("res://scripts/vitals_hud.gd").new()
	vitals.lab = self
	hud.add_child(vitals)
	var foundry := preload("res://scripts/foundry_run.gd").new()
	foundry.lab = self
	add_child(foundry)
	var scenery_layer := CanvasLayer.new()
	scenery_layer.layer = -10
	var scenery := preload("res://scripts/depot_scenery.gd").new()
	scenery.lab = self
	scenery_layer.add_child(scenery)
	add_child(scenery_layer)
	var atmosphere_layer := CanvasLayer.new()
	atmosphere_layer.layer = 3
	add_child(atmosphere_layer)
	var vignette := ColorRect.new()
	vignette.size = Vector2(1152,648)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var atmosphere_material := ShaderMaterial.new()
	atmosphere_material.shader = preload("res://shaders/atmosphere.gdshader")
	vignette.material = atmosphere_material
	atmosphere_layer.add_child(vignette)
	atmosphere_layer.add_child(preload("res://scripts/atmosphere.gd").new())
	hud.layer = 5
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
	var visual := preload("res://scripts/platform_art.gd").new()
	visual.size = size
	visual.moving = moving
	body.add_child(visual)
	add_child(body)

func label_at(text: String, at: Vector2) -> void:
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color("f2dbac"))
	var sign_style := StyleBoxFlat.new()
	sign_style.bg_color = Color("294446", 0.9)
	sign_style.content_margin_left = 8
	sign_style.content_margin_right = 8
	sign_style.content_margin_top = 4
	sign_style.content_margin_bottom = 4
	label.add_theme_stylebox_override("normal", sign_style)
	add_child(label)

func _physics_process(_delta: float) -> void:
	if player.position.x > 980 and player.position.x < 1130 and player.is_on_floor() and not checkpoint_reached:
		checkpoint_reached = true
		player.set_checkpoint(Vector2(1020, 490))
		status.text = "RUSTBELT RUN   /   CHECKPOINT REACHED\nContinue right to the repair yard.  R returns here."

func _draw() -> void:
	# Workshop flag, rails and riveted support below the checkpoint.
	draw_line(Vector2(1000,520),Vector2(1000,455),Color("283d3f"),6)
	draw_line(Vector2(999,520),Vector2(999,455),Color("d4bc88"),2)
	draw_colored_polygon(PackedVector2Array([Vector2(1002,456),Vector2(1036,462),Vector2(1028,483),Vector2(1002,478)]),Color("d7a451"))
	draw_circle(Vector2(1015,468),5,Color("314d4b"))
	# Ground decoration never crosses the solid platform's upper edge.
	for x in [60, 1200, 1600, 2800]:
		draw_line(Vector2(x,590),Vector2(x+150,590),Color("283c3e"),6)
		for i in 6:
			draw_line(Vector2(x+i*28,580),Vector2(x+i*28,602),Color("795c43"),5)
