extends Node2D

const METAL = preload("res://assets/art/painted/weathered_steel.png")

var size := Vector2(100, 20)
var moving := false
var surface_kind := "steel"
var base_color := Color("3b5152")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

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
	draw_rect(Rect2(r.position+Vector2(1,4),size),Color(0.02,0.06,0.07,0.3))
	draw_style_box(box(base_color, Color("1d3035"), 3), r)
	for i in range(int(ceil(size.x/96.0))):
		var width := minf(96,size.x-i*96)
		var region := Rect2(64+(i%6)*130,64,width*3,size.y*3)
		var destination := Rect2(r.position+Vector2(i*96,0),Vector2(width,size.y))
		draw_texture_rect_region(METAL,destination,region,Color(0.68,0.79,0.75))
		if size.y > 30:
			draw_line(destination.position+Vector2(0,15),destination.position+Vector2(0,size.y-2),Color("152c30"),2)
	# Heavy iron top rail with a thin sunlit bevel, and deep lower lip.
	draw_rect(Rect2(r.position,Vector2(size.x,5)),Color("899681"))
	draw_rect(Rect2(r.position+Vector2(0,size.y-7),Vector2(size.x,7)),Color("192f32"))
	# Recessed metal panels, small scratches and rust stains add material depth.
	for band in range(1, int(size.y), 4):
		var shade := 0.04 + float(band)/maxf(size.y,1.0)*0.08
		draw_rect(Rect2(r.position+Vector2(3,band),Vector2(size.x-6,3)),Color(0.06,0.12,0.13,shade))
	for i in range(int(size.x/19)):
		var x := r.position.x+7+i*19
		var y := r.position.y+9+fposmod(i*17.0,maxf(4,size.y-16))
		draw_line(Vector2(x,y),Vector2(minf(x+8,r.end.x-3),y+2),Color("b6ad85",0.16),1)
		if i%3 == 0:
			draw_circle(Vector2(x,y),2.5,Color("a16d45",0.25))
	draw_rect(Rect2(r.position + Vector2(0, 8), Vector2(size.x, 5)), Color("283d40"))
	if size.y > 30:
		for x in range(int(r.position.x + 10), int(r.end.x-26), 40):
			draw_line(Vector2(x, r.position.y+22), Vector2(x+26, r.end.y-6), Color("233b3c",0.65), 2)
			draw_line(Vector2(x+26, r.position.y+22), Vector2(x, r.end.y-6), Color("233b3c",0.65), 2)
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

	if not moving and surface_kind == "steel":
		for i in range(int(size.x/55)):
			var root := Vector2(r.position.x+16+i*55,r.position.y+1)
			var height := 7.0+fposmod(i*13.0,10.0)
			draw_circle(root+Vector2(0,2),5,Color("405d3f"))
			for j in 4:
				var at := root+Vector2(j*1.3,-j*height/4)
				leaf(at,Vector2(-6-j,-3-j),Color("648254"))
				leaf(at,Vector2(5+j,-5-j),Color("83a15f"))
			draw_line(root,root+Vector2(4,-height),Color("b4bd7c"),1,true)
		if size.y > 35:
			for i in range(int(size.x/140)):
				var root := r.position+Vector2(34+i*140,5)
				for j in 6:
					var at := root+Vector2(sin(j*1.2)*5,j*7)
					draw_line(at,at+Vector2(1,9),Color("385e46"),2)
					leaf(at,Vector2(-7,-2),Color("466e4c"))
					leaf(at+Vector2(0,4),Vector2(7,1),Color("6b8c50"))

func leaf(at: Vector2, direction: Vector2, color: Color) -> void:
	var side := Vector2(-direction.y,direction.x).normalized()*2.5
	var mid := at+direction*0.5
	draw_colored_polygon(PackedVector2Array([at,mid+side,at+direction,mid-side]),color)

func box(fill: Color, edge: Color, border: int) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = fill
	b.border_color = edge
	b.set_border_width_all(border)
	b.set_corner_radius_all(2)
	return b
