extends Node2D

var time := 0.0
var shafts: ArrayMesh

func _ready() -> void:
	# Soft-edged rays are built once and submitted as one retained mesh.
	var mesh_arrays: Array = []
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	var vertices := PackedVector2Array()
	var colors := PackedColorArray()
	for i in 3:
		var x := 830+i*120.0
		var points := [Vector2(x,-50),Vector2(x+25,-50),Vector2(x+50,-50),Vector2(x-510,660),Vector2(x-465,660),Vector2(x-420,660)]
		var shades := [0.0,0.045,0.0,0.0,0.008,0.0]
		for index in [0,1,4,0,4,3,1,2,5,1,5,4]:
			vertices.append(points[index])
			colors.append(Color(1.0,0.85,0.60,shades[index]))
	mesh_arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh_arrays[Mesh.ARRAY_COLOR] = colors
	shafts = ArrayMesh.new()
	shafts.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,mesh_arrays)


func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	draw_mesh(shafts,null)
	for i in 18:
		var x := fposmod(i*179.0+sin(time*.14+i)*24,1152)
		var y := fposmod(i*71.0-time*(2.0+i%3),620)
		draw_circle(Vector2(x,y),0.7+float(i%2)*0.45,Color(1.0,0.88,0.63,0.18))
