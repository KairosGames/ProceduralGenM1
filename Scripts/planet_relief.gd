class_name PlanetRelief extends Node3D

@export var noise: FastNoiseLite
@export var amplitude: float = 8.0 
@export var frequency: float = 5.0 
@export var use_world_space: bool = true

func generateIcosphereRelief(center_global: Vector3, icoMesh: MeshInstance3D) -> void:
	var array_mesh := icoMesh.mesh as ArrayMesh
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)
	var center_local := icoMesh.to_local(center_global)
	var vcount := mdt.get_vertex_count()
	for i in range(vcount):
		var v := mdt.get_vertex(i)
		var dir := (v - center_local)
		var dlen := dir.length()
		if dlen == 0.0:
			continue
		dir /= dlen

		var sample_pos: Vector3
		if use_world_space:
			var v_world := icoMesh.to_global(v)
			sample_pos = v_world * frequency
		else:
			sample_pos = v * frequency

		var h := noise.get_noise_3d(sample_pos.x, sample_pos.y, sample_pos.z)
		var offset := h * amplitude

		var new_v := v + dir * offset
		mdt.set_vertex(i, new_v)

	_recalculate_normals(mdt, center_local)
	var mat := array_mesh.surface_get_material(0)
	array_mesh.clear_surfaces()
	mdt.commit_to_surface(array_mesh)
	array_mesh.surface_set_material(0, mat)
	icoMesh.mesh = array_mesh

func _recalculate_normals(mdt: MeshDataTool, center_local: Vector3) -> void:
	var vcount := mdt.get_vertex_count()
	var acc := []
	acc.resize(vcount)
	for i in range(vcount):
		acc[i] = Vector3.ZERO

	var fcount := mdt.get_face_count()
	for f in range(fcount):
		var a := mdt.get_face_vertex(f, 0)
		var b := mdt.get_face_vertex(f, 1)
		var c := mdt.get_face_vertex(f, 2)

		var va := mdt.get_vertex(a)
		var vb := mdt.get_vertex(b)
		var vc := mdt.get_vertex(c)

		var n := (vb - va).cross(vc - va)
		if n.length_squared() == 0.0:
			continue

		n = n.normalized()
		acc[a] += n
		acc[b] += n
		acc[c] += n

	for i in range(vcount):
		var n: Vector3 = acc[i]
		if n.length_squared() == 0.0:
			n = Vector3.UP
		else:
			n = n.normalized()

		var v := mdt.get_vertex(i)
		var radial := (v - center_local).normalized()
		if n.dot(radial) < 0.0:
			n = -n

		mdt.set_vertex_normal(i, n)
