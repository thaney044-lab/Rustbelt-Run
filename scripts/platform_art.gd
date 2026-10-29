extends Node2D

const METAL = preload("res://assets/art/painted/weathered_steel.png")
const STONE = preload("res://assets/art/painted/viaduct_stone.png")
const DrawBatch = preload("res://scripts/draw_batch.gd")

var size := Vector2(100, 20)
var moving := false
var surface_kind := "steel"
var base_color := Color("3b5152")
var foliage: RefCounted
var stonework: RefCounted
var foliage_mesh: ArrayMesh
var stone_mesh: ArrayMesh

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

func _draw() -> void:
	foliage = DrawBatch.new()
	stonework = DrawBatch.new()
	var r := Rect2(-size / 2, size)
	if surface_kind == "crate":
		draw_crate(r)
		draw_foliage()
		return
	if surface_kind == "gate":
		draw_gate(r)
		draw_foliage()
		return
	if not moving and size.y > 35 and size.x > 100:
		draw_masonry(r)
		draw_foliage()
		return
	draw_catwalk(r)
	draw_foliage()

func draw_catwalk(r: Rect2) -> void:
	# All load-bearing detail stays below the exact collision top.
	draw_rect(Rect2(r.position + Vector2(0, 3), size), Color("102321", 0.65))
	draw_rect(r, Color("243c39"))
	draw_texture_rect_region(METAL, r, Rect2(120, 180, size.x * 3, size.y * 3), Color(0.72, 0.79, 0.72))
	var web_y := r.position.y + 7
	foliage.rect(Rect2(r.position.x + 3, web_y, size.x - 6, maxf(2, size.y - 11)), Color("172e2c", 0.8))
	for x in range(int(r.position.x + 5), int(r.end.x - 8), 28):
		var end_x := minf(x + 24, r.end.x - 4)
		foliage.line(Vector2(x, r.end.y - 3), Vector2(end_x, web_y), Color("698079"), 2, true)
		foliage.line(Vector2(x, web_y), Vector2(end_x, r.end.y - 3), Color("364f48"), 2, true)
	foliage.rect(Rect2(r.position.x, r.end.y - 3, size.x, 3), Color("142a29"))
	foliage.line(Vector2(r.position.x, r.end.y - 3), Vector2(r.end.x, r.end.y - 3), Color("839084"), 1, true)
	for x in range(int(r.position.x + 2), int(r.end.x - 2), 16):
		var width := minf(14, r.end.x - x - 1)
		foliage.rect(Rect2(x, r.position.y, width, 5), Color("9e8960"))
		foliage.line(Vector2(x, r.position.y + 1), Vector2(x + width, r.position.y + 1), Color("e2d2a3"), 1, true)
		foliage.line(Vector2(x + 2, r.position.y + 4), Vector2(x + width - 1, r.position.y + 4), Color("574c38"), 1)
	for side in [-1, 1]:
		var x: float = side * (size.x / 2 - 6)
		foliage.rect(Rect2(x - 3, web_y - 1, 6, size.y - 7), Color("57685b"))
		rivet(Vector2(x, web_y + 2))
		var reach := minf(36, size.x * 0.3)
		foliage.line(Vector2(x, r.end.y), Vector2(x - side * reach * 0.5, r.end.y + 12), Color("223a32"), 4, true)
		foliage.line(Vector2(x - side * reach * 0.5, r.end.y + 12), Vector2(x - side * reach, r.end.y), Color("7a8563"), 2, true)
	if moving:
		# Hazard stripes and paired lamps distinguish every moving deck.
		for x in range(int(r.position.x + 11), int(r.end.x - 13), 18):
			foliage.line(Vector2(x, web_y), Vector2(minf(x + 5, r.end.x - 10), web_y + 6), Color("e0b35c"), 3, true)
		for side in [-1, 1]:
			var lamp := Vector2(side * (size.x / 2 - 6), r.position.y + 3)
			foliage.circle(lamp, 4, Color("efbc65", 0.18))
			foliage.circle(lamp, 1.6, Color("fff0b6"))
	else:
		for i in range(int(size.x / 62)):
			var root := Vector2(r.position.x + 12 + i * 62, r.position.y + 5)
			for j in 4:
				var at := root + Vector2(sin(j) * 2, j * 6)
				leaf(at, Vector2(-5, -2), Color("557346"))
				leaf(at + Vector2(0, 2), Vector2(5, -1), Color("809455"))

