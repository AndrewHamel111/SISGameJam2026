class_name PhoneDisplay
extends Control

@onready var vbox: VBoxContainer = $TextureRect/OrdersView/VBoxContainer
@onready var order_display : PackedScene = load("res://scenes/order_display.tscn")
@onready var app_views: Array[Control] = [
	$TextureRect/OrdersView,
	$TextureRect/MapView,
	$TextureRect/BankView,
]

enum App
{
	ORDERS = 0,
	MAP,
	BANK,
	COUNT,
}

var current_app: int = App.ORDERS as int

static var status_color: Dictionary[Order.Status, Color] = {
	Order.Status.PENDING: Color.LIGHT_GRAY,
	Order.Status.STARTED: Color.LIGHT_YELLOW,
	Order.Status.PICKED_UP: Color.SKY_BLUE,
	Order.Status.COMPLETED: Color.LIME,
	Order.Status.FAILED: Color.INDIAN_RED,
}

func add_order(order_details: Order) -> void:
	for node in vbox.get_children():
		if (node as OrderDisplay).order == order_details:
			return
	var node := order_display.instantiate() as OrderDisplay
	node.set_order(order_details)
	node.color = status_color[order_details.status]
	#node.set_indexed("modulate:a", 0.5)
	vbox.add_child(node)

var current_order_search : Order
func display_matches_order(display: OrderDisplay) -> bool:
	return display.order == current_order_search

func set_orders(orders_root: Node) -> void:
	for node in vbox.get_children():
		var display := node as OrderDisplay
		if not orders_root.get_children().has(display.order):
			vbox.remove_child(node)
			node.queue_free()
	for child in orders_root.get_children():
		if not child is Order:
			push_error("Node which is not Order is child of /root/World/Orders !")
			continue
		add_order(child as Order)

func select_order(index: int) -> void:
	if current_app != App.ORDERS:
		return
	var children := vbox.get_children()
	for node in children:
		var order := node as OrderDisplay
		order.color = status_color[order.order.status]
		order.set_indexed("modulate:a", 0.5)
	if index < children.size():
		var selected := children[index] as OrderDisplay
		if selected:
			selected.set_indexed("modulate:a", 1.0)
			#selected.color = Color.LIGHT_CYAN

func get_order(index: int) -> OrderDisplay:
	var children := vbox.get_children()
	if index >= children.size():
		push_error("Tried to get_order for an index (%d) exceeding the order slots on the phone!" % [index])
		return null
	return children[index] as OrderDisplay

func set_rating(rating: int) -> void:
	var gold_star_root : Node = $TextureRect/OrdersView/HBoxContainer
	for node in gold_star_root.get_children():
		node.visible = rating > 0
		rating -= 1

func scroll_apps(direction: int) -> void:
	current_app += direction
	if current_app == App.COUNT as int:
		current_app = 0
	elif current_app == -1:
		current_app = (App.COUNT as int) - 1
	
	for view in app_views:
		view.hide()
	
	app_views[current_app].show()
