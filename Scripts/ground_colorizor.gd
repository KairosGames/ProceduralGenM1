class_name GroundColorizor extends Node

@export var groundShader: Shader
@export var gradient: GradientTexture1D

func colorize(mi: MeshInstance3D, radius: float, amplitude: float) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = groundShader
	mat.set_shader_parameter("altitude_gradient", gradient)
	mat.set_shader_parameter("base_radius", radius)
	mat.set_shader_parameter("amplitude", amplitude)
	mat.set_shader_parameter("center_world", mi.global_position)
	mi.material_override = mat
