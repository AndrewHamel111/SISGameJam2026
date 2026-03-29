class_name OrderDisplay
extends ColorRect

@onready var order_name: Label = $OrderName
@onready var order_destination: Label = $OrderDestination
@onready var order_value: Label = $Value
@onready var order_duration: Label = $Duration

var order: Order
var _name: String
var desc: String
var money: String
var duration: String

func set_order(value: Order) -> void:
	order = value
	
	var address := "%d %s" % [order.destination_street_number, order.destination_street_name]
	set_details(order.name, address, order.value, order.duration)

func set_details(title: String, address: String, value: float, time: float) -> void:
	_name = title
	desc = address
	money = "$%.2f" % [value]
	if time as int % 60 != 0:
		duration = "%dm %ds" % [(time as int / 60), (time as int % 60)]
	else:
		duration = "%dm" % [(time as int / 60)]

func _ready() -> void:
	order_name.text = _name
	order_destination.text = desc
	order_value.text = money
	order_duration.text = duration
