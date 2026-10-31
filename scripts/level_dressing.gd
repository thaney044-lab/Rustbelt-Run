extends Node2D
## World-space architecture: deliberately behind the fox and all landing rims.
const METAL = preload("res://assets/art/painted/weathered_steel.png")
const WORKSHOP = preload("res://assets/art/painted/workshop.png")
const DrawBatch = preload("res://scripts/draw_batch.gd")
var time := 0.0
var section := -1
var glow: Texture2D
var foliage: RefCounted
var foliage_mesh: ArrayMesh

func _ready() -> void:
	z_index = -3 if section < 0 else 0
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if glow == null:
		create_glow()
	if section < 0:
		# Retained draw commands are split into independently culled world sections.
		for i in 14:
			var chunk: Node2D = get_script().new()
			chunk.section = i
			chunk.glow = glow
			add_child(chunk)
		return
	if section != 12: return
	var sign := Label.new()
	sign.text = "PATCH'S WORKSHOP"
	sign.position = Vector2(12848,372)
	sign.add_theme_font_size_override("font_size",8)
	sign.add_theme_color_override("font_color",Color("d5bb7a"))
	add_child(sign)

func create_glow() -> void:
	var gradient := Gradient.new()
	gradient.set_color(0,Color(1,0.75,0.35,0.22))
	gradient.set_color(1,Color(1,0.75,0.35,0))
	var radial := GradientTexture2D.new()
	radial.gradient = gradient
	radial.fill = GradientTexture2D.FILL_RADIAL
	radial.fill_from = Vector2(0.5,0.5)
	radial.fill_to = Vector2(1,0.5)
	radial.width = 96
	radial.height = 96
	glow = radial

func owns(x: float) -> bool:
	return x >= section*1000 and x < (section+1)*1000

