class_name HUDController
extends Control

@onready var label_2: Label = $Label2
@onready var label: Label = $Label

func set_speed(speed: int) -> void:
	label.text = "%d MPH" % [speed]
	label_2.text = "%d MPH" % [speed]
