class_name PhoneDisplay
extends Control

@onready var vbox: VBoxContainer = $TextureRect/VBoxContainer
@onready var order_display : PackedScene = load("res://scenes/order_display.tscn")

func _ready() -> void:
	call_deferred("add_order")

func add_order() -> void:
	var node := order_display.instantiate() as OrderDisplay
	node.set_details("Jimmy", "250 City Centre", 5.25, 3)
	vbox.add_child(node)