func _draw() -> void:
	if section < 0: return
	foliage = DrawBatch.new()
	# Sagging power cables tie individual jumps to a continuous railway district.
	for spec in [[30,520],[970,1260],[1660,2060],[2580,2990],[4290,4900],[6820,7240],[7870,8010],[8870,9340],[9650,10180],[11480,12150]]:
		if not owns((spec[0]+spec[1])*0.5): continue
		var left: float = spec[0]
		var right: float = spec[1]
		for x in [left,right]:
			girder(Vector2(x,310),210,9)
			foliage.line(Vector2(x-20,315),Vector2(x+20,315),Color("8b8669"),5,true)
		var cable := PackedVector2Array()
		for i in 25:
			var t := i/24.0
			cable.append(Vector2(lerpf(left,right,t),311+sin(t*PI)*35))
		foliage.polyline(cable,Color("223a37"),2,true)
		for i in 5:
			var t := (i+0.5)/5
			var at := Vector2(lerpf(left,right,t),311+sin(t*PI)*35)
			foliage.line(at,at+Vector2(0,10),Color("3c4b3b"),1,true)
			foliage.circle(at+Vector2(0,11),2,Color("ebc578"))
	# Hanging catwalks use braces and chain eyes, not unexplained floating blocks.
	for spec in [[205,315,180,440],[385,495,140,360],[595,705,150,330],[805,895,130,305],[1075,1185,170,290],[1240,1340,210,360],[1375,1525,260,438],[1545,1655,210,350],[2800,2900,180,446],[6030,6250,110,380],[6060,6160,110,295],[6245,6335,90,255],[6400,6500,110,305],[8940,9060,240,450],[9130,9270,220,390],[10270,10410,200,390],[10490,10630,170,340],[11000,11140,250,440],[11520,11640,240,460],[12210,12350,220,410],[12440,12580,190,370]]:
		if not owns((spec[0]+spec[1])*0.5): continue
		var left: float = spec[0]
		var right: float = spec[1]
		var top: float = spec[2]
		var bottom: float = spec[3]
		for x in [left+8,right-8]:
			foliage.line(Vector2(x,top),Vector2(x,bottom),Color("223b37"),3,true)
			foliage.line(Vector2(x-1,top),Vector2(x-1,bottom),Color("9d936d",0.5),1,true)
			for y in range(int(top),int(bottom),18):
				foliage.circle(Vector2(x,y),2.5,Color("6e765b"))
	# Railway railing has thin, subdued uprights behind the playable silhouette.
	for spec in [[35,470,520],[945,1120,520],[1640,1800,520],[4310,4460,520],[6860,7220,520],[8570,8790,490],[9320,9560,460],[9980,10180,460],[10700,10900,390],[11170,11420,520],[11940,12140,460],[12660,12980,490]]:
		if owns((spec[0]+spec[1])*0.5): railing(spec[0],spec[1],spec[2])
	for x in [140,1090,1760,2660,4160,5060,6970,8730,9430,10080,10800,11300,12040,12880]:
		if owns(x): lamp(Vector2(x,330))
	# District landmarks, placed outside the collision path.
	if owns(90): station_clock(Vector2(90,235))
	if owns(1260): water_tower(Vector2(1260,175))
	if owns(2270): pipe_run(1840,2700,575)
	if owns(3555): pipe_run(3020,4090,610)
	if owns(5850): pipe_run(5420,6300,605)
	if owns(6750): pipe_run(6300,7200,605)
	if owns(4650):
		# Canal suspension bridge: cables and service girders behind the crossings.
		for x in [4480,4870]:
			girder(Vector2(x,185),430,12)
			for dx in [-18,18]:
				foliage.line(Vector2(x+dx,196),Vector2(x+dx,218),Color("9c9b78"),2,true)
		var suspension := PackedVector2Array()
		for i in 33:
			var t := i/32.0
			var at := Vector2(4480+t*390,190+sin(t*PI)*125)
			suspension.append(at)
			if i%3 == 0:
				foliage.line(at,Vector2(at.x,450),Color("577064",0.65),1,true)
		foliage.polyline(suspension,Color("a7a17a"),3,true)
	# Widely spaced transfer towers leave the jumping corridor open.
	for x in [7350,7810,8110,8500]:
		if not owns(x): continue
		girder(Vector2(x,260),430,8)
		for y in [280,630]:
			foliage.line(Vector2(x-18,y),Vector2(x+18,y),Color("566c50"),3,true)
	# An illuminated workshop provides a real destination beyond the final jump.
	if owns(12710): workshop(Vector2(12710,279))
	# Ferns live at edges; their roots never change the actual collision rim.
	for spec in [[20,520],[470,520],[940,520],[1510,520],[1845,520],[2980,520],[4240,520],[5310,520],[6810,520],[7240,520],[8780,490],[9540,460],[10170,460],[10890,390],[11430,520],[12140,460],[12990,490]]:
		if owns(spec[0]): fern(Vector2(spec[0],spec[1]),float(spec[0])*0.01)
	if not foliage.vertices.is_empty():
		foliage_mesh = foliage.build()
		draw_mesh(foliage_mesh,null)

func girder(at: Vector2, height: float, width: float) -> void:
	foliage.rect(Rect2(at-Vector2(width/2,0),Vector2(width,height)),Color("263d37"))
	foliage.line(at-Vector2(width/2-1,0),at+Vector2(-width/2+1,height),Color("909277"),2,true)
	for y in range(8,int(height),35):
		foliage.circle(at+Vector2(0,y),1.5,Color("b5a778"))

func railing(left: float, right: float, floor_y: float) -> void:
	for y in [floor_y-36,floor_y-14]:
		foliage.line(Vector2(left,y),Vector2(right,y),Color("31483b",0.85),2,true)
	for x in range(int(left),int(right),36):
		foliage.line(Vector2(x,floor_y),Vector2(x,floor_y-37),Color("52604a"),3,true)
		foliage.circle(Vector2(x,floor_y-38),2.2,Color("a29e72"))

