class_name IcosphereGenerator extends Node3D

@export_category("Settings")
@export var radius: float = 10.0
@export_range(0, 8) var subdivisions: int = 7

@export_category("References")
@export var planetRelief: PlanetRelief
@export var groundColorizor: GroundColorizor
@export var waterColorizer: WaterColorizer

func _ready() -> void:
	var mi_ground := MeshInstance3D.new()
	mi_ground.mesh = build_icosphere(radius, subdivisions)
	add_child(mi_ground)
	planetRelief.generateIcosphereRelief(global_position, mi_ground)
	groundColorizor.colorize(mi_ground, radius, planetRelief.amplitude)
	build_water(mi_ground)

func build_icosphere(r: float, subdiv: int) -> ArrayMesh:
	subdiv = max(subdiv, 0)
	
	var t : float = (1.0 + sqrt(5.0)) * 0.5
	var vertices := PackedVector3Array([
		Vector3(-1,  t,  0), Vector3( 1,  t,  0), Vector3(-1, -t,  0), Vector3( 1, -t,  0),
		Vector3( 0, -1,  t), Vector3( 0,  1,  t), Vector3( 0, -1, -t), Vector3( 0,  1, -t),
		Vector3( t,  0, -1), Vector3( t,  0,  1), Vector3(-t,  0, -1), Vector3(-t,  0,  1),
	])
	
	for i in range(vertices.size()):
		vertices[i] = vertices[i].normalized()

	var triangles := PackedInt32Array([
		0, 11, 5,   0, 5, 1,    0, 1, 7,    0, 7, 10,   0, 10, 11,
		1, 5, 9,    5, 11, 4,   11, 10, 2,  10, 7, 6,   7, 1, 8,
		3, 9, 4,    3, 4, 2,    3, 2, 6,    3, 6, 8,    3, 8, 9,
		4, 9, 5,    2, 4, 11,   6, 2, 10,   8, 6, 7,    9, 8, 1
	])

	var midpoint_cache: Dictionary = {}

	for _s in range(subdiv):
		midpoint_cache.clear()
		var new_tris := PackedInt32Array()
		new_tris.resize(triangles.size() * 4)

		var w: int = 0
		for k in range(0, triangles.size(), 3):
			var a := triangles[k]
			var b := triangles[k + 1]
			var c := triangles[k + 2]

			var ab := get_midpoint(a, b, vertices, midpoint_cache)
			var bc := get_midpoint(b, c, vertices, midpoint_cache)
			var ca := get_midpoint(c, a, vertices, midpoint_cache)

			new_tris[w] = a;  new_tris[w + 1] = ab; new_tris[w + 2] = ca; w += 3
			new_tris[w] = b;  new_tris[w + 1] = bc; new_tris[w + 2] = ab; w += 3
			new_tris[w] = c;  new_tris[w + 1] = ca; new_tris[w + 2] = bc; w += 3
			new_tris[w] = ab; new_tris[w + 1] = bc; new_tris[w + 2] = ca; w += 3

		triangles = new_tris
		
	for i in range(0, triangles.size(), 3):
		var tmp := triangles[i + 1]
		triangles[i + 1] = triangles[i + 2]
		triangles[i + 2] = tmp
	
	var normals := PackedVector3Array()
	normals.resize(vertices.size())

	for i in range(vertices.size()):
		var n := vertices[i].normalized()
		normals[i] = n
		vertices[i] = n * r

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = triangles

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func edge_key(a: int, b: int) -> int:
	var x : int = mini(a, b)
	var y : int = maxi(a, b)
	return (x << 20) ^ y

func get_midpoint(a: int, b: int, vertices: PackedVector3Array, cache: Dictionary) -> int:
	var key := edge_key(a, b)
	if cache.has(key):
		return cache[key]

	var mid := (vertices[a] + vertices[b]) * 0.5
	mid = mid.normalized()

	var idx := vertices.size()
	vertices.append(mid)
	cache[key] = idx
	return idx

func build_water(mi_ground: MeshInstance3D):
	var mi_sea := MeshInstance3D.new()
	mi_sea.mesh = build_icosphere(radius, subdivisions)
	mi_sea.scale = Vector3.ONE * ((radius + 0.05) / radius)
	waterColorizer.max_depth = planetRelief.amplitude
	waterColorizer.setup_water(mi_ground, mi_sea, radius)
	add_child(mi_sea)
