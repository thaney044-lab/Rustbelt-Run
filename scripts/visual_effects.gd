extends Node2D

var particles: Array[Dictionary] = []

func _ready() -> void:
	z_index = 20
	set_process(false)

func burst(at: Vector2, color: Color, count := 10) -> void:
	for i in count:
		var angle := -PI + float(i)/maxf(count-1,1)*PI
		particles.append({"pos":at,"vel":Vector2.from_angle(angle)*(25+float(i%4)*18),"age":0.0,"color":color})
	set_process(true)

func _process(delta: float) -> void:
	for p in particles:
		p.age += delta
		p.pos += p.vel*delta
		p.vel.y += 100*delta
	particles = particles.filter(func(p):return p.age < 0.5)
	queue_redraw()
	if particles.is_empty():
		set_process(false)

func _draw() -> void:
	for p in particles:
		var color: Color = p.color
		color.a *= 1.0-p.age/0.5
		draw_line(p.pos,p.pos-p.vel*0.035,color,1.5,true)
