extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func frames(n: int) -> void:
	for i in n:
		await physics_frame
		await process_frame
func check(ok: bool, text: String) -> void:
	if ok: print("PASS: ",text)
	else:
		push_error(text)
		failures += 1
func run() -> void:
	var lab = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(lab)
	var area
	for child in lab.get_children():
		if child.get_script() == load("res://scripts/foundry_run.gd"): area = child
	lab.player.position = Vector2(5420,490)
	await frames(20)
	check(area.active and lab.player.spawn_point.x == 5420,"foundry entry checkpoint activates")
	area.use_control()
	check(not area.powered,"hoist control requires proximity")
	lab.player.position = Vector2(5490,490)
	area.use_control()
	await frames(70)
	check(area.powered and area.lift.position.y < 470,"nearby control starts vertical hoist")
	lab.player.position = area.lift.position+Vector2(0,-30)
	lab.player.velocity = Vector2.ZERO
	await frames(25)
	check(lab.player.is_on_floor() and absf(lab.player.position.y-area.lift.position.y+30)<3,"hoist carries player vertically")
	lab.player.respawn()
	await frames(2)
	check(not area.powered and lab.player.position.x == 5420,"retry resets entry puzzle to a valid state")
	lab.combat.enemies[3].defeat()
	lab.player.position = Vector2(6940,490)
	await frames(20)
	check(area.stage == 2 and lab.player.spawn_point.x == 6910,"far-bank checkpoint saves crossing progress")
	lab.player.position = Vector2(12900,450)
	await frames(30)
	check(area.finished,"final landing completes extended route")
	lab.player.respawn()
	await frames(2)
	check(not area.finished and lab.player.position.x == 6910,"final retry returns to far bank")
	quit(1 if failures else 0)
