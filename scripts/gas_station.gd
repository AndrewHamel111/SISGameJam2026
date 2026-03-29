class_name GasStation
extends Node3D

var fill_rate := 5
var cost := 0.75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player := get_node("/root/World/Player") as Player
	var player_pos := player.transform.origin
	var distance_to_player := transform.origin.distance_to(player_pos)
	var height := pow(distance_to_player, 1) * 0.3
	var mesh_instance := get_node("pump_area/MeshInstance3D")
	if mesh_instance:
		var mesh := mesh_instance.mesh as Mesh;
		var material := mesh.material as Material
		if material:
			material.set_shader_parameter("max_height", height)
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player:
		player.entered_gas_station(self)


func _on_area_3d_body_exited(body: Node3D) -> void:
	var player := body as Player
	if player:
		player.exited_gas_station(self)
