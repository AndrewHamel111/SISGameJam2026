class_name GasStation
extends Node3D

var fill_rate := 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player:
		player.entered_gas_station(self)


func _on_area_3d_body_exited(body: Node3D) -> void:
	var player := body as Player
	if player:
		player.exited_gas_station(self)
