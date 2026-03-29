extends Node2D

var minimap_camera: Camera3D
var player: Node3D

func _ready() -> void:
	minimap_camera = get_node("%MinimapCamera") as Camera3D
	player = get_node("/root/World/Player") as Node3D

func _process(_delta: float) -> void:
	minimap_camera.global_position.x = player.global_position.x
	minimap_camera.global_position.z = player.global_position.z
	minimap_camera.global_rotation.y = player.global_rotation.y + PI
