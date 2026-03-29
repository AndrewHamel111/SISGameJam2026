class_name World
extends Node3D

const ORDER_MIN_SQR_DIST := 600.0
@onready var available_offers_root : Node = $Orders

var houses : Array[House]
var next_order_id : int = 0
var player_ref: Player
var order_timeout: SceneTreeTimer

@export var order_reward_min: Curve
@export var order_reward_max: Curve
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
	
	player_ref = get_node("/root/World/Player") as Player
	player_ref.start_order.connect(_on_player_start_order)
	player_ref.pickup_order.connect(_on_player_pickup_order)
	player_ref.deliver_order.connect(_on_player_deliver_order)
	
	repopulate_names()
	add_order()
	add_order()
	add_order()

func add_order() -> void:
	var expired_orders: Array[Order]
	for node in available_offers_root.get_children():
		var order := node as Order
		if order.is_expired() or order.status == Order.Status.COMPLETED:
			expired_orders.push_back(order)
	for order in expired_orders:
		available_offers_root.remove_child(order)
		order.free()
	available_offers_root.add_child(create_new_order())
	update_player_hud()

func create_new_order() -> Order:
	var order := Order.new()
	order.id = next_order_id
	next_order_id += 1
	
	if order_names.is_empty():
		repopulate_names()
	order.name = order_names.pop_back()
	
	var pickup := houses.pick_random() as House
	order.pickup_address = pickup.name
	order.pickup_street_number = pickup.street_number
	order.pickup_street_name = pickup.street_name
	
	var destination := get_destination_for(pickup)
	order.destination_address = destination.name
	order.destination_street_number = destination.street_number
	order.destination_street_name = destination.street_name
	
	order.value = get_next_order_value()
	order.duration = get_next_order_duration()
	
	return order

func get_next_order_value() -> float:
	var current_min := order_reward_min.sample(player_ref.rating)
	var current_max := order_reward_max.sample(player_ref.rating)
	return randf_range(current_min, current_max)

func get_next_order_duration() -> float:
	return randf_range(60, 180)

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
	player_ref.hud.phone_display.set_orders(available_offers_root)

func repopulate_names() -> void:
	order_names = possible_order_names.duplicate()
	order_names.shuffle()

func get_house(address: String) -> House:
	var house := get_node("buildings/" + address) as House
	if not house:
		push_error("Failed to get house at address \"%s\"" % [house])
	return house

func _on_player_start_order(order: Order) -> void:
	order.status = Order.Status.STARTED
	order.start_time = Time.get_ticks_msec()
	var pickup := get_house(order.pickup_address)
	pickup.show_collider()
	order_timeout = get_tree().create_timer(order.duration)
	order_timeout.timeout.connect(_on_order_timeout)
	update_player_hud()

func _on_player_pickup_order(order: Order) -> void:
	order.status = Order.Status.PICKED_UP
	var pickup := get_house(order.pickup_address)
	pickup.show_collider(false)
	var destination := get_house(order.destination_address)
	destination.show_collider()
	update_player_hud()

func _on_player_deliver_order(order: Order) -> void:
	order.status = Order.Status.COMPLETED
	var destination := get_house(order.destination_address)
	destination.show_collider(false)
	player_ref.add_money(order.value)
	player_ref.add_rating(1)
	get_tree().create_timer(1.0).timeout.connect(add_order)
	update_player_hud()

func _on_order_timeout() -> void:
	player_ref.add_rating(-2)
	player_ref.handle_timeout()
	get_tree().create_timer(1.0).timeout.connect(add_order)
	update_player_hud()
