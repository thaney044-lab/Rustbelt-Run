extends "res://tests/level_smoke.gd"

func run() -> void:
	lab = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(lab)
	for enemy in lab.combat.enemies: enemy.defeat()
	var area = lab.director.foundry
	await place(Vector2(465,500))
	await jump_to(700)
	check(lab.player.is_on_floor() and lab.player.position.x > 622,"widened entrance gap is reachable with a held jump")
	await place(Vector2(750,500))
	await jump_to(1030)
	check(lab.player.is_on_floor() and lab.player.position.x > 907,"second wide gap reaches the checkpoint bank")
	await place(Vector2(1130,500))
	await jump_to(1410)
	check(lab.player.is_on_floor() and lab.player.position.x > 1287,"third wide gap reaches the narrower bank")
	area.active = true
	area.stage = 2
	area.powered = true
	lab.player.set_checkpoint(Vector2(6910,490))
	area.time = 0
	await place(Vector2(7250,500))
	await jump_to(7460)
	check(lab.player.is_on_floor() and lab.player.position.x > 7397 and lab.player.position.y < 460,"transfer entrance reaches the raised vent landing")
	var shuttle: AnimatableBody2D
	for child in lab.get_children():
		if child is AnimatableBody2D and absf(child.origin.x-7700)<1: shuttle = child
	shuttle.elapsed = -PI/2/shuttle.pace
	area.time = 0
	await place(Vector2(7500,455))
	await jump_to(7680)
	check(lab.player.is_on_floor() and lab.player.position.x > 7580 and lab.player.position.y < 430,"timed jump boards the faster transfer shuttle")
	# Ride to its right-hand turnaround before committing to the next bank.
	for i in 240:
		if lab.player.position.x > 7735: break
		await frames(1)
	await jump_to(7920)
	check(lab.player.is_on_floor() and area.stage == 3 and lab.player.spawn_point.x == 7940,"shuttle exit reaches and saves the service-island checkpoint")
	area.time = 1.5
	await place(Vector2(8020,500))
	await jump_to(8230)
	check(lab.player.is_on_floor() and lab.player.position.x > 8172 and lab.player.position.y < 475,"waiting for steam to clear makes the second wide gap reachable")
	area.time = 1.5
	await place(Vector2(8265,470))
	await jump_to(8430)
	check(lab.player.is_on_floor() and lab.player.position.x > 8372 and lab.player.position.y < 425,"precision jump reaches the final upper landing")
	await place(Vector2(8460,420))
	await jump_to(8650)
	check(lab.player.is_on_floor() and lab.player.position.x > 8510,"last jump reaches the relocated workshop bank")
	lab.player.respawn()
	await frames(3)
	check(lab.player.position.x == 7940 and not area.finished,"late retry preserves the new midpoint checkpoint")
	area.time = 1.45
	lab.player.position = Vector2(7460,455)
	lab.player.velocity = Vector2.ZERO
	await frames(2)
	check(not area.vent_live(0) and lab.player.position.x == 7460,"amber warning is harmless before steam starts")
	area.time = 2.25
	await frames(2)
	check(lab.player.position.x == 7940 and area.time < 0.1,"live steam returns to checkpoint and resets its cycle")
	quit(1 if failures else 0)
