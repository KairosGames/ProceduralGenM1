class_name UVSphereGenerator extends Node3D

@export var radius: float = 10.0
@export_range(3, 256) var rings: int = 32
@export_range(3, 256) var segments: int = 64

@export var relief_strength: float = 0.1
@export var seed_value: int = 12345

func _ready() -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = build_bumpy_uv_sphere(radius, rings, segments, relief_strength, seed_value)
	add_child(mi)

func build_bumpy_uv_sphere(r: float, ring_count: int, seg_count: int, strength: float, seed: int) -> ArrayMesh:
	ring_count = max(ring_count, 3)
	seg_count = max(seg_count, 3)

	var rng := RandomNumberGenerator.new()
	rng.seed = seed

	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	for i in range(ring_count + 1):
		var v: float = float(i) / float(ring_count)
		var phi: float = PI * v

		var sin_phi := sin(phi)
		var cos_phi := cos(phi)

		for j in range(seg_count + 1):
			var u := float(j) / float(seg_count)
			var theta := TAU * u

			var sin_theta: float = sin(theta)
			var cos_theta: float = cos(theta)

			var dir := Vector3(
				sin_phi * cos_theta,
				cos_phi,
				sin_phi * sin_theta
			).normalized()

			var offset := rng.randf_range(-strength, strength)

			var pos := dir * (r + offset)

			vertices.append(pos)
			normals.append(dir)
			uvs.append(Vector2(u, 1.0 - v))

	var stride := seg_count + 1
	for i in range(ring_count):
		for j in range(seg_count):
			var a := i * stride + j
			var b := a + stride
			var c := b + 1
			var d := a + 1

			indices.append(a); indices.append(b); indices.append(c)
			indices.append(a); indices.append(c); indices.append(d)

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
