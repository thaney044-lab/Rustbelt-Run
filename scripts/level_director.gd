extends Node2D
## Session presentation and optional discoveries; puzzle/checkpoint ownership stays local.
var lab: Node2D
var foundry: Node2D
var passage: Node2D
var elapsed := 0.0
var retries := 0
var complete := false
var paused := false
var chapter := -1
var toast_time := 0.0
var last_checkpoint := Vector2(100,490)
var caches := [false,false]
const CACHE_POSITIONS := [Vector2(850,270),Vector2(6290,220)]
const CHAPTERS := ["01  /  CINDER YARD","02  /  THE REPAIR WORKS","03  /  PISTON HALL","04  /  FLOODED VIADUCT","05  /  THE FOUNDRY","06  /  FREIGHT AQUEDUCT","07  /  THE LAST MILE"]
var toast: Label
var route: Label
var progress: Line2D
var overlay: ColorRect
var heading: Label
var details: Label
var primary: Button
var secondary: Button
var time := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 2
	lab.player.respawned.connect(on_retry)
	var canvas := CanvasLayer.new()
	canvas.layer = 8
	add_child(canvas)
	toast = make_label(Vector2(28,116),18,Color("f1d59a"))
	canvas.add_child(toast)
	route = make_label(Vector2(28,591),12,Color("e6d7af"))
	canvas.add_child(route)
	var track := Line2D.new()
	track.points = PackedVector2Array([Vector2(28,623),Vector2(1124,623)])
	track.width = 3
	track.default_color = Color("18332f",0.8)
	canvas.add_child(track)
	progress = Line2D.new()
	progress.width = 3
	progress.default_color = Color("c2ac6f")
	canvas.add_child(progress)
	overlay = ColorRect.new()
	overlay.color = Color("0b211e",0.90)
	overlay.size = Vector2(1152,648)
	overlay.visible = false
	canvas.add_child(overlay)
	var eyebrow := make_label(Vector2(0,143),14,Color("b9a875"))
	eyebrow.text = "R U S T B E L T   R U N     /     F I R S T   S H I F T"
	eyebrow.size.x = 1152
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.add_child(eyebrow)
	heading = make_label(Vector2(0,193),42,Color("f0dfb9"))
	heading.size.x = 1152
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.add_child(heading)
	details = make_label(Vector2(0,267),18,Color("b6c6b1"))
	details.size.x = 1152
	details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details.add_theme_constant_override("line_spacing",12)
	overlay.add_child(details)
	primary = make_button(Vector2(401,403),Vector2(350,44))
	primary.pressed.connect(func():
		if complete: replay()
		else: toggle_pause()
	)
	overlay.add_child(primary)
	secondary = make_button(Vector2(401,459),Vector2(350,40))
	secondary.pressed.connect(func():
		if complete: lab.player.respawn()
		else: replay()
	)
	overlay.add_child(secondary)
	primary.focus_neighbor_bottom = primary.get_path_to(secondary)
	primary.focus_neighbor_top = primary.get_path_to(secondary)
	secondary.focus_neighbor_bottom = secondary.get_path_to(primary)
	secondary.focus_neighbor_top = secondary.get_path_to(primary)

