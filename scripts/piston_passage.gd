extends Node2D

var lab: Node2D
var time := 0.0
var checkpoint_active := false
var secret_found := false
var finished := false
var collected_flash := 0.0
const METAL = preload("res://assets/art/painted/weathered_steel.png")
const SECRET := Vector2(2860, 410)
const PISTONS := [3190.0, 3420.0, 3650.0]

func _ready() -> void:
	lab.platform(Vector2(3535,560),Vector2(1130,80))
	lab.platform(Vector2(2850,455),Vector2(100,18))
	lab.platform(Vector2(4190,560),Vector2(180,80))
	lab.label_at("MAINTENANCE LOFT",Vector2(2760,350))
	lab.label_at("PISTON PASSAGE  /  Watch the amber warning",Vector2(3010,270))
	lab.label_at("DEPOT EXIT",Vector2(3940,340))
	lab.player.respawned.connect(on_retry)

func on_retry() -> void:
	if checkpoint_active:
		time = 0.0
		finished = false

func phase(index: int) -> float:
	return fposmod(time + index * 1.0, 4.8)

func piston_bottom(index: int) -> float:
	var p := phase(index)
	if p < 2.0:
		return 350.0
	if p < 2.35:
		return lerpf(350.0,518.0,(p-2.0)/0.35)
	if p < 3.0:
		return 518.0
	return lerpf(518.0,350.0,minf((p-3.0)/0.9,1.0))

func hazard_rect(index: int) -> Rect2:
	return Rect2(PISTONS[index]-28,230,56,piston_bottom(index)-230)

func _physics_process(delta: float) -> void:
	time += delta
	collected_flash = maxf(0.0,collected_flash-delta)
	var player: CharacterBody2D = lab.player
	if player.position.x > 2780 and player.position.x < 2990 and player.is_on_floor() and not checkpoint_active:
		checkpoint_active = true
		player.set_checkpoint(Vector2(2780,490))
		time = 0
	if player.position.distance_to(SECRET) < 29 and not secret_found:
		secret_found = true
		collected_flash = 2.5
	if not checkpoint_active:
		queue_redraw()
		return
	var player_rect := Rect2(player.position-Vector2(13,20),Vector2(26,40))
	for i in 3:
		if hazard_rect(i).intersects(player_rect):
			player.respawn()
			break
	if player.position.x > 3990 and player.is_on_floor():
		finished = true
	if finished:
		lab.status.text = "DEPOT RESTORED  /  CONTINUE RIGHT TO THE SERVICE CANAL\n" + ("Rare machine part recovered." if secret_found else "A rare part is hidden in the maintenance loft.") + "  R: replay passage."
	elif collected_flash > 0:
		lab.status.text = "SECRET FOUND  /  RARE MACHINE PART\nStored for this play session. Continue through the piston passage."
	else:
		lab.status.text = "PISTON PASSAGE  /  CHECKPOINT ACTIVE\nAmber means descending soon. Wait for the piston to rise, then cross."
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2(2750,520),Vector2(2750,465),Color("d4bc88"),4)
	draw_colored_polygon(PackedVector2Array([Vector2(2752,466),Vector2(2785,472),Vector2(2752,485)]),Color("88bd9b"))
	# Industrial overhead frame; warm lamps communicate the cycle without color alone.
	draw_line(Vector2(3060,215),Vector2(3750,215),Color("243d41"),24)
	draw_line(Vector2(3060,205),Vector2(3750,205),Color("bc8d56"),5)
	for i in 3:
		var x: float = PISTONS[i]
		var bottom := piston_bottom(i)
		var p := phase(i)
		var warning := p > 1.3 and p < 2.35
		draw_rect(Rect2(x-9,225,18,bottom-250),Color("92aaa1"))
		draw_line(Vector2(x-5,225),Vector2(x-5,bottom-25),Color("dae0c3"),3)
		draw_rect(Rect2(x-29,bottom-28,58,28),Color("263c3f"))
		draw_texture_rect_region(METAL,Rect2(x-29,bottom-28,58,28),Rect2(120,150,174,84),Color(0.6,0.72,0.68))
		draw_rect(Rect2(x-27,bottom-25,54,19),Color("c9934d"))
		for offset in [-20,-5,10]:
			draw_line(Vector2(x+offset,bottom-23),Vector2(x+offset+12,bottom-9),Color("4f4b37"),5)
		draw_line(Vector2(x-30,bottom),Vector2(x+30,bottom),Color("f0d18d"),3)
		draw_circle(Vector2(x,190),9,Color("dc8869") if bottom > 450 else (Color("efb55b") if warning else Color("78a993")))
		if bottom > 450:
			draw_line(Vector2(x-4,190),Vector2(x+4,190),Color("263e40"),3)
		elif warning:
			draw_line(Vector2(x,184),Vector2(x,191),Color("263e40"),3)
			draw_circle(Vector2(x,195),1.5,Color("263e40"))
		for y in [545,559]:
			draw_line(Vector2(x-30,y),Vector2(x+30,y),Color("d8b669"),2)
	if not secret_found:
		var at := SECRET+Vector2(0,sin(time*2)*3)
		draw_arc(at,17,0,TAU,12,Color("d6b567"),3)
		for i in 8:
			var d := Vector2.from_angle(i*TAU/8)
			draw_line(at+d*15,at+d*22,Color("d6b567"),5)
		draw_circle(at,8,Color("2a4445"))
		draw_circle(at,3,Color("a8cfb3"))
	# Freight car and PATCH cameo: a clear destination beyond the hazards.
	draw_line(Vector2(3880,529),Vector2(4280,529),Color("203b3e"),6)
	for x in [3940,4100]:
		draw_circle(Vector2(x,507),20,Color("24383a"))
		draw_circle(Vector2(x,507),11,Color("b18858"))
	draw_rect(Rect2(3890,442,260,56),Color("89573c"))
	draw_texture_rect_region(METAL,Rect2(3890,442,260,56),Rect2(140,140,780,168),Color(1.05,0.7,0.45))
	draw_rect(Rect2(3890,442,260,8),Color("d3aa68"))
	for x in range(3900,4150,30):
		draw_line(Vector2(x,455),Vector2(x,488),Color("ae774d"),3)
	var bot := Vector2(4050,425)
	draw_circle(bot+Vector2(-12,9),9,Color("263e40"))
	draw_circle(bot+Vector2(12,9),9,Color("263e40"))
	draw_rect(Rect2(bot-Vector2(20,25),Vector2(40,30)),Color("b9a16c"))
	draw_rect(Rect2(bot-Vector2(15,20),Vector2(30,13)),Color("2d5153"))
	for dx in [-7,7]:
		draw_circle(bot+Vector2(dx,-14),3,Color("a8d6b2"))
	draw_line(bot+Vector2(0,-25),bot+Vector2(0,-37),Color("526c60"),3)
	draw_circle(bot+Vector2(0,-38),4,Color("e6b25e"))
	if finished:
		for i in 18:
			var at := Vector2(4010,350)+Vector2(sin(i*2.4)*95,cos(i*1.7)*45)
			draw_circle(at,2,Color("f0d694"))