func rivet(at: Vector2) -> void:
	foliage.circle(at + Vector2(0, 1), 2.0, Color("172c29"))
	foliage.circle(at, 1.2, Color("d1b783"))

func draw_crate(r: Rect2) -> void:
	draw_style_box(box(Color("714b33"), Color("252f29"), 2), r)
	for i in 4:
		var x := r.position.x + 3 + i * (size.x - 6) / 4
		var width := (size.x - 6) / 4 - 1
		foliage.rect(Rect2(x, r.position.y + 3, width, size.y - 6), Color("a7794e") if i % 2 == 0 else Color("8c623e"))
		for j in 3:
			foliage.line(Vector2(x + 2, r.position.y + 8 + j * 11), Vector2(x + width - 2, r.position.y + 11 + j * 11), Color("533e2b", 0.5), 1)
	for reverse in [false, true]:
		var start := Vector2(r.position.x + 5, r.end.y - 5 if reverse else r.position.y + 5)
		var end := Vector2(r.end.x - 5, r.position.y + 5 if reverse else r.end.y - 5)
		foliage.line(start + Vector2(0, 2), end + Vector2(0, 2), Color("493b2a"), 6, true)
		foliage.line(start, end, Color("c99b64"), 4, true)
	for y in [r.position.y + 4, r.end.y - 5]:
		foliage.rect(Rect2(r.position.x + 1, y - 2, size.x - 2, 5), Color("45594e"))
		for x in [r.position.x + 5, r.end.x - 5]:
			rivet(Vector2(x, y))

func draw_gate(r: Rect2) -> void:
	draw_style_box(box(Color("263b3a"), Color("132824"), 2), r)
	draw_texture_rect_region(METAL, r.grow(-2), Rect2(60, 80, (size.x - 4) * 3, (size.y - 4) * 3), Color(0.6, 0.7, 0.65))
	for y in range(int(r.position.y + 10), int(r.end.y - 10), 16):
		foliage.rect(Rect2(r.position.x + 4, y, size.x - 8, 10), Color("182e2c"))
		foliage.line(Vector2(r.position.x + 5, y + 1), Vector2(r.end.x - 5, y + 8), Color("d9a959"), 3, true)
	for x in [r.position.x + 2, r.end.x - 3]:
		foliage.line(Vector2(x, r.position.y), Vector2(x, r.end.y), Color("9d9f83"), 1)
	for y in [r.position.y + 4, r.end.y - 4]:
		foliage.rect(Rect2(r.position.x, y - 3, size.x, 6), Color("637367"))
		rivet(Vector2(0, y))
	foliage.circle(Vector2(0, r.position.y + 4), 2, Color("ffd283"))

func leaf(at: Vector2, direction: Vector2, color: Color) -> void:
	var side := Vector2(-direction.y,direction.x).normalized()*2.5
	var mid := at+direction*0.5
	foliage.quad(PackedVector2Array([at,mid+side,at+direction,mid-side]),color)

func draw_foliage() -> void:
	if foliage.vertices.is_empty(): return
	foliage_mesh = foliage.build()
	draw_mesh(foliage_mesh,null)

func box(fill: Color, edge: Color, border: int) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = fill
	b.border_color = edge
	b.set_border_width_all(border)
	b.set_corner_radius_all(2)
	return b

