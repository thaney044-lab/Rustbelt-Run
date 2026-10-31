extends Node2D
## Two final districts, with safe banks separating traversal challenges.
var lab: Node2D
var checkpoint_stage := 0
const END_X := 12870.0
const WORLD_END := 13060
const BANKS := [Vector2(8680,460), Vector2(10080,430), Vector2(11300,490), Vector2(12040,430)]

func _ready() -> void:
	# The former workshop bank now opens onto a freight aqueduct.
	lab.platform(Vector2(9000,460),Vector2(120,20))
	lab.platform(Vector2(9200,400),Vector2(140,20))
	lab.platform(Vector2(9440,500),Vector2(300,80))
	lab.platform(Vector2(9780,430),Vector2(140,20),true,1.1,60)
	lab.platform(Vector2(10080,500),Vector2(240,80))
	lab.platform(Vector2(10340,400),Vector2(140,20))
	lab.platform(Vector2(10560,350),Vector2(140,20))
	lab.platform(Vector2(10800,430),Vector2(260,80))
	lab.platform(Vector2(11070,450),Vector2(140,20))
	lab.platform(Vector2(11300,560),Vector2(320,80))
	lab.platform(Vector2(11580,470),Vector2(120,20))
	lab.platform(Vector2(11800,420),Vector2(140,20),true,1.25,50)
	lab.platform(Vector2(12040,500),Vector2(240,80))
	lab.platform(Vector2(12280,420),Vector2(140,20))
	lab.platform(Vector2(12510,380),Vector2(140,20))
	lab.platform(Vector2(12830,530),Vector2(420,80))
	lab.combat.spawn_patrol(Vector2(9440,439),9340,9530)
	lab.combat.spawn_patrol(Vector2(10800,369),10730,10880)
	lab.combat.spawn_patrol(Vector2(11300,499),11220,11390)
	for at in [Vector2(8830,450),Vector2(9000,420),Vector2(9200,360),Vector2(9370,430),Vector2(9510,430),Vector2(9780,390),Vector2(10020,430),Vector2(10160,430),Vector2(10340,360),Vector2(10560,310),Vector2(10760,350),Vector2(10870,350),Vector2(11070,410),Vector2(11250,480),Vector2(11400,480),Vector2(11580,430),Vector2(11800,380),Vector2(12040,420),Vector2(12280,380),Vector2(12510,340),Vector2(12700,450),Vector2(12900,450)]:
		lab.combat.scrap_positions.append(at)
		lab.combat.collected.append(false)
	z_index = -2

func _physics_process(_delta: float) -> void:
	var player: CharacterBody2D = lab.player
	if not player.is_on_floor(): return
	for i in BANKS.size():
		if i >= checkpoint_stage and absf(player.position.x - BANKS[i].x) < 75 and absf(player.position.y - BANKS[i].y) < 25:
			checkpoint_stage = i + 1
			player.set_checkpoint(BANKS[i])

func _draw() -> void:
	for at in BANKS:
		var base: Vector2 = at+Vector2(-60,30)
		draw_line(base,base-Vector2(0,62),Color("cbbb8d"),3,true)
		draw_colored_polygon(PackedVector2Array([base-Vector2(0,62),base+Vector2(28,-53),base-Vector2(0,43)]),Color("8cb48b"))
