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

func celebrate(at: Vector2, color: Color, caption: String) -> void:
	burst(at, color, 8)
	particles.append({"pos": at, "vel": Vector2.ZERO, "age": 0.0, "color": color, "life": 0.55, "kind": "ring"})
	particles.append({"pos": at + Vector2(0, -24), "vel": Vector2(0, -24), "age": 0.0, "color": color, "life": 0.9, "kind": "caption", "text": caption})
	set_process(true)

func robot_breakup(at: Vector2, facing: float) -> void:
	burst(at, Color("ffda86"), 18)
	for i in 9:
		var angle := -PI + (i + 0.5) * PI / 9
		particles.append({"pos": at, "vel": Vector2.from_angle(angle) * (80 + i % 3 * 35) + Vector2(facing * 20, -30), "age": 0.0, "color": Color("cbad72") if i % 2 else Color("617e74"), "life": 0.85, "kind": "metal", "spin": float(i * 2 + 1)})
	for i in 5:
		particles.append({"pos": at + Vector2(i * 5 - 10, 0), "vel": Vector2((i - 2) * 12, -25 - i * 4), "age": 0.0, "color": Color("9da998", 0.45), "life": 1.0, "kind": "smoke"})
	set_process(true)

func _process(delta: float) -> void:
	for p in particles:
		p.age += delta
		p.pos += p.vel*delta
		p.vel.y += (0 if p.get("kind", "") in ["caption", "ring"] else (-8 if p.get("kind", "") == "smoke" else (320 if p.get("kind", "") == "metal" else 100))) * delta
	particles = particles.filter(func(p):return p.age < p.get("life", 0.5))
	queue_redraw()
	if particles.is_empty():
		set_process(false)

func _draw() -> void:
	for p in particles:
		var color: Color = p.color
		color.a *= 1.0 - p.age / p.get("life", 0.5)
		if p.get("kind", "") == "caption":
			var font := ThemeDB.fallback_font
			var width := font.get_string_size(p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
			var at: Vector2 = p.pos - Vector2(width * 0.5, 0)
			draw_string_outline(font, at, p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, 3, Color(0.05, 0.12, 0.12, color.a))
			draw_string(font, at, p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)
		elif p.get("kind", "") == "ring":
			draw_arc(p.pos, 8 + p.age * 55, 0, TAU, 32, color, 1.5, true)
		elif p.get("kind", "") == "smoke":
			draw_circle(p.pos, 4 + p.age * 17, color)
		elif p.get("kind", "") == "metal":
			draw_set_transform(p.pos, p.age * p.spin)
			draw_rect(Rect2(-3, -2, 6, 4), color)
			draw_line(Vector2(-3, -2), Vector2(3, -2), Color(1, 0.9, 0.65, color.a), 1, true)
			draw_set_transform(Vector2.ZERO)
		else:
			draw_line(p.pos,p.pos-p.vel*0.035,color,1.5,true)
