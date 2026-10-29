extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func frames(n: int) -> void:
	for i in n:
		await physics_frame
		await process_frame
func check(ok: bool, title: String) -> void:
	if ok:
		print("PASS: ",title)
	else:
		push_error("FAIL: "+title)
		failures += 1
func run() -> void:
	var lab = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(lab)
	await frames(20)
	var player = lab.player
	var combat = lab.combat
	var enemy = combat.enemies[0]
	check(player.health == 3,"player starts with three health points")
	player.position = enemy.position+Vector2(-55,0)
	player.facing = 1
	combat.swing()
	check(not enemy.alive,"front-facing wrench swing defeats a nearby patrol bot")
	player.respawn()
	check(enemy.alive,"retry restores enemy patrol state")
	player.invulnerability = 0
	player.position = enemy.position
	player.velocity = Vector2.ZERO
	enemy.contact_player(player)
	check(player.health == 2 and player.velocity.x != 0,"side contact costs health and knocks player clear")
	enemy.contact_player(player)
	check(player.health == 2,"temporary protection prevents repeated contact damage")
	player.invulnerability = 0
	player.health = 1
	enemy.contact_player(player)
	check(player.health == 3 and player.position == player.spawn_point,"fatal damage returns to checkpoint with full health")
	player.position = enemy.position+Vector2(0,-33)
	player.velocity.y = 220
	enemy.contact_player(player)
	check(not enemy.alive and player.velocity.y < 0,"landing on flat bot top disables it and bounces player")
	player.respawn()
	player.position = enemy.position+Vector2(-55,0)
	player.facing = -1
	combat.attack_cooldown = 0
	combat.swing()
	check(enemy.alive,"wrench swing does not hit a bot behind the player")
	player.position = enemy.position+Vector2(-150,0)
	player.facing = 1
	check(combat.begin_throw(),"directional throw acquires an in-range bot")
	combat.yard.throw_wrench()
	check(not combat.yard.wrench_out,"combat and puzzle throws cannot create duplicate wrenches")
	await frames(70)
	check(not enemy.alive and not combat.flight_active,"thrown wrench disables bot and returns automatically")
	player.position = combat.scrap_positions[0]
	combat.collect_scrap()
	var count: int = combat.scrap_count
	combat.collect_scrap()
	check(count > 0 and combat.scrap_count == count,"scrap is collected once per piece")
	player.respawn()
	check(combat.scrap_count == count and combat.collected[0],"collected scrap survives retries")
	player.health = 1
	player.set_checkpoint(Vector2(100,490))
	check(player.health == 3,"reaching a checkpoint restores health")
	player.respawn()
	player.position = Vector2(1980,490)
	player.velocity = Vector2.ZERO
	player.facing = 1
	combat.yard.entered = true
	check(not combat.begin_throw(),"puzzle area keeps switch targeting when no bot is in range")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_K
	key.keycode = KEY_K
	key.pressed = true
	Input.parse_input_event(key)
	await frames(4)
	check(combat.yard.wrench_out and not combat.flight_active,"keyboard throw routes to the existing puzzle wrench")
	key = InputEventKey.new()
	key.physical_keycode = KEY_K
	key.keycode = KEY_K
	key.pressed = false
	Input.parse_input_event(key)
	await frames(55)
	check(combat.yard.gate_open and not combat.yard.wrench_out,"keyboard throw still opens the gate and returns after combat integration")
	var in_bounds := true
	for i in 100:
		await frames(1)
		in_bounds = in_bounds and enemy.position.x >= enemy.patrol_left and enemy.position.x <= enemy.patrol_right
	check(in_bounds,"patrol stays on its authored safe-ground route")
	print("Gameplay smoke test failures: ",failures)
	quit(1 if failures else 0)
