extends "res://scripts/movement_lab.gd"
@export_enum("Mosswater Relay:1", "Emberline Summit:2", "Stormglass Viaduct:3", "Nightfall Dispatch:4") var mission_id := 1
var data: Dictionary
var relay_on: Array[bool] = []
var checkpoint_index := -1
var time := 0.0
var exit_shape: CollisionShape2D
var movers: Array[AnimatableBody2D] = []
var moving_specs: Array = []
var moving_elapsed: Array[float] = []

func _ready() -> void:
	data = preload("res://scripts/mission_data.gd").get_level(mission_id)
	configure_input()
	effects = preload("res://scripts/visual_effects.gd").new()
	add_child(effects)
	for spec in data.platforms:
		if spec.size() == 4:
			platform(Vector2(spec[0],spec[1]),Vector2(spec[2],spec[3]))
		else:
			platform(Vector2(spec[0],spec[1]),Vector2(spec[2],spec[3]),true,spec[6],spec[5])
			var body: AnimatableBody2D = get_child(get_child_count()-1)
			body.set_physics_process(false)
			movers.append(body)
			moving_specs.append(spec)
			moving_elapsed.append(0.0)
	var last: Array = data.platforms[-1]
	var gate := StaticBody2D.new()
	gate.position = Vector2(data.goal+60,last[1]-last[3]/2.0-55)
	exit_shape = CollisionShape2D.new()
	var gate_rect := RectangleShape2D.new()
	gate_rect.size = Vector2(18,110)
	exit_shape.shape = gate_rect
	gate.add_child(exit_shape)
	add_child(gate)
	label_at("POWERED EXIT",Vector2(data.goal-65,last[1]-last[3]/2.0-150))
	player = Player.new()
	player.position = Vector2(100,490)
	player.z_index = 1
	add_child(player)
	player.respawned.connect(func(): time = 0.0)
	var camera := Camera2D.new()
	camera.position = Vector2(180,-80)
	camera.limit_left = 0
	camera.limit_right = data.end
	camera.limit_top = 0
	camera.limit_bottom = 720
	player.add_child(camera)
	var hud := CanvasLayer.new()
	hud.layer = 5
	add_child(hud)
	status = Label.new()
	status.position = Vector2(24,22)
	status.add_theme_font_size_override("font_size",17)
	var backing := StyleBoxFlat.new()
	backing.bg_color = Color("142b30",0.94)
	backing.border_color = Color("bba270")
	backing.border_width_left = 2
	backing.content_margin_left = 14
	backing.content_margin_right = 14
	backing.content_margin_top = 9
	backing.content_margin_bottom = 9
	backing.set_corner_radius_all(3)
	status.add_theme_stylebox_override("normal",backing)
	hud.add_child(status)
	var fullscreen := Button.new()
	fullscreen.text = "FULLSCREEN"
	fullscreen.position = Vector2(1000,22)
	fullscreen.focus_mode = Control.FOCUS_NONE
	fullscreen.add_theme_stylebox_override("normal",backing)
	fullscreen.pressed.connect(func():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
	)
	hud.add_child(fullscreen)
	combat = preload("res://scripts/gameplay.gd").new()
	combat.lab = self
	combat.authored_layout = false
	add_child(combat)
	for index in data.bots:
		var spec: Array = data.platforms[index]
		combat.spawn_patrol(Vector2(spec[0],spec[1]-spec[3]/2.0-21),spec[0]-spec[2]/2.0+40,spec[0]+spec[2]/2.0-40)
		combat.enemies[-1].patrol_speed = data.patrol_speed
	for index in range(1,data.platforms.size()):
		var spec: Array = data.platforms[index]
		for offset in ([-45,0,45] if spec[3] > 30 else [0]):
			combat.scrap_positions.append(Vector2(spec[0]+offset,spec[1]-spec[3]/2.0-32))
			combat.collected.append(false)
	var vitals := preload("res://scripts/vitals_hud.gd").new()
	vitals.lab = self
	hud.add_child(vitals)
	for at in data.relays:
		relay_on.append(false)
		label_at("E / " + ("RESTORE " + control_name().to_upper()),at+Vector2(-65,-105))
	label_at("RESTORE POWER TO RUN THE MACHINERY",Vector2(1180,280))
	label_at("AMBER WARNS / CROSS WHEN CLEAR",Vector2(data.platforms[data.hazards[0]][0]-180,260))
	var background := CanvasLayer.new()
	background.layer = -10
	var scenery := preload("res://scripts/mission_scenery.gd").new()
	scenery.lab = self
	scenery.mission_id = mission_id
	background.add_child(scenery)
	add_child(background)
	director = preload("res://scripts/mission_director.gd").new()
	director.lab = self
	director.mission_id = mission_id
	add_child(director)
	queue_redraw()

