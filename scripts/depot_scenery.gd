extends Node2D

var lab: Node2D
var camera: Camera2D
var time := 0.0
var living: Node2D
const FOUNDRY = preload("res://assets/art/painted/foundry_panorama.png")
const PANORAMA = preload("res://assets/art/painted/depot_panorama.png")

func _ready() -> void:
	var surface := ShaderMaterial.new()
	surface.shader = preload("res://shaders/living_panorama.gdshader")
	material = surface
	living = preload("res://scripts/living_background.gd").new()
	add_child(living)

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(lab.player):
		return
	if not camera:
		camera = get_viewport().get_camera_2d()
	if not camera:
		return
	var scroll := camera.get_screen_center_position().x - 576.0
	living.scroll = scroll
	# An oversized panorama has sufficient bleed for the entire level's slow parallax.
	draw_texture_rect(PANORAMA,Rect2(-20-scroll*0.065,-22,1640,703),false,Color(0.76,0.82,0.80))
	var transition := smoothstep(3400.0,4100.0,lab.player.position.x)
	var foundry_scroll := clampf((lab.player.position.x-3000.0)*0.18,0,450)
	draw_texture_rect(FOUNDRY,Rect2(-40-foundry_scroll,-5,1880,687),false,Color(0.79,0.82,0.83,transition))
	# Low mist sits behind the playable layer, never obscuring hazards or targets.
	for i in 8:
		var y := 380+i*12.0+sin(time*0.15+i)*4
		draw_rect(Rect2(-20,y,1200,24),Color(0.45,0.64,0.64,transition*0.013))
	# Atmospheric shadow separates the bright readable playfield from distant detail.
	for i in 18:
		draw_rect(Rect2(0,320+i*20,1152,20),Color(0.04,0.12,0.14,float(i)*0.016))
	# Fine cables and near girders travel faster than the painting, providing depth.
	for i in range(-1,9):
		var x := i*360.0-fposmod(scroll*0.35,360.0)
		draw_line(Vector2(x,540),Vector2(x,690),Color("1c3538",0.65),9)
		draw_line(Vector2(x,552),Vector2(x+90,640),Color("20393a",0.55),5)
	# A few distant birds, rather than a constantly moving screen overlay.
	for i in 3:
		var at := Vector2(fposmod(time*6+i*180,1400)-120,110+sin(time*.3+i)*12)
		var wing := sin(time*3+i)*3
		draw_polyline(PackedVector2Array([at+Vector2(-5,wing),at,at+Vector2(5,wing)]),Color("354c4c",0.4),1,true)
