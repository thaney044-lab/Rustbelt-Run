extends Node2D

var lab: Node2D
var patrol_left := 330.0
var patrol_right := 485.0
var direction := 1.0
var alive := true
var age := 0.0
var home := Vector2.ZERO
var art: Texture2D
var sprite_region := Rect2()

func _ready() -> void:
	home = position
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

func reset() -> void:
	alive = true
	position = home
	direction = 1.0
	age = 0
	queue_redraw()

func defeat() -> void:
	if not alive:
		return
	alive = false
	age = 0
	lab.effects.burst(position,Color("e6c27e"),12)
	queue_redraw()

func contact_player(player: CharacterBody2D) -> void:
	if not alive or not Rect2(position-Vector2(18,17),Vector2(36,37)).intersects(Rect2(player.position-Vector2(13,20),Vector2(26,40))):
		return
	if player.velocity.y > 0 and player.position.y < position.y-19:
		defeat()
		player.velocity.y = -350
		lab.combat.show_notice("STOMP!  /  Patrol bot disabled.")
	else:
		if player.take_damage(position.x):
			lab.combat.show_notice("HIT!  /  J swings the wrench; jump onto the bot's flat top.")

func _physics_process(delta: float) -> void:
	age += delta
	if alive:
		position.x = clampf(position.x+direction*48*delta,patrol_left,patrol_right)
		if position.x >= patrol_right:
			direction = -1
		elif position.x <= patrol_left:
			direction = 1
		contact_player(lab.player)
	queue_redraw()

func _draw() -> void:
	if not alive and age > 0.6:
		return
	var alpha := 1.0 if alive else maxf(0.0,1.0-age/0.6)
	draw_set_transform(Vector2(0,18),0,Vector2(1,0.22))
	draw_circle(Vector2.ZERO,19,Color(0.02,0.07,0.08,0.3*alpha))
	draw_set_transform(Vector2(0,sin(age*11)*0.6),0 if alive else age*1.5,Vector2(direction,1))
	if art:
		draw_texture_rect_region(art,Rect2(-25,-16.6,50,36.6),sprite_region,Color(1,1,1,alpha))
	else:
		draw_rect(Rect2(-18,-16,36,29),Color("497773"))
		for x in [-12,12]:
			draw_circle(Vector2(x,14),7,Color("20383a"))
		draw_circle(Vector2(9,-4),5,Color("e7b35e"))
	draw_set_transform(Vector2.ZERO)
	if alive and lab.player.position.distance_to(position) < 250 and (position.x-lab.player.position.x)*lab.player.facing > 0:
		draw_arc(position,29,0,TAU,28,Color("edcf8b",0.7),1.5,true)