func interact_relay() -> bool:
	for index in data.relays.size():
		if not relay_on[index] and player.position.distance_to(data.relays[index]) < 65:
			relay_on[index] = true
			if relay_count() == relay_on.size(): exit_shape.set_deferred("disabled",true)
			effects.celebrate(data.relays[index],Color("a9e1b3"),data.get("online","PUMP ONLINE" if mission_id == 1 else "BREAKER ONLINE"))
			director.message("Power restored · %d/%d online" % [relay_count(),relay_on.size()])
			return true
	return false

func control_name() -> String:
	return data.get("control","pump" if mission_id == 1 else "breaker")

func relay_count() -> int:
	return relay_on.count(true)

func hazard_phase(index: int) -> float:
	return fposmod(time+index*float(data.get("phase_offset",1.7)),float(data.get("period",5.2)))

func hazard_live(index: int) -> bool:
	var phase := hazard_phase(index)
	return phase >= 2.3 and phase < 2.3 + float(data.active_duration)

func hazard_rect(index: int) -> Rect2:
	var spec: Array = data.platforms[data.hazards[index]]
	return Rect2(spec[0]-24,spec[1]-spec[3]/2.0-110,48,112)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(director): return
	if director.complete: return
	time += delta
	for index in movers.size():
		var spec: Array = moving_specs[index]
		var needed := 1
		for relay in data.relays.size():
			if spec[0] > data.relays[relay].x: needed = relay+1
		if relay_on[needed-1]:
			moving_elapsed[index] += delta
		var offset := sin(moving_elapsed[index]*spec[6])*float(spec[5])
		movers[index].position = Vector2(spec[0],spec[1])+ (Vector2(offset,0) if spec[4] == "x" else (Vector2(offset,offset*0.65) if spec[4] == "xy" else Vector2(0,offset)))
	if Input.is_action_just_pressed("interact"): interact_relay()
	if player.is_on_floor():
		for i in data.checks.size():
			var spec: Array = data.platforms[data.checks[i]]
			if i > checkpoint_index and absf(player.position.x-spec[0]) < spec[2]/2.0-20 and absf(player.position.y-(spec[1]-spec[3]/2.0-20)) < 5:
				checkpoint_index = i
				player.set_checkpoint(Vector2(spec[0],spec[1]-spec[3]/2.0-20))
	var player_rect := Rect2(player.position-Vector2(13,20),Vector2(26,40))
	for index in data.hazards.size():
		if hazard_live(index) and hazard_rect(index).intersects(player_rect):
			player.respawn()
			break
	queue_redraw()

