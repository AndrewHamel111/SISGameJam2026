class_name World
extends Node3D

const ORDER_MIN_SQR_DIST := 60.0
@onready var available_offers_root : Node = $Orders

var houses : Array[House]
var next_order_id : int = 0

@export var possible_order_names : Array[String]
var order_names : Array[String]

func _ready() -> void:
	setup_game()
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(update_player_hud)

func setup_game() -> void:
	var buildings_root := get_node("buildings") as Node3D
	for child in buildings_root.get_children():
		var house := child as House
		if house:
			houses.push_back(house)
	
	available_offers_root.add_child(create_new_order())
	available_offers_root.add_child(create_new_order())
	available_offers_root.add_child(create_new_order())
	repopulate_names()

func create_new_order() -> Order:
	var order := Order.new()
	order.id = next_order_id
	next_order_id += 1
	
	if order_names.is_empty():
		repopulate_names()
	order.name = order_names.pop_back()
	
	var pickup := houses.pick_random() as House
	order.pickup_street_number = pickup.street_number
	order.pickup_street_name = pickup.street_name
	
	var destination := get_destination_for(pickup)
	order.destination_street_number = destination.street_number
	order.destination_street_name = destination.street_name
	
	return order

func get_destination_for(house: House) -> House:
	var value : House = null
	while !value:
		var candidate := houses.pick_random() as House
		var invalid := candidate == house or \
			candidate.global_position.distance_squared_to(house.global_position) < ORDER_MIN_SQR_DIST
		if invalid:
			continue
		value = candidate
	return value

func update_player_hud() -> void:
	var player := get_node("/root/World/Player") as Player
	player.hud.phone_display.set_orders(available_offers_root)

func repopulate_names() -> void:
	order_names = possible_order_names.duplicate()
	order_names.shuffle()
