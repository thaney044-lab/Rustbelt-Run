extends RefCounted
## Merge small decorative quads into one retained canvas mesh.
var vertices := PackedVector2Array()
var colors := PackedColorArray()
var uvs := PackedVector2Array()

func quad(points: PackedVector2Array, color: Color, texture_uv := PackedVector2Array()) -> void:
	for index in [0,1,2,0,2,3]:
		vertices.append(points[index])
		colors.append(color)
		uvs.append(texture_uv[index] if texture_uv.size() == 4 else Vector2.ZERO)

func build() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	if vertices.is_empty(): return mesh
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh

func rect(area: Rect2, color: Color) -> void:
	quad(PackedVector2Array([area.position,Vector2(area.end.x,area.position.y),area.end,Vector2(area.position.x,area.end.y)]),color)

func line(a: Vector2, b: Vector2, color: Color, width := 1.0, antialiased := false) -> void:
	var side := (b-a).orthogonal().normalized()
	var half := maxf(width,1)*0.5
	quad(PackedVector2Array([a-side*half,b-side*half,b+side*half,a+side*half]),color)
	if antialiased:
		var clear := Color(color,0)
		for sign_value in [-1.0,1.0]:
			var inner: Vector2 = side*half*sign_value
			var outer: Vector2 = side*(half+0.75)*sign_value
			var points := PackedVector2Array([a+inner,b+inner,b+outer,a+outer])
			var shades := PackedColorArray([color,color,clear,clear])
			for index in [0,1,2,0,2,3]:
				vertices.append(points[index])
				colors.append(shades[index])
				uvs.append(Vector2.ZERO)

func circle(center: Vector2, radius: float, color: Color) -> void:
	var count := clampi(int(radius*2),12,48)
	for i in count:
		for point in [center,center+Vector2.from_angle(i*TAU/count)*radius,center+Vector2.from_angle((i+1)*TAU/count)*radius]:
			vertices.append(point)
			colors.append(color)
			uvs.append(Vector2.ZERO)

func polygon(points: PackedVector2Array, color: Color) -> void:
	for index in Geometry2D.triangulate_polygon(points):
		vertices.append(points[index])
		colors.append(color)
		uvs.append(Vector2.ZERO)

func polyline(points: PackedVector2Array, color: Color, width := 1.0, antialiased := false) -> void:
	for i in range(points.size()-1):
		line(points[i],points[i+1],color,width,antialiased)

func arc(at: Vector2, radius: float, start: float, end: float, count: int, color: Color, width := 1.0, antialiased := false) -> void:
	var points := PackedVector2Array()
	for i in count:
		points.append(at+Vector2.from_angle(lerpf(start,end,float(i)/(count-1)))*radius)
	polyline(points,color,width,antialiased)

func multiline(points: PackedVector2Array, color: Color, width := 1.0, antialiased := false) -> void:
	for i in range(0,points.size(),2):
		line(points[i],points[i+1],color,width,antialiased)
