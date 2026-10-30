extends "res://tests/level_smoke.gd"

func run() -> void:
	var campaign = root.get_node("Campaign")
	for id in [1,2]:
		lab = load("res://scenes/mosswater.tscn" if id == 1 else "res://scenes/emberline.tscn").instantiate()
		root.add_child(lab)
		await frames(6)
		check(lab.combat.scrap_positions.size() > 30,"new mission has its own scrap route")
		check(lab.combat.enemies.size() == (3 if id == 1 else 4),"new mission has authored patrols")
		check(not lab.interact_relay() and lab.relay_count() == 0,"distant controls cannot be activated from spawn")
		var enemy = lab.combat.enemies[0]
		lab.player.position = enemy.position-Vector2(50,0)
		lab.player.facing = 1
		lab.combat.swing()
		check(not enemy.alive,"wrench combat works without the First Shift repair puzzle")
		lab.player.respawn()
		check(enemy.alive,"mission retry restores its patrols")
		for bot in lab.combat.enemies: bot.defeat()
		var lift: AnimatableBody2D
		for i in lab.moving_specs.size():
			if lab.moving_specs[i][4] == "y": lift = lab.movers[i]
		var idle: Vector2 = lift.position
		await frames(12)
		check(lift.position == idle, "unpowered machinery waits for relay activation")
		lab.relay_on.fill(true)
		var lift_before: Vector2 = lift.position
		lab.player.position = lift.position-Vector2(0,30)
		lab.player.velocity = Vector2.ZERO
		await frames(30)
		check(lift.position.distance_to(lift_before) > 2 and lab.player.is_on_floor() and absf(lab.player.position.y-lift.position.y+30) < 4,"vertical lift carries the player")
		lab.relay_on.fill(false)
		# Freeze machinery while verifying each authored jump connection in real physics.
		lab.set_physics_process(false)
		for child in lab.get_children():
			if child is AnimatableBody2D:
				child.set_physics_process(false)
				child.position = child.origin
		for i in range(1,lab.data.platforms.size()):
			var previous: Array = lab.data.platforms[i-1]
			var next: Array = lab.data.platforms[i]
			await place(Vector2(previous[0]+previous[2]/2.0-26,previous[1]-previous[3]/2.0-20))
			await jump_to(next[0]-next[2]/2.0+minf(60,next[2]/2.0))
			check(lab.player.is_on_floor() and absf(lab.player.position.y-(next[1]-next[3]/2.0-20)) < 3 and absf(lab.player.position.x-next[0]) < next[2]/2.0+13,"level %d jump connection %d" % [id+1,i])
		lab.set_physics_process(true)
		var goal_bank: Array = lab.data.platforms[-1]
		await place(Vector2(lab.data.goal+20,goal_bank[1]-goal_bank[3]/2.0-20))
		check(not lab.director.complete and not lab.exit_shape.disabled,"exit stays closed until every relay is restored")
		for at in lab.data.relays:
			await place(at)
			check(lab.interact_relay(),"nearby E interaction restores a relay")
			check(not lab.interact_relay(),"restored relay cannot award duplicate power")
		await frames(2)
		check(lab.exit_shape.disabled,"restoring all power physically opens the exit gate")
		var count: int = lab.relay_count()
		lab.player.respawn()
		await frames(3)
		check(lab.relay_count() == count and lab.player.health == 3,"relay power survives checkpoint recovery")
		for index in lab.data.hazards.size():
			var r: Rect2 = lab.hazard_rect(index)
			lab.time = 1.6-index*1.7
			lab.player.position = Vector2(r.get_center().x,r.end.y-22)
			lab.player.velocity = Vector2.ZERO
			await frames(2)
			check(not lab.hazard_live(index) and absf(lab.player.position.x-r.get_center().x) < 1,"hazard warning leaves time to react")
			lab.time = 2.4-index*1.7
			await frames(2)
			check(lab.player.position.x == lab.player.spawn_point.x,"active hazard restores the safe checkpoint")
		var last: Array = lab.data.platforms[-1]
		await place(Vector2(lab.data.goal+20,last[1]-last[3]/2.0-30))
		check(lab.director.complete and lab.director.overlay.visible,"powered exit completes the mission")
		check(lab.director.primary.has_focus(),"results screen offers a focused campaign action")
		lab.player.respawn()
		await frames(3)
		check(not lab.director.complete and lab.player.controls_enabled,"R returns from results to the mission checkpoint")
		lab.queue_free()
		await process_frame
		await process_frame
	# Save best time and best scrap independently, then restore the test device's save.
	var old_records: Dictionary = campaign.records.duplicate(true)
	var existed := FileAccess.file_exists(campaign.SAVE_PATH)
	var old_bytes := FileAccess.get_file_as_bytes(campaign.SAVE_PATH) if existed else PackedByteArray()
	campaign.records.erase(1)
	campaign.record_completion(1,90.0,10)
	campaign.record_completion(1,120.0,5)
	campaign.record_completion(1,80.0,8)
	check(campaign.records[1].time == 80.0 and campaign.records[1].scrap == 10, "campaign preserves the fastest time and largest scrap haul")
	var restored = load("res://scripts/campaign.gd").new()
	root.add_child(restored)
	check(restored.records[1].time == 80.0 and restored.records[1].scrap == 10, "completion records survive a fresh campaign load")
	restored.queue_free()
	campaign.records = old_records
	if existed:
		var save := FileAccess.open(campaign.SAVE_PATH,FileAccess.WRITE)
		save.store_buffer(old_bytes)
		save.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(campaign.SAVE_PATH))
	# Verify scene transitions through the actual campaign router.
	campaign.play(1)
	await process_frame
	await process_frame
	check(current_scene != null and current_scene.mission_id == 1,"selector loads Mosswater as an independent scene")
	current_scene.director.advance()
	await process_frame
	await process_frame
	check(current_scene != null and current_scene.mission_id == 2,"next-level action opens Emberline Summit")
	campaign.menu()
	await process_frame
	await process_frame
	check(current_scene.get_script() == load("res://scripts/campaign_menu.gd"),"campaign returns to the level selector")
	check(current_scene.buttons[0].has_focus(),"selector supports keyboard navigation on entry")
	quit(1 if failures else 0)
