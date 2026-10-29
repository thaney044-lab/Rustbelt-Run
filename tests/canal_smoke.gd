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
		push_error(title)
		failures += 1
func run() -> void:
	var lab = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(lab)
	var passage
	for child in lab.get_children():
		if child.get_script() == load("res://scripts/canal_crossing.gd"):
			passage = child
	lab.player.position = Vector2(4380,490)
	await frames(20)
	check(passage.active and lab.player.spawn_point.x == 4370,"canal checkpoint activates")
	lab.player.position = Vector2(4660,650)
	await frames(2)
	check(lab.player.position.x == 4370 and lab.player.position.y < 530,"water restores safe checkpoint")
	lab.player.position = Vector2(5220,490)
	await frames(25)
	check(passage.finished,"foundry gate completes extended route")
	lab.player.respawn()
	await frames(2)
	check(not passage.finished,"retry allows canal replay")
	quit(1 if failures else 0)
