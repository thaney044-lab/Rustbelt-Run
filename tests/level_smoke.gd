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
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventKey.new()
	event.physical_keycode = code
	Input.parse_input_event(event)
	await process_frame

func run() -> void:
	lab = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(lab)
	await frames(10)
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
	check(paused and lab.director.overlay.visible and lab.director.elapsed == before,"pause freezes simulation and run timer")
	await key(KEY_ESCAPE)
	check(not paused and lab.player.controls_enabled,"Escape resumes movement")
	lab.combat.enemies[-1].defeat()
	await place(Vector2(5420,490))
	await place(Vector2(8700,450))
	await frames(20)
	check(lab.director.complete and lab.director.overlay.visible and not lab.player.controls_enabled,"workshop landing opens results and stops player input")
	await key(KEY_R)
	await frames(3)
	check(not lab.director.complete and not lab.director.overlay.visible and lab.player.controls_enabled,"R leaves results and restores checkpoint play")
	quit(1 if failures else 0)