func _draw() -> void:
	if data.is_empty(): return
	var metal := Color("38534a") if mission_id == 1 else Color("514638")
	if mission_id >= 3: metal = Color("39465b")
	for index in data.platforms.size():
		var spec: Array = data.platforms[index]
		var top: float = spec[1]-spec[3]/2.0
		if index % 2 == 0 and spec.size() == 4:
			for side in [-1,1]:
				var x: float = spec[0]+side*(spec[2]/2.0-12)
				draw_line(Vector2(x,top+spec[3]),Vector2(x,720),metal,4,true)
		if index in data.checks:
			var base := Vector2(spec[0]-spec[2]/2.0+24,top)
			draw_line(base,base-Vector2(0,58),Color("ceb886"),3,true)
			draw_colored_polygon(PackedVector2Array([base-Vector2(0,58),base+Vector2(26,-48),base-Vector2(0,38)]),Color("8fb799"))
	for index in data.relays.size():
		var at: Vector2 = data.relays[index]
		var color := Color("a4dbaf") if relay_on[index] else Color("e4b65b")
		draw_style_box(panel(metal),Rect2(at-Vector2(20,25),Vector2(40,56)))
		draw_circle(at,12,Color("142c2c"))
		draw_arc(at,9,-PI*0.7,PI*0.7,20,color,2,true)
		draw_line(at,at+Vector2(6,-6) if relay_on[index] else at+Vector2(-6,6),color,2,true)
		for i in 3:
			draw_rect(Rect2(at+Vector2(-12+i*9,18),Vector2(6,4)),color if relay_on[index] else Color("5c6551"))
		if not relay_on[index] and is_instance_valid(player) and player.position.distance_to(at) < 65:
			draw_arc(at,27,0,TAU,32,color,1.5,true)
	for index in data.hazards.size():
		var r := hazard_rect(index)
		var phase := hazard_phase(index)
		var warning := phase >= 1.4 and phase < 2.3
		var lamp := Vector2(r.position.x-10,r.end.y-20)
		draw_circle(lamp,7,Color("e18d62") if hazard_live(index) else (Color("f3c66e") if warning else Color("8bbc9b")))
		if warning:
			draw_line(lamp-Vector2(0,4),lamp+Vector2(0,1),Color("182e2a"),2,true)
			draw_circle(lamp+Vector2(0,4),1,Color("182e2a"))
		if mission_id == 1:
			draw_rect(Rect2(r.position.x-5,r.end.y-2,58,8),metal)
			if hazard_live(index):
				for j in 8:
					var rise := fposmod(time*120+j*14,110)
					draw_circle(Vector2(r.get_center().x+sin(time*7+j)*7,r.end.y-rise),7+rise*0.05,Color(0.56,0.82,0.85,(1-rise/130)*0.55))
		elif mission_id >= 3:
			draw_rect(Rect2(r.position.x-6,r.end.y-2,60,8),metal)
			if hazard_live(index):
				var energy := Color("a2dfed") if mission_id == 3 else Color("efa8b0")
				if mission_id == 3:
					var bolt := PackedVector2Array()
					for j in 10:
						bolt.append(Vector2(r.get_center().x+sin(time*45+j*3.1)*12,r.end.y-j*12))
					draw_polyline(bolt,Color(energy,0.2),9,true)
					draw_polyline(bolt,energy,2,true)
				else:
					draw_rect(r,Color(energy,0.12))
					var scan_x := r.get_center().x + sin(time*5)*16
					draw_line(Vector2(scan_x,r.position.y),Vector2(scan_x,r.end.y),energy,3,true)
		else:
			var press := 1.0 if hazard_live(index) else smoothstep(2.1,2.3,phase) if warning else 0.0
			var head_y := lerpf(r.position.y-20,r.end.y-10,press)
			draw_line(Vector2(r.get_center().x,165),Vector2(r.get_center().x,head_y),metal,14,true)
			draw_rect(Rect2(r.position.x-12,head_y,72,14),Color("94794e"))
			for dx in [0,18,36]:
				draw_line(Vector2(r.position.x+dx-8,head_y+3),Vector2(r.position.x+dx,head_y+11),Color("e4b965"),4,true)
	var final_bank: Array = data.platforms[-1]
	var goal := Vector2(data.goal,final_bank[1]-final_bank[3]/2.0-32)
	var ready := relay_count() == relay_on.size()
	if not ready:
		var shutter := Rect2(goal+Vector2(51,-78),Vector2(18,110))
		draw_rect(shutter,Color("30433a"))
		for y in range(int(shutter.position.y+5),int(shutter.end.y-4),14):
			draw_line(Vector2(shutter.position.x+3,y),Vector2(shutter.end.x-3,y+8),Color("d7ab5f"),3,true)
	draw_arc(goal,46,PI,TAU,32,Color("b3dfb4") if ready else Color("bd9f64"),5,true)
	draw_line(goal-Vector2(46,0),goal-Vector2(46,-32),metal,6,true)
	draw_line(goal+Vector2(46,0),goal+Vector2(46,32),metal,6,true)
	if mission_id == 2:
		draw_line(goal+Vector2(80,30),goal+Vector2(80,-255),metal,10,true)
		draw_circle(goal+Vector2(80,-255),16,Color("f8d388") if ready else metal)

	if mission_id == 3:
		draw_line(goal+Vector2(76,25),goal+Vector2(76,-170),metal,8,true)
		draw_arc(goal+Vector2(76,-170),14,0,TAU,24,Color("9fd7e9") if ready else Color("a29676"),3,true)
	if mission_id == 4:
		draw_line(goal+Vector2(78,30),goal+Vector2(78,-155),metal,8,true)
		draw_rect(Rect2(goal+Vector2(64,-158),Vector2(28,80)),Color("14232f"))
		for i in 3:
			draw_circle(goal+Vector2(78,-145+i*24),7,Color("a1d5b3") if i < relay_count() else Color("c18a70"))

func panel(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("b8a475")
	style.set_border_width_all(2)
	style.set_corner_radius_all(3)
	return style
