extends Node2D

var time := 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	# Extremely restrained sun shafts and drifting motes, above art but below HUD.
	for i in 3:
		var x := 830+i*120.0
		draw_colored_polygon(PackedVector2Array([Vector2(x,-50),Vector2(x+50,-50),Vector2(x-420,660),Vector2(x-510,660)]),Color(1.0,0.84,0.56,0.017))
	for i in 18:
		var x := fposmod(i*179.0+sin(time*.14+i)*24,1152)
		var y := fposmod(i*71.0-time*(2.0+i%3),620)
		draw_circle(Vector2(x,y),0.7+float(i%2)*0.45,Color(1.0,0.88,0.63,0.18))
