extends Node2D

# Constrained puzzle state: all objects reset together on checkpoint retry.
const BATTERY_HOME := Vector2(2000, 497)
const SOCKET := Vector2(2155, 493)
const SWITCH := Vector2(2080, 390)
const CONTROL := Vector2(2195, 492)
var lab: Node2D
var player: CharacterBody2D
var gate: StaticBody2D
var gate_shape: CollisionShape2D
var bridge: AnimatableBody2D
var crate: StaticBody2D
var battery := BATTERY_HOME
var carrying := false
var powered := false
var gate_open := false
var crate_broken := false
var lowered := false
var bridge_height := 375.0
var entered := false
var complete := false
var wrench_out := false
var wrench_position := Vector2.ZERO
var wrench_target := Vector2.ZERO
var wrench_returning := false
var swing_time := 0.0
var hint := ""
var marker: Label

func _ready() -> void:
	player = lab.player
	lab.platform(Vector2(2040, 560), Vector2(360, 80))
	lab.platform(Vector2(2750, 560), Vector2(440, 80))
	gate = body(Vector2(2140, 465), Vector2(20, 110), Color("ac6651"))
	gate_shape = gate.get_child(0)
	crate = body(Vector2(1910, 497), Vector2(42, 46), Color("ad8456"))
	var crate_mark := Label.new()
	crate_mark.text = "X"
	crate_mark.position = Vector2(-8, -15)
	crate.add_child(crate_mark)
	bridge = AnimatableBody2D.new()
	bridge.position = Vector2(2375, 375)
	add_shape(bridge, Vector2(310, 20), Color("dfb85d"))
	add_child(bridge)
	marker = Label.new()
	marker.position = Vector2(1760, 305)
	marker.add_theme_font_size_override("font_size", 14)
	marker.add_theme_color_override("font_color", Color("f5dbab"))
	var plaque := StyleBoxFlat.new()
	plaque.bg_color = Color("294446",0.92)
	plaque.content_margin_left = 10
	plaque.content_margin_right = 10
	plaque.content_margin_top = 6
	plaque.content_margin_bottom = 6
	marker.add_theme_stylebox_override("normal",plaque)
	marker.text = "WORKSHOP  /  02\nJ swing   K throw   E use   T reset"
	add_child(marker)
	lab.label_at("THROW -> SWITCH", Vector2(1990, 310))
	lab.label_at("BATTERY -> SOCKET -> CRANE", Vector2(2050, 580))
	lab.label_at("EXIT ->", Vector2(2720, 455))
	player.respawned.connect(on_respawn)

func add_shape(node: PhysicsBody2D, size: Vector2, color: Color) -> void:
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	collision.shape = rectangle
	node.add_child(collision)
	var visual := preload("res://scripts/platform_art.gd").new()
	visual.size = size
	visual.base_color = color
	visual.moving = size.x > 250
	visual.surface_kind = "crate" if size == Vector2(42,46) else ("gate" if size == Vector2(20,110) else "steel")
	node.add_child(visual)

func body(at: Vector2, size: Vector2, color: Color) -> StaticBody2D:
	var result := StaticBody2D.new()
	result.position = at
	add_shape(result, size, color)
	add_child(result)
	return result

func on_respawn() -> void:
	if entered:
		reset_puzzle()

func reset_puzzle() -> void:
	carrying = false
	powered = false
	gate_open = false
	crate_broken = false
	lowered = false
	complete = false
	wrench_out = false
	battery = BATTERY_HOME
	bridge_height = 375.0
	bridge.position = Vector2(2375, bridge_height)
	gate_shape.set_deferred("disabled", false)
	gate.show()
	crate.get_child(0).set_deferred("disabled", false)
	crate.show()
	hint = "Puzzle reset. Swing at the marked crate with J."

func target_in_front(at: Vector2, reach: float) -> bool:
	var difference := at - player.position
	return difference.length() <= reach and difference.x * player.facing >= -12

func swing() -> void:
	if wrench_out:
		return
	swing_time = 0.2
	if not crate_broken and target_in_front(crate.position, 80):
		crate_broken = true
		crate.get_child(0).set_deferred("disabled", true)
		crate.hide()
		hint = "Crate cleared. Throw K toward the highlighted switch."
	elif powered and target_in_front(CONTROL, 80):
		lowered = not lowered
		hint = "Crane moving to its other fixed stop."

func throw_wrench() -> void:
	if wrench_out:
		return
	wrench_out = true
	wrench_returning = false
	wrench_position = player.position
	wrench_target = SWITCH if not gate_open and target_in_front(SWITCH, 260) else player.position + Vector2(player.facing * 230, 0)

func interact() -> void:
	if not powered and carrying and player.position.distance_to(SOCKET) < 65:
		powered = true
		carrying = false
		battery = SOCKET
		hint = "Crane powered! E or J at the control lowers the bridge."
	elif not powered and not carrying and player.position.distance_to(battery) < 65:
		carrying = true
		hint = "Carry the battery to the socket; E inserts it."
	elif carrying:
		carrying = false
		# Place on the safe yard floor, never in the gap or behind the gate.
		battery = Vector2(clampf(player.position.x, 1885, 2100), 497)
		hint = "Battery placed safely. E picks it up again."
	elif powered and player.position.distance_to(CONTROL) < 65:
		lowered = not lowered
		hint = "Bridge moving. Wait until it reaches the marked stop."

