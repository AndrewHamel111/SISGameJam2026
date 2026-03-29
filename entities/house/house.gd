class_name House
extends Node3D

@onready var area_3d: Area3D = $Area3D
@onready var beacon: Node3D = $Beacon

var street_number: int
var street_name: String

func _ready() -> void:
	var house_number := ""
	var house_name := name as String
	for i in house_name.length():
		var c := house_name[i]
		if c.is_valid_int():
			house_number += c
		else:
			street_name += c
	street_number = house_number.to_int()

func show_collider(value: bool = true) -> void:
	beacon.visible = value
	area_3d.monitoring = value

func _on_area_3d_body_entered(body: Node3D) -> void:
	var player := body as Player
	if not player:
		push_error("Non player body has entered House Area3D!")
		return
	player.house_area_entered(self)