func lamp(at: Vector2) -> void:
	girder(at+Vector2(-20,-10),200,5)
	foliage.polyline(PackedVector2Array([at+Vector2(-20,0),at+Vector2(-20,-15),at+Vector2(0,-15),at]),Color("a39b73"),3,true)
	if glow: draw_texture_rect(glow,Rect2(at-Vector2(58,48),Vector2(116,116)),false)
	foliage.rect(Rect2(at-Vector2(8,0),Vector2(16,22)),Color("273d33"))
	foliage.rect(Rect2(at-Vector2(5,-3),Vector2(10,15)),Color("e7c27e"))
	foliage.line(at+Vector2(0,3),at+Vector2(0,18),Color("645e3d"),1,true)
	foliage.line(at-Vector2(12,0),at+Vector2(12,0),Color("647357"),4,true)

func station_clock(at: Vector2) -> void:
	foliage.line(at+Vector2(-55,0),at+Vector2(0,0),Color("243d35"),8,true)
	foliage.circle(at,29,Color("263b30"))
	foliage.arc(at,26,0,TAU,48,Color("b89d64"),3,true)
	foliage.circle(at,22,Color("c6bc91"))
	for i in 12:
		var d := Vector2.from_angle(i*TAU/12)
		foliage.line(at+d*18,at+d*20,Color("4b5943"),2,true)
	foliage.line(at,at+Vector2(0,-14),Color("354936"),2,true)
	foliage.line(at,at+Vector2(11,5),Color("354936"),3,true)
	foliage.circle(at,3,Color("896e43"))

func water_tower(at: Vector2) -> void:
	for x in [-38,38]:
		girder(at+Vector2(x,65),280,7)
	foliage.line(at+Vector2(-38,90),at+Vector2(38,260),Color("35493b"),5,true)
	foliage.line(at+Vector2(38,90),at+Vector2(-38,260),Color("35493b"),5,true)
	var r := Rect2(at-Vector2(52,0),Vector2(104,82))
	draw_texture_rect_region(METAL,r,Rect2(180,150,400,300),Color(0.72,0.75,0.56))
	for y in [8,37,72]:
		foliage.line(at+Vector2(-54,y),at+Vector2(54,y),Color("263e36"),5,true)
		foliage.line(at+Vector2(-54,y-2),at+Vector2(54,y-2),Color("a49e70"),1,true)
	foliage.polygon(PackedVector2Array([at+Vector2(-60,0),at+Vector2(0,-24),at+Vector2(60,0)]),Color("3e5845"))

func pipe_run(left: float, right: float, y: float) -> void:
	foliage.line(Vector2(left,y+3),Vector2(right,y+3),Color("172f2c"),15,true)
	foliage.line(Vector2(left,y),Vector2(right,y),Color("76674a"),10,true)
	foliage.line(Vector2(left,y-3),Vector2(right,y-3),Color("b09561"),2,true)
	for x in range(int(left)+15,int(right),90):
		foliage.line(Vector2(x,y-9),Vector2(x,y+9),Color("384c3c"),5,true)
		foliage.circle(Vector2(x,y-5),1.5,Color("c1aa72"))

func fern(at: Vector2, phase: float) -> void:
	for i in 7:
		var angle := -PI+0.23+i*0.43+sin(time*0.8+phase)*0.035
		var length := 22+sin(i*2.3+phase)*7
		var d := Vector2.from_angle(angle)
		foliage.line(at,at+d*length,Color("6d8450"),1,true)
		for j in range(2,7):
			var mid := at+d*j*length/7
			var side := Vector2(-d.y,d.x)*(7-j)*1.4
			foliage.quad(PackedVector2Array([mid-d*3,mid+side+d*2,mid+d*3,mid-side+d*2]),Color("789154") if j%2 else Color("506f45"))

func workshop(at: Vector2) -> void:
	draw_texture_rect(WORKSHOP,Rect2(at,Vector2(WORKSHOP.get_size())*0.22),false,Color(0.85,0.90,0.78))
	if glow:
		draw_texture_rect(glow,Rect2(at+Vector2(100,115),Vector2(150,125)),false,Color(1,0.9,0.7,0.7+sin(time)*0.04))
