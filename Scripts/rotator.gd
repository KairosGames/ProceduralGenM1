class_name Rotator extends Node3D

@export var a_speed: float = 0.25

func _process(delta: float) -> void:
	rotate(Vector3.UP, a_speed * delta)
