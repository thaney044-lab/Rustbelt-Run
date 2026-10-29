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
		if child.get_script() == load("res://scripts/piston_passage.gd"):
			passage = child
	lab.player.position = Vector2(2800,490)
	await frames(20)
	check(passage.checkpoint_active and lab.player.spawn_point.x == 2780,"passage checkpoint activates")
	lab.player.position = passage.SECRET
	await frames(1)
	check(passage.secret_found,"loft part collects on contact")
	passage.time = 2.5
	lab.player.position = Vector2(3190,490)
	await frames(2)
	check(lab.player.position.x == 2780 and passage.time < 0.1,"piston contact restores safe checkpoint and cycle")
	check(passage.secret_found,"collected part survives retry")
	lab.player.position = Vector2(4030,490)
	await frames(25)
	check(passage.finished,"freight-car destination completes stage")
	lab.player.respawn()
	await frames(2)
	check(not passage.finished,"retry leaves completed state for replay")
	quit(1 if failures else 0)
