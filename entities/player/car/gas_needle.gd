extends Node3D

var needle_angle_empty: float = -60.0
var needle_angle_full: float = 60.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player := get_node("/root/World/Player") as Player

	var perc : float = player.gas_remaining / player.gas_max
	rotation_degrees = Vector3(0, 0, needle_angle_empty + perc * (needle_angle_full - needle_angle_empty))
