class_name WaterColorizer extends Node

@export var water_shader: Shader
@export var depth_gradient: GradientTexture1D
@export var max_depth: float = 3.0

func setup_water(ground_mi: MeshInstance3D, sea_mi: MeshInstance3D, sea_level: float) -> void:
	write_depth_vertex_colors(ground_mi, sea_mi, sea_level, max_depth)

	var mat := ShaderMaterial.new()
	mat.render_priority = 0
	mat.shader = water_shader
	mat.set_shader_parameter("depth_gradient", depth_gradient)
	sea_mi.material_override = mat

func write_depth_vertex_colors(ground_mi: MeshInstance3D, sea_mi: MeshInstance3D, sea_level: float, max_d: float) -> void:
	var ground_mesh := ground_mi.mesh as ArrayMesh
	var sea_mesh := sea_mi.mesh as ArrayMesh
	var g := MeshDataTool.new()
	var s := MeshDataTool.new()
	g.create_from_surface(ground_mesh, 0)
	s.create_from_surface(sea_mesh, 0)

	var vcount := mini(g.get_vertex_count(), s.get_vertex_count())
	var inv := 1.0 / maxf(max_d, 0.0001)

	for i in range(vcount):
		var gv := g.get_vertex(i)
		var ground_r := gv.length()
		var depth := maxf(0.0, sea_level - ground_r)
		var depth01 := clampf(depth * inv, 0.0, 1.0)

		s.set_vertex_color(i, Color(depth01, 0, 0, 1))

	var mat0 := sea_mesh.surface_get_material(0)
	sea_mesh.clear_surfaces()
	s.commit_to_surface(sea_mesh)
	sea_mesh.surface_set_material(0, mat0)
	sea_mi.mesh = sea_mesh
