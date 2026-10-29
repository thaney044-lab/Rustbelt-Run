extends Node2D

var size := Vector2(100, 20)
var moving := false
var surface_kind := "steel"
var base_color := Color("3b5152")

func _draw() -> void:
	var r := Rect2(-size / 2, size)
	if surface_kind == "crate":
		draw_style_box(box(Color("8b5137"), Color("302e2b"), 3), r)
		for x in [-13, 0, 13]:
			draw_line(Vector2(x, r.position.y + 3), Vector2(x, r.end.y - 3), Color("b5794e"), 2)
		draw_line(r.position + Vector2(5, 5), r.end - Vector2(5, 5), Color("e0a66c"), 5)
		draw_line(Vector2(r.end.x-5, r.position.y+5), Vector2(r.position.x+5, r.end.y-5), Color("e0a66c"), 5)
		return
	if surface_kind == "gate":
		draw_style_box(box(Color("25383b"), Color("18282b"), 3), r)
		for y in range(int(r.position.y + 5), int(r.end.y), 15):
			draw_line(Vector2(-7, y), Vector2(7, y+8), Color("d39450"), 6)
		draw_rect(Rect2(-size.x/2-3, r.position.y, size.x+6, 7), Color("e6c77c"))
		return
	draw_style_box(box(base_color, Color("1d3035"), 3), r)
	draw_rect(Rect2(r.position + Vector2(0, 8), Vector2(size.x, 5)), Color("283d40"))
	if size.y > 30:
		for x in range(int(r.position.x + 10), int(r.end.x-26), 40):
			draw_line(Vector2(x, r.position.y+22), Vector2(x+26, r.end.y-6), Color("304447"), 3)
			draw_line(Vector2(x+26, r.position.y+22), Vector2(x, r.end.y-6), Color("304447"), 3)
	var trim := Color("e7b958") if moving else Color("9bac8e")
	draw_rect(Rect2(r.position, Vector2(size.x, 6)), trim)
	draw_line(r.position, Vector2(r.end.x, r.position.y), Color("f3d9a1") if moving else Color("ccd3aa"), 2)
	for x in range(int(r.position.x + 10), int(r.end.x - 4), 30):
		draw_circle(Vector2(x, r.position.y+15), 2.0, Color("b8b6a0"))
	if moving:
		for x in range(int(r.position.x+5), int(r.end.x-10), 22):
			draw_line(Vector2(x, r.position.y+6), Vector2(x+8, r.position.y+13), Color("685536"), 4)
	else:
		for x in range(int(r.position.x+5), int(r.end.x-4), 23):
			var h := 4.0 + fposmod(float(x*x), 8.0)
			draw_line(Vector2(x,r.position.y), Vector2(x+2,r.position.y-h), Color("80a27c"), 2)
			draw_line(Vector2(x+3,r.position.y), Vector2(x+7,r.position.y-h*.7), Color("527a66"), 2)
		if size.y > 35:
			for i in 3:
				var at := Vector2(r.position.x + 13 + i*17, r.position.y + 10 + i*11)
				draw_line(at, at+Vector2(0,15), Color("497563"), 2)
				draw_circle(at+Vector2(4,7), 4, Color("62866a"))

func box(fill: Color, edge: Color, border: int) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = fill
	b.border_color = edge
	b.set_border_width_all(border)
	b.set_corner_radius_all(2)
	return b
