extends Node3D

@onready var car_wheel := $car_wheel as Node3D

func set_wheel_angle(angle: float) -> void:
	car_wheel.rotation = Vector3.ZERO
	car_wheel.rotate_z(angle)