func make_label(at: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = at
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.add_theme_color_override("font_shadow_color",Color("0d211d"))
	label.add_theme_constant_override("shadow_offset_y",2)
	return label

func make_button(at: Vector2, dimensions: Vector2) -> Button:
	var button := Button.new()
	button.position = at
	button.size = dimensions
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size",16)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("30483a")
	style.border_color = Color("c7ae72")
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	button.add_theme_stylebox_override("normal",style)
	var hover := style.duplicate()
	hover.bg_color = Color("51624a")
	button.add_theme_stylebox_override("hover",hover)
	var focus := style.duplicate()
	focus.bg_color = Color("48664f")
	focus.border_color = Color("ffe2a1")
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_color_override("font_color",Color("f0dfb9"))
	return button

func message(text: String) -> void:
	toast.text = text
	toast_time = 3.2

func on_retry() -> void:
	retries += 1
	complete = false
	paused = false
	get_tree().paused = false
	lab.player.controls_enabled = true
	primary.release_focus()
	secondary.release_focus()
	overlay.hide()

func replay() -> void:
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")

func toggle_pause() -> void:
	if complete: return
	paused = not paused
	get_tree().paused = paused
	lab.player.controls_enabled = not paused
	overlay.visible = paused
	if paused:
		heading.text = "Take a breather."
		details.text = "A/D or arrows  ·  Run      Space  ·  Jump\nJ  ·  Swing      K  ·  Throw      E  ·  Use\nR  ·  Return to checkpoint      T  ·  Reset repair puzzle\nController: A jump · X swing · B throw · Y use · Start pause"
		primary.text = "RESUME  /  ESC"
		secondary.text = "RESTART FIRST SHIFT"
		primary.grab_focus()
	else:
		primary.release_focus()
		secondary.release_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo(): return
	if (event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE) or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif complete and event is InputEventKey and event.pressed and event.physical_keycode == KEY_ENTER:
		replay()
		get_viewport().set_input_as_handled()

func cache_count() -> int:
	return int(caches[0])+int(caches[1])

func finish() -> void:
	complete = true
	lab.player.controls_enabled = false
	lab.player.velocity = Vector2.ZERO
	heading.text = "The workshop lights are on."
	var parts := cache_count()+int(passage.secret_found)
	details.text = "FIRST SHIFT COMPLETE\n%02d:%02d    ·    %d scrap recovered    ·    %d/3 rare parts\n%d checkpoint retries    ·    Explore the rooftops to find every part." % [int(elapsed)/60,int(elapsed)%60,lab.combat.scrap_count,parts,retries]
	primary.text = "PLAY AGAIN  /  ENTER"
	secondary.text = "EXPLORE FROM CHECKPOINT  /  R"
	overlay.show()
	primary.grab_focus()
	toast.hide()

func _process(delta: float) -> void:
	if paused: return
	time += delta
	if complete:
		lab.player.invulnerability = 1.0
		return
	elapsed += delta
	var x: float = lab.player.position.x
	var next_chapter := 0 if x < 1850 else (1 if x < 2980 else (2 if x < 4280 else (3 if x < 5350 else (4 if x < 8600 else (5 if x < 11100 else 6)))))
	if next_chapter != chapter:
		chapter = next_chapter
		message(CHAPTERS[chapter])
	if lab.player.spawn_point != last_checkpoint:
		last_checkpoint = lab.player.spawn_point
		lab.effects.celebrate(lab.player.position, Color("9cdbb1"), "CHECKPOINT")
		message("CHECKPOINT LIT  /  progress secured · health restored")
	for i in CACHE_POSITIONS.size():
		if not caches[i] and lab.player.position.distance_to(CACHE_POSITIONS[i]) < 32:
			caches[i] = true
			lab.player.health = 3
			lab.effects.celebrate(CACHE_POSITIONS[i], Color("f1ce77"), "RARE PART")
			message("RARE PART RECOVERED  /  rooftop salvage · health restored")
	toast_time = maxf(0,toast_time-delta)
	toast.visible = toast_time > 0
	toast.modulate.a = minf(1,toast_time)
	route.text = "%s     /     PARTS %d/3     /     %02d:%02d" % [CHAPTERS[chapter],cache_count()+int(passage.secret_found),int(elapsed)/60,int(elapsed)%60]
	progress.points = PackedVector2Array([Vector2(28,623),Vector2(28+clampf(x/preload("res://scripts/freight_run.gd").END_X,0,1)*1096,623)])
	if foundry.finished: finish()
	update_status()
	queue_redraw()

func objective_text(x: float) -> String:
	if x < 1850:
		return "Head right to the repair works · rooftops hide rare salvage."
	if x < 2780:
		var yard = lab.combat.yard
		if not yard.crate_broken: return "J · Break the wooden crate to reach the battery."
		if not yard.gate_open: return "K · Throw the wrench toward the elevated switch."
		if not yard.powered:
			return "E · Insert the battery in the socket." if yard.carrying else "E · Pick up the battery beside the broken crate."
		if not yard.lowered: return "E · Use the crane control to lower the bridge."
		return "Cross the lowered bridge to the maintenance loft."
	if x < 4280: return "Watch the amber warning · cross when the pistons rise."
	if x < 5350: return "Ride the maintenance platform across the flooded canal."
	if x >= 12000: return "Time the final steam vent, then follow the workshop lights."
	if x >= 11100: return "Cross the steam platforms to the last safe bank."
	if x >= 10000: return "Climb the freight catwalks and clear the patrol bank."
	if x >= 8600: return "Cross the aqueduct and ride the freight shuttle to safety."
	if not foundry.powered: return "E · Power the hoist at the nearby amber control."
	if foundry.stage < 2: return "Ride the hoist up, then cross the upper catwalks."
	if foundry.stage < 3: return "Wait for steam to clear, then cross to the service island."
	return "Reach the freight aqueduct beyond the foundry."

func update_status() -> void:
	var text: String = CHAPTERS[maxi(chapter, 0)] + "\n" + objective_text(lab.player.position.x)
	if lab.combat.notice_time > 0:
		text = lab.combat.notice
	elif elapsed < 8:
		text += "\nA/D move · Space jump · J/K wrench · Esc pause & controls"
	if lab.status.text != text:
		lab.status.text = text
		lab.status.reset_size()

func _draw() -> void:
	for i in CACHE_POSITIONS.size():
		if caches[i]: continue
		var at: Vector2 = CACHE_POSITIONS[i]+Vector2(0,sin(time*2)*3)
		draw_circle(at,22,Color("e6c66d",0.07))
		draw_arc(at,15,time*0.3,time*0.3+TAU,32,Color("d6b568"),2,true)
		for j in 8:
			var d := Vector2.from_angle(j*TAU/8+time*0.3)
			draw_line(at+d*13,at+d*19,Color("d6b568"),5,true)
		draw_circle(at,8,Color("294939"))
		draw_circle(at,4,Color("b8d0a1"))