func draw_masonry(r: Rect2) -> void:
	# Painted stone at a consistent world scale; arches connect the deck to the valley.
	stone_rect(r)
	foliage.rect(Rect2(r.position+Vector2(0,size.y-10),Vector2(size.x,10)),Color("172e2b",0.35))
	var bays := maxi(1,int(round(size.x/260.0)))
	var span := size.x/bays
	var joints := PackedVector2Array()
	for i in bays:
		var left := r.position.x+i*span
		var center := Vector2(left+span/2,r.end.y+maxf(170,span/2+20))
		var radius := span/2-27
		stone_rect(Rect2(left,r.end.y,27,290))
		stone_rect(Rect2(left+span-27,r.end.y,27,290))
		# A continuous arch ring, rather than a solid rectangle over the opening.
		for j in 18:
			var a := PI+j*PI/18
			var b := PI+(j+1)*PI/18
			var points := PackedVector2Array([center+Vector2.from_angle(a)*radius,center+Vector2.from_angle(b)*radius,center+Vector2.from_angle(b)*(radius+32),center+Vector2.from_angle(a)*(radius+32)])
			stone_polygon(points)
			if j%2 == 0:
				joints.append_array(PackedVector2Array([points[0],points[3]]))
		# Fill the spandrel above the arch, leaving its interior transparent.
		for j in 18:
			var a := center+Vector2.from_angle(PI+j*PI/18)*(radius+31)
			var b := center+Vector2.from_angle(PI+(j+1)*PI/18)*(radius+31)
			stone_polygon(PackedVector2Array([Vector2(a.x,r.end.y),Vector2(b.x,r.end.y),b,a]))
		for edge in [left,left+span-27]:
			foliage.line(Vector2(edge+2,r.end.y),Vector2(edge+2,r.end.y+290),Color("b6ac85",0.25),2)
	stone_mesh = stonework.build()
	draw_mesh(stone_mesh,STONE)
	foliage.multiline(joints,Color("26352d",0.75),1,true)
	foliage.rect(Rect2(r.position,Vector2(size.x,7)),Color("374b44"))
	foliage.line(r.position,Vector2(r.end.x,r.position.y),Color("cec39c"),2)
	# Individual coping blocks make the landing edge readable over the painting.
	for x in range(int(r.position.x + 1), int(r.end.x - 1), 28):
		var width := minf(26, r.end.x - x - 1)
		foliage.rect(Rect2(x, r.position.y + 1, width, 5), Color("999a7d"))
		foliage.line(Vector2(x, r.position.y + 1), Vector2(x + width, r.position.y + 1), Color("ded2aa"), 1)
	for i in range(int(size.x/32)):
		var x := r.position.x+10+i*32
		foliage.line(Vector2(x,r.position.y+2),Vector2(x+14,r.position.y+2),Color("87947a"),1)
		if i%3 == 0:
			var at := Vector2(x,r.position.y+3)
			leaf(at,Vector2(-5,-2),Color("648454"))
			leaf(at,Vector2(6,-1),Color("88a364"))
			for j in 3:
				leaf(at+Vector2(2,j*8),Vector2(6,2),Color("59764b"))
	# Recessed drainage outlets and iron tie plates anchor the painted masonry.
	for i in range(int(size.x/155)):
		var at := r.position+Vector2(65+i*155,31)
		foliage.rect(Rect2(at-Vector2(12,9),Vector2(24,18)),Color("152d28",0.7))
		foliage.rect(Rect2(at-Vector2(10,8),Vector2(20,15)),Color("485345"))
		foliage.line(at+Vector2(-9,-7),at+Vector2(9,-7),Color("a59b72"),1)
		for dx in [-7,7]:
			foliage.circle(at+Vector2(dx,0),1.7,Color("c0aa78"))
		foliage.circle(at,4,Color("142a25"))
		foliage.line(at+Vector2(0,5),at+Vector2(2,24),Color("273c2d",0.5),3)
	# Subtle face shading sits under the coping without hiding stone grain.
	for band in 5:
		foliage.rect(Rect2(r.position+Vector2(0,7+band*3),Vector2(size.x,3)),Color(0.03,0.08,0.06,0.14-band*0.025))
	# Broad, soft-edged rust streaks and trailing ivy break up repeated tiles.
	for i in range(int(size.x/110)):
		var x := r.position.x+26+i*110
		for j in 9:
			var at := Vector2(x+sin(j*0.8)*5,r.position.y+j*7)
			foliage.line(at,at+Vector2(0,8),Color("40523a"),2,true)
			leaf(at,Vector2(-6,-2),Color("58754a"))
			if j%2 == 0: leaf(at+Vector2(1,4),Vector2(7,-2),Color("809455"))

func stone_rect(rect: Rect2) -> void:
	# Subdivide so wider decks never stretch the stone courses.
	for i in range(int(ceil(rect.size.x/384.0))):
		var width := minf(384,rect.size.x-i*384)
		var dest := Rect2(rect.position+Vector2(i*384,0),Vector2(width,rect.size.y))
		draw_texture_rect_region(STONE,dest,Rect2(0,0,width*4,rect.size.y*4),Color(0.69,0.77,0.70))

func stone_polygon(points: PackedVector2Array) -> void:
	var uv := PackedVector2Array()
	for p in points:
		uv.append((p+size/2)*4/Vector2(STONE.get_size()))
	stonework.quad(points,Color(0.57,0.66,0.60),uv)
