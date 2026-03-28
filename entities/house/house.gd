class_name House
extends Node3D

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
