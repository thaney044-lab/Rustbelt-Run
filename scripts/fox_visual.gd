extends Node2D

# Each pose uses the same source-pixel scale and a shared hip/boot anchor.
# The untouched source sheet is retained alongside its generation provenance.
const SHEET = preload("res://assets/art/painted/fox_animations.png")
const SCALE := 0.215
const ANCHOR_X := 270.0
const BOOT_Y := [477.0,466.0,472.0,468.0,420.0,323.0,410.0,418.0]
const REGIONS := [Rect2(44,135,324,342),Rect2(394,146,351,320),Rect2(774,147,322,325),Rect2(1140,148,357,320),Rect2(33,613,330,319),Rect2(485,560,260,367),Rect2(779,635,365,287),Rect2(1161,608,349,322)]
var player: CharacterBody2D
var frame := 0
var time := 0.0
var action_time := 0.0

func _ready() -> void:
	player = get_parent()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

func _process(delta: float) -> void:
	time += delta
	action_time = maxf(0.0,action_time-delta)
	if Input.is_action_just_pressed("swing"):
		action_time = 0.22
	if action_time > 0:
		frame = 7
	elif not player.is_on_floor():
		frame = 5 if player.velocity.y < -40 else 6
	elif absf(player.velocity.x) > 25:
		frame = [1,2,3,4][int(time*10)%4]
	else:
		frame = 0
	queue_redraw()

func _draw() -> void:
	if not player:
		return
	var bob := sin(time*2.6)*0.6 if frame == 0 else 0.0
	draw_set_transform(Vector2(0,bob),0,Vector2(player.facing,1))
	var source: Rect2 = REGIONS[frame]
	var cell_origin := Vector2((frame%4)*384,(frame/4 as int)*512)
	var destination := Rect2((source.position-cell_origin-Vector2(ANCHOR_X,BOOT_Y[frame]))*SCALE+Vector2(0,20),source.size*SCALE)
	draw_texture_rect_region(SHEET,destination,source)
	draw_set_transform(Vector2.ZERO)
