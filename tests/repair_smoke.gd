extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame
func check(ok: bool, message: String) -> void:
	if ok:
		print("PASS: ", message)
	else:
		push_error("FAIL: " + message)
		failures += 1
func run() -> void:
	var lab = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(lab)
	var player = lab.player
	var yard = lab.get_child(lab.get_child_count() - 1)
	# Find the puzzle by its public state rather than child insertion order.
	for child in lab.get_children():
		if child.get_script() == load("res://scripts/repair_yard.gd"):
			yard = child
	player.position = Vector2(1800, 490)
	await frames(25)
	check(yard.entered and player.spawn_point.x == 1800, "repair checkpoint activates")
	player.position = Vector2(1860, 490)
	player.facing = 1
	yard.swing()
	await frames(2)
	check(yard.crate_broken and yard.crate.get_child(0).disabled, "wrench swing breaks marked crate")
	player.position = Vector2(1980, 490)
	yard.throw_wrench()
	await frames(50)
	check(yard.gate_open and yard.gate_shape.disabled and not yard.wrench_out, "throw hits highlighted switch, opens gate and returns")
	player.position = Vector2(2000, 490)
	yard.interact()
	check(yard.carrying, "battery can be picked up")
	player.position = Vector2(2370, 490)
	yard.interact()
	check(not yard.carrying and yard.battery.x <= 2100, "battery dropped over gap returns to safe floor")
	player.position = yard.battery
	yard.interact()
	player.position = Vector2(2155, 490)
	yard.interact()
	check(yard.powered and not yard.carrying, "battery powers socket")
	player.position = Vector2(2195, 490)
	yard.interact()
	await frames(110)
	check(is_equal_approx(yard.bridge.position.y, 510.0), "powered crane reaches bridge stop")
	player.position = Vector2(2375, 475)
	player.velocity = Vector2.ZERO
	await frames(25)
	check(player.is_on_floor(), "lowered bridge supports player")
	player.respawn()
	await frames(3)
	check(not yard.powered and not yard.gate_open and not yard.crate_broken and not yard.carrying and yard.battery == yard.BATTERY_HOME and yard.bridge.position.y == 375, "checkpoint restores entire valid puzzle state")
	check(not yard.gate_shape.disabled and not yard.crate.get_child(0).disabled, "reset restores gate and crate collision")
	print("Repair smoke test failures: ", failures)
	quit(1 if failures else 0)
