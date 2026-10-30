extends "res://tests/level_smoke.gd"

func run() -> void:
	lab = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(lab)
	var freight: Node2D
	for child in lab.get_children():
		if child.get_script() == load("res://scripts/freight_run.gd"): freight = child
	var foundry = lab.director.foundry
	foundry.active = true
	foundry.powered = true
	foundry.stage = 3
	for enemy in lab.combat.enemies: enemy.defeat()
	await place(Vector2(8680,460))
	check(not lab.director.complete and freight.checkpoint_stage == 1,"old ending is now the aqueduct checkpoint")
	check(lab.get_viewport().get_camera_2d().limit_right == 13060,"camera includes the full extended route")
	check(lab.combat.enemies.size() == 7 and lab.combat.scrap_positions.size() == 67,"extension adds three patrols and twenty-two scrap pickups")
	# Check each new landing using ordinary movement and held jumps.
	for hop in [[Vector2(8820,470),9000],[Vector2(9040,430),9200],[Vector2(9250,370),9400]]:
		await place(hop[0])
		await jump_to(hop[1])
		check(lab.player.is_on_floor() and absf(lab.player.position.x-hop[1]) < 80,"aqueduct approach landing at %d" % hop[1])
	var shuttles: Array[Node2D] = []
	for child in lab.get_children():
		if child is AnimatableBody2D and child.get("origin") != null and child.origin.x > 9000:
			shuttles.append(child)
	check(shuttles.size() == 2,"both new freight shuttles exist")
	var before: float = shuttles[0].position.x
	await frames(25)
	check(absf(shuttles[0].position.x-before) > 1,"freight shuttle moves along its route")
	for shuttle in shuttles:
		shuttle.set_physics_process(false)
		shuttle.position = shuttle.origin
	for hop in [[Vector2(9570,440),9780],[Vector2(9830,400),10040],[Vector2(10175,440),10340],[Vector2(10390,370),10560],[Vector2(10610,320),10760],[Vector2(10910,370),11070],[Vector2(11120,420),11260]]:
		await place(hop[0])
		await jump_to(hop[1])
		check(lab.player.is_on_floor() and absf(lab.player.position.x-hop[1]) < 80,"freight crossing landing at %d" % hop[1])
	check(freight.checkpoint_stage == 3,"last-mile checkpoint activates on the safe bank")
	for hop in [[Vector2(11440,500),11580],[Vector2(11620,440),11800],[Vector2(11850,390),12000],[Vector2(12135,440),12280],[Vector2(12330,390),12510],[Vector2(12560,350),12740]]:
		# Start each vent crossing in its safe phase; the final vent is offset.
		foundry.time = 2.9 if hop[1] == 12280 else 0
		await place(hop[0])
		await jump_to(hop[1])
		check(lab.player.is_on_floor() and absf(lab.player.position.x-hop[1]) < 85,"last-mile landing at %d" % hop[1])
	check(freight.checkpoint_stage == 4,"last safe bank saves progress")
	lab.player.respawn()
	await frames(3)
	check(lab.player.spawn_point == freight.BANKS[3] and not lab.director.complete,"retry preserves extension checkpoint without completing the run")
	for index in [2, 3]:
		foundry.time = 1.5 - index * 2.1
		lab.player.position = foundry.VENTS[index] - Vector2(0, 20)
		lab.player.velocity = Vector2.ZERO
		await frames(2)
		check(not foundry.vent_live(index) and absf(lab.player.position.x - foundry.VENTS[index].x) < 1, "new vent warning leaves time to react")
		foundry.time = 2.25 - index * 2.1
		await frames(2)
		check(lab.player.position.x == 12040, "new vent burst recovers to the latest safe bank")
	await place(Vector2(12900,450))
	check(lab.director.complete and lab.director.overlay.visible,"relocated workshop opens the results screen")
	quit(1 if failures else 0)
