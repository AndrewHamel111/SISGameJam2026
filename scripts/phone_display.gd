class_name PhoneDisplay
extends Control

@onready var vbox: VBoxContainer = $TextureRect/VBoxContainer
@onready var order_display : PackedScene = load("res://scenes/order_display.tscn")

func add_order(order_details: Order) -> void:
	var node := order_display.instantiate() as OrderDisplay
	var address := "%d %s" % [order_details.destination_street_number, order_details.destination_street_name]
	node.set_details(order_details.name, address, order_details.value, order_details.duration)
	vbox.add_child(node)

func set_orders(orders_root: Node) -> void:
	for node in vbox.get_children():
		vbox.remove_child(node)
		node.free()
	for child in orders_root.get_children():
		if not child is Order:
			push_error("Node which is not Order is child of /root/World/Orders !")
			continue
		add_order(child as Order)

func select_order(index: int) -> void:
	var children := vbox.get_children()
	for node in children:
		var order := node as OrderDisplay
		order.color = Color.LIGHT_GRAY
	if index < children.size():
		var selected := children[index] as OrderDisplay
		if selected:
			selected.color = Color.LIGHT_CYAN
