extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	if ok:
		print("PASS: ",description)
	else:
		push_error(description)
		failures += 1

func run() -> void:
	var library = load("res://scripts/rendered_art.gd")
	var aligned: bool = library.DATA.size() == 16
	for entry in library.DATA.values():
		var source_image: Image = entry[0].get_image()
		aligned = aligned and source_image.get_size() == Vector2i(entry[1]*3)
		aligned = aligned and source_image.get_format() == Image.FORMAT_RGBA8 and source_image.get_pixel(0,0).a == 0
		aligned = aligned and Rect2(Vector2.ZERO,entry[1]).has_point(entry[2])
	check(aligned,"all sixteen rendered sprites have transparent margins and valid world anchors")
	var art = load("res://scripts/fox_visual.gd")
	var image: Image = art.SHEET.get_image()
	check(image.get_size() == Vector2i(1536,1024),"fox atlas matches declared layout")
	check(image.get_pixel(0,0).a == 0.0,"fox sheet preserves background transparency")
	var valid := true
	for region in art.REGIONS:
		valid = valid and Rect2(Vector2.ZERO,Vector2(image.get_size())).encloses(region)
	check(valid and art.REGIONS.size() == 8,"all eight pose regions fit the atlas")
	var scene = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(scene)
	check(scene.enhanced_visuals,"First Shift enables the new rendered art profile")
	var fox = scene.player.get_child(1)
	scene.player.controls_enabled = false
	scene.player.velocity.y = -300
	await process_frame
	await process_frame
	check(fox.frame == 5,"rising selects the jump pose")
	scene.player.velocity.y = 300
	await process_frame
	await process_frame
	check(fox.frame == 6,"falling selects the descent pose")
	Input.action_press("swing")
	await process_frame
	await process_frame
	check(fox.frame == 7,"wrench input selects the swing pose")
	Input.action_release("swing")
	# The visible reticle must agree with the wrench's actual target.
	var near_bot = scene.combat.enemies[0]
	var far_bot = scene.combat.enemies[1]
	near_bot.set_physics_process(false)
	far_bot.set_physics_process(false)
	scene.player.position = Vector2(100, 499)
	scene.player.facing = 1
	near_bot.position = Vector2(180, 499)
	far_bot.position = Vector2(220, 499)
	check(near_bot.is_targeted() and not far_bot.is_targeted(), "only the nearest wrench target is highlighted")
	scene.player.facing = -1
	check(not near_bot.is_targeted(), "targets behind the player are not highlighted")
	scene.player.facing = 1
	near_bot.defeat()
	check(not near_bot.is_targeted() and far_bot.is_targeted(), "defeated enemies hand targeting to the next live bot")
	near_bot.reset()
	check(near_bot.alive and near_bot.position == near_bot.home and near_bot.wheel_rotation == 0, "retry resets enemy animation and patrol position")
	quit(1 if failures else 0)
