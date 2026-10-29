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
	quit(1 if failures else 0)
