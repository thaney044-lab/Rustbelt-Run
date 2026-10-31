extends SceneTree
var failures := 0
var lab: Node2D

func _initialize() -> void:
	call_deferred("run")

func frames(n: int) -> void:
	for i in n:
		await physics_frame
		await process_frame

func check(ok: bool, description: String) -> void:
	if ok: print("PASS: ",description)
	else:
		push_error(description)
		failures += 1

func place(at: Vector2) -> void:
	lab.player.position = at
	lab.player.velocity = Vector2.ZERO
	await frames(15)

func jump_to(target_x: float) -> void:
	var direction := "move_right" if target_x > lab.player.position.x else "move_left"
	Input.action_press("jump")
	Input.action_press(direction)
	for i in 70:
		if absf(lab.player.position.x-target_x) < 10: Input.action_release(direction)
		await frames(1)
		if i > 12 and lab.player.is_on_floor(): break
	Input.action_release("jump")
	Input.action_release(direction)
	await frames(8)

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	Input.parse_input_event(event)
	await process_frame

func run() -> void:
	lab = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(lab)
	await frames(10)
	await place(Vector2(1060,398))
	check(not lab.checkpoint_reached, "upper salvage ledge does not activate the checkpoint below")
	await place(Vector2(1020,500))
	check(lab.checkpoint_reached, "checkpoint activates on its actual landing bank")
	check(lab.combat.enemies[0].patrol_speed < lab.combat.enemies[-1].patrol_speed, "First Shift patrol pressure builds toward the finale")
	var yard = lab.combat.yard
	check(lab.director.objective_text(2000).contains("crate"), "repair objective starts with clearing the crate")
	yard.crate_broken = true
	check(lab.director.objective_text(2000).contains("switch"), "repair objective advances to the gate switch")
	yard.gate_open = true
	yard.carrying = true
	check(lab.director.objective_text(2000).contains("Insert"), "carried battery produces the socket objective")
	yard.powered = true
	check(lab.director.objective_text(2000).contains("control"), "powered crane produces the bridge objective")
	yard.crate_broken = false
	yard.gate_open = false
	yard.carrying = false
	yard.powered = false
	await place(Vector2(480,340))
	await jump_to(650)
	check(lab.player.is_on_floor() and lab.player.position.y < 315 and lab.player.position.x > 595,"first rooftop jump is reachable using normal movement")
	await place(Vector2(690,310))
	await jump_to(850)
	check(lab.player.is_on_floor() and lab.player.position.y < 290 and lab.director.caches[0],"rooftop jump reaches and collects the rare part")
	lab.player.health = 1
	lab.player.respawn()
	await frames(3)
	check(lab.director.cache_count() == 1 and lab.player.health == 3,"rare parts survive checkpoint retries")
	await place(Vector2(890,285))
	await jump_to(1130)
	check(lab.player.is_on_floor() and lab.player.position.x > 1062 and lab.player.position.y < 315,"offset rooftop remains reachable from the salvage ledge")
	await place(Vector2(1450,420))
	await jump_to(1600)
	check(lab.player.is_on_floor() and lab.player.position.y < 340 and lab.player.position.x > 1532,"staggered yard ledges remain reachable without overhead stacking")
	await place(Vector2(6240,360))
	await jump_to(6110)
	check(lab.player.is_on_floor() and lab.player.position.y < 280,"foundry side approach reaches the upper salvage ledge")
	await place(Vector2(6150,275))
	await jump_to(6290)
	check(lab.director.cache_count() == 2,"foundry upper route reaches its second rare part")
	await key(KEY_ESCAPE)
	var before: float = lab.director.elapsed
	await frames(10)
	check(lab.director.primary.has_focus(), "pause focuses the resume button for keyboard navigation")
	await key(KEY_DOWN)
	check(lab.director.secondary.has_focus(), "Down selects the restart button")
	await key(KEY_UP)
	check(lab.director.primary.has_focus(), "Up returns to resume")
	check(paused and lab.director.overlay.visible and lab.director.elapsed == before,"pause freezes simulation and run timer")
	await key(KEY_ENTER)
	check(not paused and lab.player.controls_enabled, "Enter activates focused resume button")
	var start := InputEventJoypadButton.new()
	start.button_index = JOY_BUTTON_START
	start.pressed = true
	Input.parse_input_event(start)
	await process_frame
	await process_frame
	check(paused and lab.director.primary.has_focus(), "controller Start opens pause with focused resume")
	start = InputEventJoypadButton.new()
	start.button_index = JOY_BUTTON_START
	Input.parse_input_event(start)
	await key(KEY_ESCAPE)
	check(not paused and lab.player.controls_enabled, "Escape resumes after controller pause")
	lab.combat.enemies[3].defeat()
	await place(Vector2(5420,490))
	await place(Vector2(12900,450))
	await frames(20)
	check(lab.director.complete and lab.director.overlay.visible and not lab.player.controls_enabled,"workshop landing opens results and stops player input")
	await key(KEY_R)
	await frames(3)
	check(not lab.director.complete and not lab.director.overlay.visible and lab.player.controls_enabled,"R leaves results and restores checkpoint play")
	quit(1 if failures else 0)