func _physics_process(delta: float) -> void:
	if not entered and player.position.x > 1780 and player.is_on_floor():
		entered = true
		player.spawn_point = Vector2(1800, 490)
		hint = "Repair checkpoint active. J breaks the marked crate."
	if not entered:
		return
	if Input.is_action_just_pressed("reset_puzzle"):
		player.respawn()
	if Input.is_action_just_pressed("swing"):
		swing()
	if Input.is_action_just_pressed("throw_wrench"):
		throw_wrench()
	if Input.is_action_just_pressed("interact"):
		interact()
	if carrying:
		battery = player.position + Vector2(player.facing * 22, -12)
	swing_time = maxf(0, swing_time - delta)
	if wrench_out:
		var destination := player.position if wrench_returning else wrench_target
		wrench_position = wrench_position.move_toward(destination, 680 * delta)
		if wrench_position.distance_to(destination) < 10:
			if wrench_returning:
				wrench_out = false
			else:
				if wrench_target == SWITCH:
					gate_open = true
					gate_shape.set_deferred("disabled", true)
					gate.hide()
					hint = "Gate open. E picks up the battery and inserts it at the socket."
				wrench_returning = true
	bridge_height = move_toward(bridge_height, 510.0 if lowered else 375.0, 90 * delta)
	bridge.position = Vector2(2375, bridge_height)
	if player.position.x > 2720 and player.is_on_floor():
		complete = true
	if complete:
		lab.status.text = "REPAIR COMPLETE — route restored!\nT: reset the puzzle and play again."
	else:
		lab.status.text = "REPAIR YARD   /   J swing   K throw   E use   T reset\n" + hint
	queue_redraw()

func _draw() -> void:
	# Fixed crane tower and top beam frame the actual moving bridge.
	for x in [2250,2500]:
		draw_line(Vector2(x,590),Vector2(x,225),Color("394e4d"),18)
		draw_line(Vector2(x-3,580),Vector2(x-3,225),Color("b47d4b"),7)
		for y in range(250,560,60):
			draw_line(Vector2(x-9,y),Vector2(x+9,y+40),Color("c19662"),3)
	draw_line(Vector2(2230,225),Vector2(2520,225),Color("273c40"),26)
	draw_line(Vector2(2230,219),Vector2(2520,219),Color("d4a759"),7)
	for x in range(2240,2520,30):
		draw_line(Vector2(x,215),Vector2(x+14,235),Color("8d7048"),5)
	draw_line(SOCKET,Vector2(2195,525),Color("273b3c"),9)
	draw_line(Vector2(2195,525),Vector2(2375,525),Color("273b3c"),9)
	draw_line(SOCKET, Vector2(2375,330), Color("e6c86a") if powered else Color("657673"), 3)
	draw_line(Vector2(2375, 330), bridge.position, Color("e6c86a"), 4)
	draw_rect(Rect2(SOCKET - Vector2(18, 20), Vector2(36, 40)), Color("d0c4a0"), false, 3)
	draw_circle(SWITCH, 17, Color("6ebe99") if gate_open else Color("d79156"))
	draw_line(SWITCH - Vector2(8, 0), SWITCH + Vector2(8, 0), Color.WHITE, 3)
	if not gate_open and target_in_front(SWITCH, 260):
		draw_arc(SWITCH, 25, 0, TAU, 24, Color.WHITE, 3)
	draw_style_box(tool_box(Color("2b4146")),Rect2(battery-Vector2(13,18),Vector2(26,36)))
	draw_rect(Rect2(battery-Vector2(8,12),Vector2(16,24)),Color("8ed6ab"))
	draw_rect(Rect2(battery+Vector2(-5,-22),Vector2(10,5)),Color("e2bc72"))
	draw_line(battery+Vector2(0,-7),battery+Vector2(0,7),Color("294849"),3)
	draw_line(battery + Vector2(-6, 0), battery + Vector2(6, 0), Color("203a30"), 3)
	draw_style_box(tool_box(Color("49635d")),Rect2(CONTROL-Vector2(17,16),Vector2(34,37)))
	draw_circle(CONTROL, 12, Color("e6c86a") if powered else Color("657673"))
	draw_line(CONTROL, CONTROL + Vector2(0, -20), Color.WHITE, 3)
	if wrench_out:
		draw_circle(wrench_position, 7, Color("e2e4d5"))
		draw_line(wrench_position, wrench_position + Vector2(15, -9), Color("e2e4d5"), 5)
	if swing_time > 0:
		draw_arc(player.position, 48, -1.1 if player.facing > 0 else 2.0, 1.1 if player.facing > 0 else 4.2, 16, Color("e6c86a"), 6)
	if not crate_broken:
		draw_line(crate.position - Vector2(12, 12), crate.position + Vector2(12, 12), Color("f5e0ae"), 3)
		draw_line(crate.position + Vector2(-12, 12), crate.position + Vector2(12, -12), Color("f5e0ae"), 3)

func tool_box(fill: Color) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = fill
	b.border_color = Color("22363a")
	b.set_border_width_all(3)
	b.set_corner_radius_all(4)
	return b
